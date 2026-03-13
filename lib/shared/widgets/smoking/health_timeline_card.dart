import 'package:flutter/material.dart';

/// Widget para exibir timeline de saúde do fumante
/// Widget reutilizável para módulos de parar de fumar
class HealthTimelineCard extends StatelessWidget {
  final int daysWithoutSmoking;
  final String? customTitle;

  const HealthTimelineCard({
    super.key,
    required this.daysWithoutSmoking,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customTitle ?? 'Benefícios para a Saúde',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildHealthMilestones(context, daysWithoutSmoking),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMilestones(BuildContext context, int days) {
    final milestones = _getHealthMilestones(days);
    
    return Column(
      children: milestones.map((milestone) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: milestone.achieved 
                      ? Colors.green 
                      : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  milestone.achieved ? Icons.check : Icons.hourglass_empty,
                  color: milestone.achieved ? Colors.white : Colors.grey,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: milestone.achieved
                            ? Colors.green
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white70 
                                : Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      milestone.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<HealthMilestone> _getHealthMilestones(int days) {
    return [
      HealthMilestone(
        days: 0,
        title: '20 minutos',
        description: 'Pressão arterial e pulso normalizam',
        achieved: days >= 0,
      ),
      HealthMilestone(
        days: 1,
        title: '12 horas',
        description: 'Nível de monóxido de carbono no sangue normaliza',
        achieved: days >= 1,
      ),
      HealthMilestone(
        days: 2,
        title: '2 dias',
        description: 'Nicotina eliminada do corpo',
        achieved: days >= 2,
      ),
      HealthMilestone(
        days: 3,
        title: '3 dias',
        description: 'Melhora na respiração',
        achieved: days >= 3,
      ),
      HealthMilestone(
        days: 14,
        title: '2 semanas',
        description: 'Melhora na circulação',
        achieved: days >= 14,
      ),
      HealthMilestone(
        days: 30,
        title: '1 mês',
        description: 'Tosse e falta de ar diminuem',
        achieved: days >= 30,
      ),
      HealthMilestone(
        days: 90,
        title: '3 meses',
        description: 'Função pulmonar melhora 30%',
        achieved: days >= 90,
      ),
      HealthMilestone(
        days: 365,
        title: '1 ano',
        description: 'Risco de doença cardíaca reduz pela metade',
        achieved: days >= 365,
      ),
    ];
  }
}

class HealthMilestone {
  final int days;
  final String title;
  final String description;
  final bool achieved;

  HealthMilestone({
    required this.days,
    required this.title,
    required this.description,
    required this.achieved,
  });
}
