import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';

class SmokingTriggersScreen extends ConsumerStatefulWidget {
  const SmokingTriggersScreen({super.key});

  @override
  ConsumerState<SmokingTriggersScreen> createState() => _SmokingTriggersScreenState();
}

class _SmokingTriggersScreenState extends ConsumerState<SmokingTriggersScreen> {
  int _selectedFilterDays = 30; // 7, 30, 0 (todos)
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final cravingService = ref.read(smokingCravingServiceProvider);
    final data = await cravingService.getTriggerAnalytics(days: _selectedFilterDays);

    if (mounted) {
      setState(() {
        _analytics = data;
        _isLoading = false;
      });
    }
  }

  void _changeFilter(int days) {
    if (_selectedFilterDays == days) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedFilterDays = days;
    });
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final total = (_analytics['total'] as num?)?.toInt() ?? 0;
    final overcomeCount = (_analytics['overcomeCount'] as num?)?.toInt() ?? 0;
    final overcomeRate = (_analytics['overcomeRate'] as num?)?.toDouble() ?? 0.0;
    final triggerRanking = (_analytics['triggerRanking'] as Map<String, int>?) ?? {};
    final hourlyDistribution = (_analytics['hourlyDistribution'] as Map<int, int>?) ?? {};
    final topTrigger = _analytics['topTrigger'] as String?;
    final peakHourInterval = _analytics['peakHourInterval'] as String?;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Gatilhos e Padrões'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Seletor de Período
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFilterTab(
                              label: '7 Dias',
                              isSelected: _selectedFilterDays == 7,
                              onTap: () => _changeFilter(7),
                            ),
                          ),
                          Expanded(
                            child: _buildFilterTab(
                              label: '30 Dias',
                              isSelected: _selectedFilterDays == 30,
                              onTap: () => _changeFilter(30),
                            ),
                          ),
                          Expanded(
                            child: _buildFilterTab(
                              label: 'Tudo',
                              isSelected: _selectedFilterDays == 0,
                              onTap: () => _changeFilter(0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (total == 0) ...[
                      // Empty State
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.insights_rounded,
                                size: 36,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum registro de vontade ainda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sempre que sentir vontade de fumar, toque no botão "SOS Vontade". '
                              'O app registrará o gatilho e a hora para mapear seus padrões de comportamento.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: colorScheme.onSurface.withValues(alpha: 0.65),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Card Resumo Geral
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4F46E5),
                              Color(0xFF6366F1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('Crises Enfrentadas', '$total', Icons.local_fire_department_rounded),
                            Container(
                              width: 1,
                              height: 36,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            _buildStatColumn('Superadas', '$overcomeCount', Icons.check_circle_rounded),
                            Container(
                              width: 1,
                              height: 36,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            _buildStatColumn('Taxa de Sucesso', '${(overcomeRate * 100).toStringAsFixed(0)}%', Icons.emoji_events_rounded),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Card de Insight Comportamental
                      if (topTrigger != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_rounded,
                                color: Color(0xFFF59E0B),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Padrão Identificado',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      peakHourInterval != null
                                          ? 'Seu momento mais desafiador costuma ocorrer por volta das $peakHourInterval, principalmente associado a "$topTrigger".'
                                          : 'Seu principal gatilho registrado é "$topTrigger". Planeje atividades alternativas para esse momento.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Ranking de Gatilhos
                      Text(
                        'Principais Gatilhos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: triggerRanking.entries.map((entry) {
                            final count = entry.value;
                            final percentage = total > 0 ? (count / total) : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '$count (${(percentage * 100).toStringAsFixed(0)}%)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      minHeight: 8,
                                      backgroundColor: colorScheme.outline.withValues(alpha: 0.1),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Horários de Risco
                      Text(
                        'Distribuição por Horário',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildHourlyRow('Manhã (06h - 12h)', _getHourRangeSum(hourlyDistribution, 6, 11), total),
                            const Divider(height: 16),
                            _buildHourlyRow('Tarde (12h - 18h)', _getHourRangeSum(hourlyDistribution, 12, 17), total),
                            const Divider(height: 16),
                            _buildHourlyRow('Noite (18h - 00h)', _getHourRangeSum(hourlyDistribution, 18, 23), total),
                            const Divider(height: 16),
                            _buildHourlyRow('Madrugada (00h - 06h)', _getHourRangeSum(hourlyDistribution, 0, 5), total),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }

  int _getHourRangeSum(Map<int, int> distribution, int startHour, int endHour) {
    int sum = 0;
    for (int h = startHour; h <= endHour; h++) {
      sum += distribution[h] ?? 0;
    }
    return sum;
  }

  Widget _buildHourlyRow(String label, int count, int total) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = total > 0 ? (count / total) : 0.0;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

