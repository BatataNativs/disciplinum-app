import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving_challenge/domain/entities/money_saving_challenge_model.dart';

class ChallengeCard extends StatelessWidget {
  final MoneySavingChallengeModel challenge;
  final bool isDark;
  final bool isActive;
  final VoidCallback onTap;
  final String Function(double, String) formatValue;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.isDark,
    required this.isActive,
    required this.onTap,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    final double completion = challenge.progressPercent;
    final int percent = (completion * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05)),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
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
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
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
                    color: isDark ? Colors.white70 : Colors.black87,
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
                            color: isDark ? Colors.white : Colors.black87,
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
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }
}
