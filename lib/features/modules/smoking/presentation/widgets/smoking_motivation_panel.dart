import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/presentation/controllers/stop_smoking_controller.dart';

/// Widget de painel motivacional do Smoking
class SmokingMotivationPanel extends ConsumerWidget {
  const SmokingMotivationPanel({super.key});

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

    return Column(
      children: [
        Text(
          'Motivação Diária',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildMilestoneList(daysWithoutSmoking),
        const SizedBox(height: 24),
        Text(
          'Dica do Dia:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getMotivationalTip(daysWithoutSmoking),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _getMotivationalTip(int days) {
    if (days < 7) return 'Lembre-se: cada dia sem fumar é uma vitória!';
    if (days < 30) return 'Beba bastante água para ajudar na desintoxicação!';
    if (days < 90) return 'Evite situações de risco nos primeiros meses!';
    if (days < 180) return 'Seu paladar já está melhorando!';
    return 'Você está transformando sua vida. Parabéns!';
  }

  Widget _buildMilestoneList(int days) {
    final milestones = [
      {'days': 7, 'title': '1 Semana', 'icon': '🏆', 'value': '7'},
      {'days': 30, 'title': '1 Mês', 'icon': '🎖', 'value': '30'},
      {'days': 90, 'title': '3 Meses', 'icon': '🏅', 'value': '90'},
      {'days': 180, 'title': '6 Meses', 'icon': '🏆', 'value': '180'},
      {'days': 365, 'title': '1 Ano', 'icon': '🏆', 'value': '365'},
    ];

    return Column(
      children: milestones.map((milestone) {
        final achieved = days >= (milestone['days'] as int);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                milestone['icon'] as String,
                style: TextStyle(
                  fontSize: 20,
                  color: achieved ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  milestone['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: achieved ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
              if (achieved)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
