import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/money_saving_challenge_stats.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/my_progress_money_saving_challenge.dart' as money_saving_progress;
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';

class MoneySavingActionsWidget extends StatelessWidget {
  final MoneySavingChallengeModel? challenge;
  final VoidCallback onShowChallengesList;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowStatistics;
  final VoidCallback onToggleModule;

  const MoneySavingActionsWidget({
    super.key,
    required this.challenge,
    required this.onShowChallengesList,
    required this.onShowNotifications,
    required this.onShowStatistics,
    required this.onToggleModule,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bool hasChallenge = challenge != null;
    bool isActive = challenge?.isActive ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ModernStartButton(
                  icon: Icons.grid_view_rounded,
                  label: 'Meus Desafios',
                  color: const Color(0xFF6366F1),
                  onTap: onShowChallengesList,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  onTap: onShowNotifications,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModernStartButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatísticas',
                  color: Colors.teal,
                  onTap: onShowStatistics,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: isActive ? Icons.power_settings_new : Icons.power_off,
                  label: isActive ? 'Desativar módulo' : 'Ativar módulo',
                  color: isActive ? Colors.red : Colors.green,
                  onTap: hasChallenge ? onToggleModule : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Crie um desafio primeiro!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MoneySavingStatisticsMenu extends StatelessWidget {
  const MoneySavingStatisticsMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          ListActionTile(
            icon: Icons.analytics_rounded,
            label: 'Estatísticas dos Desafios',
            color: const Color(0xFF10B981), // Emerald
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MoneySavingChallengeStatsScreen(),
                ),
              );
            },
          ),
          ListActionTile(
            icon: Icons.bar_chart_rounded,
            label: 'Conquistas',
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const money_saving_progress.MyProgressMoneySavingChallenge(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
