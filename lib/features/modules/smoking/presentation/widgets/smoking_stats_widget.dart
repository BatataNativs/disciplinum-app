import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/presentation/controllers/stop_smoking_controller.dart';

/// Widget de estatísticas do Smoking
class SmokingStatsWidget extends ConsumerWidget {
  const SmokingStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(stopSmokingControllerProvider);

    if (currentState.smokingData == null) {
      return const SizedBox.shrink();
    }

    final smokingData = currentState.smokingData!;
    final daysWithoutSmoking = smokingData.quitDate != null
        ? DateTime.now().difference(smokingData.quitDate!).inDays
        : 0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas Detalhadas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Saúde melhorada
            _buildStatItem(
              '🫁',
              'Pressão Arterial Reduzida',
              _calculateHealthBenefit(daysWithoutSmoking),
              Colors.green,
            ),
            
            // Capacidade pulmonar
            _buildStatItem(
              '🫁',
              'Capacidade Pulmonar Melhorada',
              '+${_calculateLungCapacity(daysWithoutSmoking)}%',
              Colors.blue,
            ),
            
            // Risco reduzido
            _buildStatItem(
              '💓',
              'Risco de Câncer Reduzido',
              '-${_calculateCancerRiskReduction(daysWithoutSmoking)}%',
              Colors.orange,
            ),
            
            // Vidas salvas
            _buildStatItem(
              '💪',
              'Dias de Vida Ganhos',
              _calculateDaysGained(daysWithoutSmoking),
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateHealthBenefit(int days) {
    // Cálculo simplificado de benefício à saúde
    if (days < 30) return 'Início';
    if (days < 90) return 'Leve';
    if (days < 180) return 'Moderado';
    if (days < 365) return 'Significativo';
    return 'Excelente';
  }

  String _calculateLungCapacity(int days) {
    // Cálculo simplificado de recuperação pulmonar
    final recoveryRate = (days / 365.0) * 0.1; // 10% por ano
    return (recoveryRate * 100).toStringAsFixed(0);
  }

  String _calculateCancerRiskReduction(int days) {
    // Cálculo simplificado de redução de risco
    final riskReduction = (days / 365.0) * 0.05; // 5% por ano
    return (riskReduction * 100).toStringAsFixed(0);
  }

  String _calculateDaysGained(int days) {
    // Cálculo simplificado de dias ganhos
    return (days * 0.8).toStringAsFixed(0); // 80% do tempo
  }
}
