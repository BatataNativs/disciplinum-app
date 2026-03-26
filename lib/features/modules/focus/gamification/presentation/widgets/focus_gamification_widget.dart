import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/focus/gamification/presentation/controllers/focus_gamification_controller.dart';
import 'package:disciplinum/features/modules/focus/gamification/presentation/providers/focus_gamification_provider.dart';

/// Widget que exibe a gamificação do módulo Focus
class FocusGamificationWidget extends ConsumerWidget {
  const FocusGamificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(focusGamificationControllerProvider);
    final gamificationState = ref.watch(focusGamificationStateProvider);

    return gamificationState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro: $error', style: TextStyle(color: Colors.red)),
      ),
      data: (state) => _buildGamificationContent(context, ref, controller, state),
    );
  }

  Widget _buildGamificationContent(
    BuildContext context,
    WidgetRef ref,
    FocusGamificationController controller,
    Map<String, dynamic> state,
  ) {
    return Column(
      children: [
        // Progresso geral
        _buildProgressCard(context, controller),
        const SizedBox(height: 16),
        
        // Insígnias conquistadas
        _buildInsigniasSection(context, ref, controller),
        const SizedBox(height: 16),
        
        // Medalhas conquistadas
        _buildMedalhasSection(context, ref, controller),
        const SizedBox(height: 16),
        
        // Ações
        _buildActionsSection(context, controller),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, FocusGamificationController controller) {
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
              value: controller.progressPercentage,
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
                  '${controller.respectedPeriods} períodos respeitados',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(controller.progressPercentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (controller.nextInsignia != null) ...[
              const SizedBox(height: 8),
              Text(
                'Próxima: ${controller.getInsigniaInfo(controller.nextInsignia!)['name']}',
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

  Widget _buildInsigniasSection(BuildContext context, WidgetRef ref, FocusGamificationController controller) {
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
            if (controller.earnedInsignias.isEmpty)
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
                children: controller.earnedInsignias.map((insigniaId) {
                  final info = controller.getInsigniaInfo(insigniaId);
                  return _buildInsigniaChip(context, info);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsigniaChip(BuildContext context, Map<String, String> info) {
    return Tooltip(
      message: info['requirement']!,
      child: Chip(
        avatar: Image.asset(
          info['asset']!,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stack) => const Icon(Icons.emoji_events),
        ),
        label: Text(info['name']!),
      ),
    );
  }

  Widget _buildMedalhasSection(BuildContext context, WidgetRef ref, FocusGamificationController controller) {
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
            if (controller.earnedMedalhas.isEmpty)
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
                children: controller.earnedMedalhas.map((medalhaId) {
                  final info = controller.getMedalhaInfo(medalhaId);
                  return _buildMedalhaChip(context, info);
                }).toList(),
              ),
            
            // Contador de Disciplinum
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.military_tech, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Disciplinum: ${controller.disciplinumCount}/4',
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

  Widget _buildMedalhaChip(BuildContext context, Map<String, String> info) {
    return Tooltip(
      message: info['requirement']!,
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
        label: Text(info['name']!),
        backgroundColor: Colors.amber.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, FocusGamificationController controller) {
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
                  onPressed: controller.isLoading ? null : () async {
                    await controller.addRespectedPeriod();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Período Respeitado'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.isLoading ? null : () async {
                    await controller.failPeriod();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Falhar Período'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (controller.canAwardDisciplinum)
                  ElevatedButton.icon(
                    onPressed: controller.isLoading ? null : () async {
                      final awarded = await controller.tryAwardDisciplinum();
                      if (awarded && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Nova insígnia Disciplinum concedida!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('Conceder Disciplinum'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: controller.isLoading ? null : () async {
                    await controller.resetProgress();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Progresso resetado')),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Resetar Progresso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
