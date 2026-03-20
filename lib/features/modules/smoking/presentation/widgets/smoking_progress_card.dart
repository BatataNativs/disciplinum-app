import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/presentation/controllers/stop_smoking_controller.dart';

/// Widget de card de progresso do Smoking
class SmokingProgressCard extends ConsumerWidget {
  const SmokingProgressCard({super.key});

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

    final moneySaved = smokingData.quitDate != null
        ? (smokingData.packPrice * smokingData.packsPerDay * daysWithoutSmoking)
        : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu Progresso',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Dias sem fumar
            _buildProgressItem(
              context,
              '🚭',
              'Dias sem Fumar',
              '$daysWithoutSmoking',
              Colors.green,
            ),
            
            // Dinheiro economizado
            _buildProgressItem(
              context,
              '💰',
              'Economizado',
              'R\$ ${moneySaved.toStringAsFixed(2)}',
              Colors.blue,
            ),
            
            // Maços por dia
            _buildProgressItem(
              context,
              '📦',
              'Maços por Dia',
              '${smokingData.packsPerDay}',
              Colors.orange,
            ),
            
            // Preço por maço
            _buildProgressItem(
              context,
              '💵',
              'Preço por Maço',
              'R\$ ${smokingData.packPrice.toStringAsFixed(2)}',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
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
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
