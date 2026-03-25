import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/money_saving_challenge_stats.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/my_progress_money_saving_challenge.dart' as money_saving_progress;
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';

class MoneySavingActionsWidget extends StatelessWidget {
  final MoneySavingChallengeModel? challenge;
  final bool isDark;
  final VoidCallback onShowChallengesList;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowStatistics;
  final VoidCallback onToggleModule;

  const MoneySavingActionsWidget({
    super.key,
    required this.challenge,
    required this.isDark,
    required this.onShowChallengesList,
    required this.onShowNotifications,
    required this.onShowStatistics,
    required this.onToggleModule,
  });

  @override
  Widget build(BuildContext context) {
    bool hasChallenge = challenge != null;
    bool isActive = challenge?.isActive ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
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
                  isDark: isDark,
                  onTap: onShowChallengesList,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  isDark: isDark,
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
                  isDark: isDark,
                  onTap: onShowStatistics,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: isActive ? Icons.power_settings_new : Icons.power_off,
                  label: isActive ? 'Desativar módulo' : 'Ativar módulo',
                  color: isActive ? Colors.red : Colors.green,
                  isDark: isDark,
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
  final bool isDark;

  const MoneySavingStatisticsMenu({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
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
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ListActionTile(
            icon: Icons.analytics_rounded,
            label: 'Estatísticas dos Desafios',
            color: const Color(0xFF10B981), // Emerald
            isDark: isDark,
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
            isDark: isDark,
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
