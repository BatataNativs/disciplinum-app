import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/controllers/money_saving_challenge_controller.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';

/// Widget de barra de ações do desafio de poupança
class SavingsActionsWidget extends ConsumerWidget {
  const SavingsActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ações',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showEditChallengeDialog(context, ref);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Editar Desafio'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(moneySavingChallengeControllerProvider.notifier).loadChallengeData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Recarregar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showResetConfirmationDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Resetar Dados'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditChallengeDialog(BuildContext context, WidgetRef ref) {
    final challengeState = ref.watch(moneySavingChallengeControllerProvider);
    final currentChallenge = challengeState.challengeData;

    if (currentChallenge == null) {
      EnhancedSnackBarHelper.showWarning(context, 'Nenhum desafio ativo encontrado');
      return;
    }

    final titleController = TextEditingController(text: currentChallenge.title);
    final targetController = TextEditingController(text: currentChallenge.targetAmount.toString());
    final minValueController = TextEditingController(text: currentChallenge.minValue.toString());
    final maxValueController = TextEditingController(text: currentChallenge.maxValue.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Desafio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do Desafio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor Alvo (R\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor Mínimo (R\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: maxValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor Máximo (R\$)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final updatedChallenge = MoneySavingChallengeModel(
                  id: currentChallenge.id,
                  title: titleController.text,
                  targetAmount: double.parse(targetController.text),
                  periodValue: currentChallenge.periodValue,
                  periodType: currentChallenge.periodType,
                  gridSize: currentChallenge.gridSize,
                  minValue: double.parse(minValueController.text),
                  maxValue: double.parse(maxValueController.text),
                  markedCells: currentChallenge.markedCells,
                  cellValues: currentChallenge.cellValues,
                  createdAt: currentChallenge.createdAt,
                  currency: currentChallenge.currency,
                  isActive: currentChallenge.isActive,
                  notifFrequency: currentChallenge.notifFrequency,
                  notifTime: currentChallenge.notifTime,
                  notifDayOfWeek: currentChallenge.notifDayOfWeek,
                  notifDayOfMonth: currentChallenge.notifDayOfMonth,
                );

                await ref.read(moneySavingChallengeControllerProvider.notifier)
                    .saveChallengeSettings(updatedChallenge);

                if (context.mounted) {
                  Navigator.pop(context);
                  EnhancedSnackBarHelper.showSuccess(context, 'Desafio atualizado com sucesso!');
                }
              } catch (e) {
                if (context.mounted) {
                  EnhancedSnackBarHelper.showError(context, 'Erro ao salvar desafio: $e');
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Dados'),
        content: const Text(
          'Tem certeza que deseja resetar todos os dados do desafio? '
          'Esta ação não pode ser desfeita e apagará todo o seu progresso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(moneySavingChallengeControllerProvider.notifier)
                    .resetChallengeData();

                if (context.mounted) {
                  Navigator.pop(context);
                  EnhancedSnackBarHelper.showWarning(context, 'Dados resetados com sucesso');
                }
              } catch (e) {
                if (context.mounted) {
                  EnhancedSnackBarHelper.showError(context, 'Erro ao resetar dados: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }
}
