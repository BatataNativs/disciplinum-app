import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/money_saving_challenge_stats.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/my_progress_money_saving_challenge.dart' as money_saving_progress;
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
                child: ElevatedButton(
                  onPressed: onShowChallengesList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grid_view_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Meus Desafios'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onShowNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Notificações'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onShowStatistics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Estatísticas'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: hasChallenge ? onToggleModule : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Crie um desafio primeiro!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? Icons.power_settings_new : Icons.power_off,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(isActive ? 'Desativar módulo' : 'Ativar módulo'),
                    ],
                  ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas e Opções',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
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
