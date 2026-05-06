import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';
import 'package:disciplinum/shared/widgets/cards/neon_card.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/screens/completed_lists_screen.dart';

class ProcrastinationStatsScreen extends ConsumerWidget {
  const ProcrastinationStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final service = ref.watch(procrastinationServiceProvider);
    final stats = service.getCompletedTasksStats();

    final totalCompleted = stats['totalCompleted'] as int;
    final greenCount = stats['greenCount'] as int;
    final yellowCount = stats['yellowCount'] as int;
    final redCount = stats['redCount'] as int;
    final greenPercent = stats['greenPercent'] as double;
    final yellowPercent = stats['yellowPercent'] as double;
    final redPercent = stats['redPercent'] as double;
    final profile = stats['profile'] as String;
    final profileEmoji = stats['profileEmoji'] as String;
    final profileDescription = stats['profileDescription'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: colorScheme.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Perfil de Desprocrastinação
                NeonCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        profileEmoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Perfil: $profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profileDescription,
                        style: TextStyle(
                          fontSize: 15,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Gráfico de Pizza
                if (totalCompleted > 0)
                  NeonCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distribuição de Conclusão',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Em qual nível de urgência você completou suas tarefas?',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: [
                                if (greenCount > 0)
                                  PieChartSectionData(
                                    value: greenCount.toDouble(),
                                    title:
                                        '${greenPercent.toStringAsFixed(0)}%',
                                    color: UrgencyLevel.green.color,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (yellowCount > 0)
                                  PieChartSectionData(
                                    value: yellowCount.toDouble(),
                                    title:
                                        '${yellowPercent.toStringAsFixed(0)}%',
                                    color: UrgencyLevel.yellow.color,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (redCount > 0)
                                  PieChartSectionData(
                                    value: redCount.toDouble(),
                                    title: '${redPercent.toStringAsFixed(0)}%',
                                    color: UrgencyLevel.red.color,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Legenda
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLegendItem(
                              '🟢 Zen',
                              greenCount,
                              UrgencyLevel.green.color,
                              colorScheme,
                            ),
                            _buildLegendItem(
                              '🟡 Atenção',
                              yellowCount,
                              UrgencyLevel.yellow.color,
                              colorScheme,
                            ),
                            _buildLegendItem(
                              '🔴 Urgente',
                              redCount,
                              UrgencyLevel.red.color,
                              colorScheme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  NeonCard(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 64,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sem dados ainda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete algumas tarefas para ver suas estatísticas de desprocrastinação!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Cards de estatísticas
                NeonCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        'Total de tarefas concluídas',
                        '$totalCompleted',
                        Icons.check_circle_outline,
                        Colors.indigoAccent,
                        colorScheme,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Concluídas com antecedência',
                        '$greenCount (${greenPercent.toStringAsFixed(0)}%)',
                        Icons.schedule,
                        UrgencyLevel.green.color,
                        colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Concluídas em cima da hora',
                        '$yellowCount (${yellowPercent.toStringAsFixed(0)}%)',
                        Icons.warning_amber_rounded,
                        UrgencyLevel.yellow.color,
                        colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Concluídas na última hora',
                        '$redCount (${redPercent.toStringAsFixed(0)}%)',
                        Icons.alarm,
                        UrgencyLevel.red.color,
                        colorScheme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Link para Listas Concluídas
                NeonCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CompletedListsScreen(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conquistas Especiais',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Listas concluídas sem nenhum atraso',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
      String label, String value, IconData icon, Color color, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
