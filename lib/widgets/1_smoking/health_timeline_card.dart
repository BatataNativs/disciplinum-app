import 'package:flutter/material.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';

class HealthTimelineCard extends StatelessWidget {
  final SmokingSettingsModel settings;

  const HealthTimelineCard({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final duration = settings.timeSmokeFree;

    // Definição dos marcos de saúde
    final milestones = [
      {
        'title': 'Pressão arterial normal',
        'duration': Duration(minutes: 20),
        'icon': Icons.favorite
      },
      {
        'title': 'Sem monóxido de carbono',
        'duration': Duration(hours: 24),
        'icon': Icons.air
      },
      {
        'title': 'Olfato e paladar melhoram',
        'duration': Duration(hours: 48),
        'icon': Icons.restaurant
      },
      {
        'title': 'Respiração mais fácil',
        'duration': Duration(hours: 72),
        'icon': Icons.self_improvement
      },
      {
        'title': 'Circulação melhora',
        'duration': Duration(days: 14),
        'icon': Icons.directions_walk
      },
      {
        'title': 'Função pulmonar +10%',
        'duration': Duration(days: 90),
        'icon': Icons.health_and_safety
      }, // Use um ícone custom ou similar
    ];

    return Card(
      color: Color(0xFF1E1E2C), // Cor escura padrão do seu app
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Melhorias na Saúde",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                final milestone = milestones[index];
                final requiredDuration = milestone['duration'] as Duration;
                final isReached = duration >= requiredDuration;

                String trailingText = "Concluído";
                if (!isReached) {
                  final remaining = requiredDuration - duration;
                  if (remaining.inDays > 0) {
                    trailingText = "Faltam ${remaining.inDays} dias";
                    if (remaining.inHours % 24 > 0) {
                      trailingText += " e ${remaining.inHours % 24}h";
                    }
                  } else if (remaining.inHours > 0) {
                    trailingText = "Faltam ${remaining.inHours}h";
                  } else {
                    trailingText = "Faltam ${remaining.inMinutes}min";
                  }
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isReached
                        ? Colors.green
                        : Colors.grey.withValues(alpha: 0.3),
                    child: Icon(milestone['icon'] as IconData,
                        color: Colors.white, size: 20),
                  ),
                  title: Text(
                    milestone['title'] as String,
                    style: TextStyle(
                      color: isReached ? Colors.white : Colors.grey,
                      decoration: isReached ? null : TextDecoration.none,
                    ),
                  ),
                  trailing: isReached
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 16)
                      : Text(trailingText,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
