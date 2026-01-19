import 'package:flutter/material.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';

/// Versão compacta do HealthTimelineCard para exibição ao lado do SavingsDashboard
class HealthCompactCard extends StatelessWidget {
  final SmokingSettingsModel settings;
  final VoidCallback? onTap;

  const HealthCompactCard({
    super.key,
    required this.settings,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration = settings.timeSmokeFree;

    // Calcula quantos milestones foram alcançados
    final milestones = [
      Duration(minutes: 20),
      Duration(hours: 24),
      Duration(hours: 48),
      Duration(hours: 72),
      Duration(days: 14),
      Duration(days: 90),
    ];

    final reachedCount = milestones.where((m) => duration >= m).length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  "Saúde",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "$reachedCount/${milestones.length}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "marcos atingidos",
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
