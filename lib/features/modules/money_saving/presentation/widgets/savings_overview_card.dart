import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';

class SavingsOverviewCard extends StatelessWidget {
  final MoneySavingChallengeModel challenge;

  const SavingsOverviewCard({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Calcula progresso
    final progress = challenge.progressPercent;
    final totalSaved = challenge.totalSaved;
    final remaining = challenge.targetAmount - totalSaved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Esquerda: Porquinho e Porcentagem
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6366F1)),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('💰', style: TextStyle(fontSize: 18)),
            ],
          ),

          const SizedBox(width: 16),

          // Direita: Valores
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildValueRow(
                    'Guardado',
                    '${challenge.currency} ${totalSaved.toStringAsFixed(2)}',
                    const Color(0xFF6366F1)),
                const SizedBox(height: 8),
                _buildValueRow(
                    'Falta',
                    '${challenge.currency} ${remaining.toStringAsFixed(2)}',
                    colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(height: 8),
                _buildValueRow(
                    'Meta',
                    '${challenge.currency} ${challenge.targetAmount.toStringAsFixed(2)}',
                    colorScheme.onSurface.withValues(alpha: 0.5),
                    isSmall: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow(String label, String value, Color color,
      {bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: isSmall ? 10 : 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 12 : 16,
          ),
        ),
      ],
    );
  }
}
