import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';

class ChallengeCard extends StatelessWidget {
  final MoneySavingChallengeModel challenge;
  final bool isActive;
  final VoidCallback onTap;
  final String Function(double, String) formatValue;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.isActive,
    required this.onTap,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double completion = challenge.progressPercent;
    final int percent = (completion * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.1),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gráfico de completude pequeno
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: completion,
                    strokeWidth: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isActive
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF6366F1).withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isActive)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Text('💰', style: TextStyle(fontSize: 14)),
                        ),
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${challenge.gridSize}x${challenge.gridSize} • ${formatValue(challenge.targetAmount, challenge.currency)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
