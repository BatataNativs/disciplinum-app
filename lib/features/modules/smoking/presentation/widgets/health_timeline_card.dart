import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_health_benefit.dart';

class HealthTimelineCard extends StatelessWidget {
  final SmokingSettingsModel settings;
  final Duration timeSmokeFree;

  const HealthTimelineCard({
    super.key,
    required this.settings,
    required this.timeSmokeFree,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = timeSmokeFree;

    // Usar SmokingHealthBenefitEntity como fonte de verdade
    final milestones = SmokingHealthBenefitEntity.values;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Melhorias na Saúde",
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Timeline
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: milestones.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  height: 1,
                ),
              ),
              itemBuilder: (context, index) {
                final milestone = milestones[index];
                final requiredDuration = Duration(minutes: milestone.timeInMinutes);
                final isReached = duration >= requiredDuration;
                final remaining = requiredDuration - duration;

                // Formatar tempo restante
                String timeText;
                if (isReached) {
                  timeText = "✓ Concluído";
                } else {
                  if (remaining.inDays > 0) {
                    timeText = "Faltam ${remaining.inDays}d";
                    if (remaining.inHours % 24 > 0) {
                      timeText += " ${remaining.inHours % 24}h";
                    }
                  } else if (remaining.inHours > 0) {
                    timeText = "Faltam ${remaining.inHours}h";
                    if (remaining.inMinutes % 60 > 0) {
                      timeText += " ${remaining.inMinutes % 60}min";
                    }
                  } else {
                    timeText = "Faltam ${remaining.inMinutes}min";
                  }
                }

                // Cor do tema
                final themeColor = Color(
                  int.parse(milestone.themeColor.replaceFirst('#', '0xFF')),
                );

                return Row(
                  children: [
                    // Ícone/Status
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isReached
                            ? themeColor.withValues(alpha: 0.2)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isReached
                              ? themeColor
                              : colorScheme.outline.withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isReached ? Icons.check_circle : Icons.circle_outlined,
                        color: isReached ? themeColor : Colors.grey,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Conteúdo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.notificationTitle.replaceAll(' 🎊', ''),
                            style: TextStyle(
                              color: isReached
                                  ? colorScheme.onSurface
                                  : Colors.grey,
                              fontSize: 15,
                              fontWeight: isReached
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            milestone.timeRequired,
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isReached
                            ? themeColor.withValues(alpha: 0.15)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isReached
                              ? themeColor.withValues(alpha: 0.5)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        timeText,
                        style: TextStyle(
                          color: isReached
                              ? themeColor
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
