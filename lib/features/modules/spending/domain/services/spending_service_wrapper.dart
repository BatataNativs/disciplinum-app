import 'package:disciplinum/features/modules/spending/domain/entities/fixed_expense_model.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service wrapper para manter consistência com outros módulos
class SpendingService {
  final Ref _ref;
  
  SpendingService(this._ref);
  
  /// Obtém todas as despesas fixas
  List<FixedExpenseModel> get expenses => _ref.read(spendingProvider).value ?? [];
  
  /// Obtém o total mensal de despesas
  double get totalMonthly => expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  
  /// Obtém o número de despesas ativas
  int get activeExpensesCount => expenses.where((e) => !e.isPaid).length;
  
  /// Verifica se há despesas vencendo hoje
  List<FixedExpenseModel> get dueToday {
    final now = DateTime.now();
    return expenses.where((e) => 
      !e.isPaid && 
      e.dueDay == now.day
    ).toList();
  }
  
  /// Adiciona uma nova despesa fixa
  Future<void> addExpense(FixedExpenseModel expense) async {
    final notifier = _ref.read(spendingProvider.notifier);
    await notifier.addFixedExpense(expense);
  }
  
  /// Atualiza uma despesa existente
  Future<void> updateExpense(FixedExpenseModel expense) async {
    final notifier = _ref.read(spendingProvider.notifier);
    await notifier.updateFixedExpense(expense);
  }
  
  /// Remove uma despesa
  Future<void> removeExpense(String id) async {
    final notifier = _ref.read(spendingProvider.notifier);
    await notifier.deleteFixedExpense(id);
  }
  
  /// Força sincronização com nuvem
  Future<void> syncWithCloud() async {
    // Força reload dos dados para sincronização
    _ref.invalidate(spendingProvider);
  }
  
  /// Limpa todas as despesas (reset completo)
  Future<void> clearAllExpenses() async {
    final notifier = _ref.read(spendingProvider.notifier);
    final allExpenses = expenses;
    for (final expense in allExpenses) {
      await notifier.deleteFixedExpense(expense.id);
    }
  }
}
