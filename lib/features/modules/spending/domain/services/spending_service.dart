import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/fixed_expense_model.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/expense_entity.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';

class SpendingNotifier extends AsyncNotifier<List<FixedExpenseModel>> {
  final _store = ObjectBoxService.instance.store;

  @override
  Future<List<FixedExpenseModel>> build() async {
    final localData = _store.box<ExpenseEntity>().getAll();
    return localData.map((e) => e.toDomain()).toList();
  }

  Future<void> _saveLocal(FixedExpenseModel model) async {
    final entity = ExpenseEntity.fromDomain(model);
    _store.box<ExpenseEntity>().put(entity);
  }

  Future<void> _deleteLocal(String uuid) async {
    final query = _store.box<ExpenseEntity>().query(ExpenseEntity_.uuid.equals(uuid)).build();
    final entity = query.findFirst();
    query.close();
    if (entity != null) {
      _store.box<ExpenseEntity>().remove(entity.id);
    }
  }

  Future<void> addFixedExpense(FixedExpenseModel expense) async {
    final currentExpenses = state.value ?? [];
    final newList = [...currentExpenses, expense];
    state = AsyncValue.data(newList);

    await _saveLocal(expense);
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
      await _scheduleNotification(updatedExpense);
    }
  }

  Future<void> deleteFixedExpense(String id) async {
    final currentExpenses = state.value ?? [];
    final newList = currentExpenses.where((e) => e.id != id).toList();
    state = AsyncValue.data(newList);

    await _deleteLocal(id);
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
