import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isar/isar.dart';

import 'package:disciplinum/features/modules/spending/domain/entities/fixed_expense_model.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/expense_entity.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class SpendingNotifier extends AsyncNotifier<List<FixedExpenseModel>> {
  static const String _moduleId = 'spending';

  final SupabaseClient _supabase = Supabase.instance.client;
  Isar get _isar => IsarService.instance.database;

  @override
  Future<List<FixedExpenseModel>> build() async {
    // 1. Carrega local (Isar)
    final localData = await _isar.expenseEntitys.where().findAll();
    final expenses = localData.map((e) => e.toDomain()).toList();

    // 2. Tenta carregar da nuvem em background
    _syncCloudInBackground();

    return expenses;
  }

  Future<void> _syncCloudInBackground() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', _moduleId)
          .maybeSingle();

      if (response != null && response['module_data'] != null) {
        final cloudJson = response['module_data'];
        final Map<String, dynamic> decoded =
            cloudJson is String ? jsonDecode(cloudJson) : cloudJson;

        if (decoded['fixed_expenses'] != null) {
          final List<dynamic> expensesJson = decoded['fixed_expenses'];
          final cloudExpenses =
              expensesJson.map((e) => FixedExpenseModel.fromJson(e)).toList();

          await _saveAllLocal(cloudExpenses);
          state = AsyncValue.data(cloudExpenses);
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar gastos fixos com nuvem (load)', error: e);
    }
  }

  Future<void> _saveAllLocal(List<FixedExpenseModel> models) async {
    final entities = models.map((e) => ExpenseEntity.fromDomain(e)).toList();
    await _isar.writeTxn(() async {
      await _isar.expenseEntitys.clear();
      await _isar.expenseEntitys.putAll(entities);
    });
  }

  Future<void> _saveLocal(FixedExpenseModel model) async {
    final entity = ExpenseEntity.fromDomain(model);
    await _isar.writeTxn(() async {
      await _isar.expenseEntitys.put(entity);
    });
  }

  Future<void> _deleteLocal(String uuid) async {
    await _isar.writeTxn(() async {
      await _isar.expenseEntitys.deleteByUuid(uuid);
    });
  }

  Future<void> _saveCloud(List<FixedExpenseModel> currentExpenses) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final cloudData = {
        'fixed_expenses': currentExpenses.map((e) => e.toJson()).toList(),
      };

      await _supabase.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': cloudData,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, module_id');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar gastos fixos com nuvem (save)', error: e);
    }
  }

  Future<void> addFixedExpense(FixedExpenseModel expense) async {
    final currentExpenses = state.value ?? [];
    final newList = [...currentExpenses, expense];
    state = AsyncValue.data(newList);

    await _saveLocal(expense);
    await _saveCloud(newList);
    await _scheduleNotification(expense);
  }

  Future<void> updateFixedExpense(FixedExpenseModel updatedExpense) async {
    final currentExpenses = state.value ?? [];
    final index = currentExpenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      final newList = List<FixedExpenseModel>.from(currentExpenses);
      newList[index] = updatedExpense;
      state = AsyncValue.data(newList);

      await _saveLocal(updatedExpense);
      await _saveCloud(newList);
      await _scheduleNotification(updatedExpense);
    }
  }

  Future<void> deleteFixedExpense(String id) async {
    final currentExpenses = state.value ?? [];
    final newList = currentExpenses.where((e) => e.id != id).toList();
    state = AsyncValue.data(newList);

    await _deleteLocal(id);
    await _saveCloud(newList);
    await _cancelNotification(id);
  }

  Future<void> togglePaid(String id) async {
    final currentExpenses = state.value ?? [];
    final index = currentExpenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      final expense = currentExpenses[index];
      final newStatus = !expense.isPaid;
      final updated = expense.copyWith(
        isPaid: newStatus,
        lastPaid: newStatus ? DateTime.now() : null,
      );

      final newList = List<FixedExpenseModel>.from(currentExpenses);
      newList[index] = updated;
      state = AsyncValue.data(newList);

      await _saveLocal(updated);
      await _saveCloud(newList);
    }
  }

  Future<void> updateExpense(String id, {double? newAmount, String? newCurrency, int? newDueDay}) async {
    final currentExpenses = state.value ?? [];
    final index = currentExpenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      final expense = currentExpenses[index];
      final updated = expense.copyWith(
        amount: newAmount ?? expense.amount,
        currency: newCurrency ?? expense.currency,
        dueDay: newDueDay ?? expense.dueDay,
      );

      final newList = List<FixedExpenseModel>.from(currentExpenses);
      newList[index] = updated;
      state = AsyncValue.data(newList);

      await _saveLocal(updated);
      await _saveCloud(newList);
      await _scheduleNotification(updated);
    }
  }

  Future<void> _scheduleNotification(FixedExpenseModel expense) async {
    final int notifyId = expense.id.hashCode.abs() % 10000;
    await _cancelNotification(expense.id);

    if (!expense.notificationsEnabled) return;

    await NotificationService.scheduleMonthlyNotification(
      id: notifyId,
      dayOfMonth: expense.dueDay,
      time: const TimeOfDay(hour: 9, minute: 0),
      title: 'Lembrete de Conta: ${expense.name}',
      body:
          'Não esqueça de pagar ${expense.currency} ${expense.amount.toStringAsFixed(2)} hoje!',
      payload: 'fixed_expense_${expense.id}',
    );
  }

  Future<void> _cancelNotification(String id) async {
    final int notifyId = id.hashCode.abs() % 10000;
    await NotificationService.cancelNotification(notifyId);
  }
}

final spendingProvider =
    AsyncNotifierProvider<SpendingNotifier, List<FixedExpenseModel>>(() {
  return SpendingNotifier();
});
