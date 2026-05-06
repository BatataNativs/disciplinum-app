import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/money_saving_challenge_total_contributions.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/money_saving_challenge_about_contributions.dart';

class MoneySavingChallengeStatsScreen extends StatelessWidget {
  const MoneySavingChallengeStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Estatísticas dos Desafios'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatOption(
            context,
            title: 'Total Geral Guardado',
            subtitle: 'Soma de todos os seus desafios e conquistas',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF6366F1), // Indigo
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const MoneySavingChallengeTotalContributionsScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatOption(
            context,
            title: 'Sobre os Aportes',
            subtitle: 'Análise de frequência e valores mais comuns',
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFF10B981), // Emerald
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const MoneySavingChallengeAboutContributionsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        onTap: onTap,
      ),
    );
  }
}
