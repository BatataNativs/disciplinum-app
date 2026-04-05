import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/focus/gamification/presentation/providers/focus_gamification_provider.dart';
import 'package:disciplinum/features/modules/focus/presentation/notifiers/focus_gamification_notifier.dart';

/// Widget que exibe a gamificação do módulo Focus
class FocusGamificationWidget extends ConsumerWidget {
  const FocusGamificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusGamificationNotifierProvider);
    final notifier = ref.watch(focusGamificationNotifierProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text('Erro: ${state.error}', style: const TextStyle(color: Colors.red)),
      );
    }

    return _buildGamificationContent(context, ref, state, notifier);
  }

  Widget _buildGamificationContent(
    BuildContext context,
    WidgetRef ref,
    FocusGamificationState state,
    FocusGamificationNotifier notifier,
  ) {
    return Column(
      children: [
        // Progresso geral
        _buildProgressCard(context, state),
        const SizedBox(height: 16),
        
        // Insígnias conquistadas
        _buildInsigniasSection(context, ref, state, notifier),
        const SizedBox(height: 16),
        
        // Medalhas conquistadas
        _buildMedalhasSection(context, ref, state, notifier),
        const SizedBox(height: 16),
        
        // Ações
        _buildActionsSection(context, notifier),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, FocusGamificationState state) {
    final progress = state.currentStreak > 0 ? (state.currentStreak % 10) / 10 : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso de Foco',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.currentStreak} dias consecutivos',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (state.totalFocusMinutes > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Total: ${state.totalFocusMinutes} minutos focados',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsigniasSection(BuildContext context, WidgetRef ref, FocusGamificationState state, FocusGamificationNotifier notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insígnias Conquistadas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (state.earnedInsignias.isEmpty)
              Text(
                'Nenhuma insígnia conquistada ainda',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.earnedInsignias.map((insigniaId) {
                  return _buildInsigniaChip(context, insigniaId);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsigniaChip(BuildContext context, String insigniaId) {
    return Chip(
      avatar: const Icon(Icons.emoji_events, size: 20),
      label: Text(insigniaId),
    );
  }

  Widget _buildMedalhasSection(BuildContext context, WidgetRef ref, FocusGamificationState state, FocusGamificationNotifier notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medalhas Conquistadas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (state.earnedMedalhas.isEmpty)
              Text(
                'Nenhuma medalha conquistada ainda',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.earnedMedalhas.map((medalhaId) {
                  return _buildMedalhaChip(context, medalhaId);
                }).toList(),
              ),
            
            // Contador de Disciplinum
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.military_tech, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Disciplinum: ${state.gamification?.disciplinumCount ?? 0}/4',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedalhaChip(BuildContext context, String medalhaId) {
    return Tooltip(
      message: medalhaId,
      child: Chip(
        avatar: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.star, color: Colors.white, size: 16),
        ),
        label: Text(medalhaId),
        backgroundColor: Colors.amber.withAlpha(25),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, FocusGamificationNotifier notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    // Registra sessão de foco de 25 minutos (pomodoro padrão)
                    final achievementUnlocked = await notifier.recordFocusSession(25);
                    if (achievementUnlocked && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Nova conquista desbloqueada!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Foco'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    notifier.resetProgress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Progresso resetado')),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Resetar Progresso'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
