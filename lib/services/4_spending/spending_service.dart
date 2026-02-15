import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/models/4_spending/fixed_expense_model.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';

class SpendingService extends ChangeNotifier {
  static const String _moduleId = 'spending';
  static const String _localKey = 'spending_fixed_expenses';

  final SharedPreferences _prefs;
  final SupabaseClient _supabase = Supabase.instance.client;

  List<FixedExpenseModel> _fixedExpenses = [];

  List<FixedExpenseModel> get fixedExpenses =>
      List.unmodifiable(_fixedExpenses);

  SpendingService(this._prefs) {
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Carrega local
    final String? localData = _prefs.getString(_localKey);
    if (localData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(localData);
        _fixedExpenses =
            decoded.map((e) => FixedExpenseModel.fromJson(e)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Erro ao carregar gastos fixos locais: $e');
      }
    }

    // 2. Tenta carregar da nuvem
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
          _fixedExpenses =
              expensesJson.map((e) => FixedExpenseModel.fromJson(e)).toList();
          await _saveLocal();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar gastos fixos com nuvem (load): $e');
    }
  }

  Future<void> _saveLocal() async {
    final encoded = jsonEncode(_fixedExpenses.map((e) => e.toJson()).toList());
    await _prefs.setString(_localKey, encoded);
  }

  Future<void> _saveCloud() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final cloudData = {
        'fixed_expenses': _fixedExpenses.map((e) => e.toJson()).toList(),
      };

      await _supabase.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': cloudData,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id, module_id');
    } catch (e) {
      debugPrint('Erro ao sincronizar gastos fixos com nuvem (save): $e');
    }
  }

  Future<void> addFixedExpense(FixedExpenseModel expense) async {
    _fixedExpenses.add(expense);
    await _saveLocal();
    await _saveCloud();
    await _scheduleNotification(expense);
    notifyListeners();
  }

  Future<void> updateFixedExpense(FixedExpenseModel updatedExpense) async {
    final index = _fixedExpenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _fixedExpenses[index] = updatedExpense;
      await _saveLocal();
      await _saveCloud();
      await _scheduleNotification(updatedExpense);
      notifyListeners();
    }
  }

  Future<void> deleteFixedExpense(String id) async {
    _fixedExpenses.removeWhere((e) => e.id == id);
    await _saveLocal();
    await _saveCloud();
    await _cancelNotification(id);
    notifyListeners();
  }

  Future<void> togglePaid(String id) async {
    final index = _fixedExpenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      final expense = _fixedExpenses[index];
      final newStatus = !expense.isPaid;
      _fixedExpenses[index] = expense.copyWith(
        isPaid: newStatus,
        lastPaid: newStatus ? DateTime.now() : null,
      );
      await _saveLocal();
      await _saveCloud();
      notifyListeners();
    }
  }

  Future<void> _scheduleNotification(FixedExpenseModel expense) async {
    final int notifyId = expense.id.hashCode.abs() % 10000;
    await _cancelNotification(expense.id);

    if (!expense.notificationsEnabled) return;

    // Simplificado: Notificar no dia do vencimento às 09:00 AM
    // TZDateTime vai lidar com meses mais curtos automaticamente
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
