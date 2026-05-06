import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/fixed_expense_model.dart';

class FixedBillsStatsScreen extends ConsumerStatefulWidget {
  const FixedBillsStatsScreen({super.key});

  @override
  ConsumerState<FixedBillsStatsScreen> createState() => _FixedBillsStatsScreenState();
}

class _FixedBillsStatsScreenState extends ConsumerState<FixedBillsStatsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMonth = DateFormat('MMMM', 'pt_BR').format(DateTime.now());
    final currentMonthCapitalized = currentMonth[0].toUpperCase() + currentMonth.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas de Contas Pagas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: colorScheme.surface,
        child: SafeArea(
          child: Builder(
            builder: (context) {
              final asyncExpenses = ref.watch(spendingProvider);
              
              return asyncExpenses.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erro: $err')),
                data: (expenses) {
                  final monthlyStats = _calculateMonthlyStats(expenses);
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seção de contas do mês atual
                        _buildCurrentMonthSection(expenses, currentMonthCapitalized),
                        const SizedBox(height: 32),
                        
                        // Gráfico de barras
                        _buildMonthlyChart(monthlyStats),
                        const SizedBox(height: 24),
                        
                        // Mensagem motivacional
                        _buildMotivationalMessage(),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentMonthSection(List<FixedExpenseModel> expenses, String month) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contas de $month:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (expenses.where((e) => _isPaidInCurrentMonth(e)).isEmpty)
            Text(
              'Nenhuma conta paga neste mês ainda.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            )
          else
            ...expenses
                .where((e) => _isPaidInCurrentMonth(e))
                .map((expense) => _buildExpenseItem(expense)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(FixedExpenseModel expense) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPaidThisMonth = _isPaidInCurrentMonth(expense);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${expense.name} - Venc. dia ${expense.dueDay.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                fontWeight: isPaidThisMonth ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(spendingProvider.notifier).togglePaid(expense.id);
              HapticFeedback.lightImpact();
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPaidThisMonth ? Colors.green : Colors.grey,
                  width: 2,
                ),
                color: isPaidThisMonth ? Colors.green : Colors.transparent,
              ),
              child: isPaidThisMonth
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(Map<String, MonthlyStats> monthlyStats) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histórico de Pagamentos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: monthlyStats.isEmpty
                ? Center(
                    child: Text(
                      'Sem dados históricos ainda.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : _buildStackedBarChart(monthlyStats),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildStackedBarChart(Map<String, MonthlyStats> monthlyStats) {
    final colorScheme = Theme.of(context).colorScheme;
    final months = monthlyStats.keys.toList()..sort();
    final maxValue = months.map((m) => monthlyStats[m]!.total).fold(0, (a, b) => a > b ? a : b);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: months.map((month) {
        final stats = monthlyStats[month]!;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Barra verde (pagas com >5 dias)
                      if (stats.greenCount > 0)
                        Container(
                          height: (stats.greenCount / maxValue) * 160,
                          color: const Color(0xFF2E7D32),
                        ),
                      // Barra amarela (pagas com 2-5 dias)
                      if (stats.yellowCount > 0)
                        Container(
                          height: (stats.yellowCount / maxValue) * 160,
                          color: const Color(0xFFF9A825),
                        ),
                      // Barra vermelha (pagas com 0-2 dias)
                      if (stats.redCount > 0)
                        Container(
                          height: (stats.redCount / maxValue) * 160,
                          color: const Color(0xFFC62828),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  month.substring(0, 3),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Pagas com >5 dias', const Color(0xFF2E7D32)),
        _buildLegendItem('Pagas com 2-5 dias', const Color(0xFFF9A825)),
        _buildLegendItem('Pagas com 0-2 dias', const Color(0xFFC62828)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'Pague suas contas antes do vencimento e mantenha tranquilidade e uma boa relação com seu dinheiro.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.4,
        ),
      ),
    );
  }

  bool _isPaidInCurrentMonth(FixedExpenseModel expense) {
    if (expense.lastPaid == null || !expense.isPaid) return false;
    
    final now = DateTime.now();
    final paymentDate = expense.lastPaid!;
    
    return paymentDate.year == now.year && paymentDate.month == now.month;
  }

  Map<String, MonthlyStats> _calculateMonthlyStats(List<FixedExpenseModel> expenses) {
    final Map<String, MonthlyStats> stats = {};
    
    for (final expense in expenses) {
      if (expense.lastPaid == null) continue;
      
      final paymentDate = expense.lastPaid!;
      final monthKey = DateFormat('MMM', 'pt_BR').format(paymentDate);
      
      // Calcular dias de antecedência
      final dueDate = DateTime(paymentDate.year, paymentDate.month, expense.dueDay);
      final daysBeforeDue = dueDate.difference(paymentDate).inDays;
      
      // Classificar por urgência
      UrgencyLevel urgency;
      if (daysBeforeDue > 5) {
        urgency = UrgencyLevel.green;
      } else if (daysBeforeDue >= 2) {
        urgency = UrgencyLevel.yellow;
      } else {
        urgency = UrgencyLevel.red;
      }
      
      if (!stats.containsKey(monthKey)) {
        stats[monthKey] = MonthlyStats();
      }
      
      stats[monthKey]!.addPayment(urgency);
    }
    
    return stats;
  }
}

class MonthlyStats {
  int greenCount = 0;
  int yellowCount = 0;
  int redCount = 0;
  
  int get total => greenCount + yellowCount + redCount;
  
  void addPayment(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.green:
        greenCount++;
        break;
      case UrgencyLevel.yellow:
        yellowCount++;
        break;
      case UrgencyLevel.red:
        redCount++;
        break;
    }
  }
}
