import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Dialog para desativar módulos com confirmação
/// Widget reutilizável para todos os módulos do app
class DeactivateModuleDialog extends ConsumerWidget {
  final NicheId nicheId;
  final String? customMessage;
  final VoidCallback? onDeactivated;

  const DeactivateModuleDialog({
    super.key,
    required this.nicheId,
    this.customMessage,
    this.onDeactivated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final niche = NicheRepository.getById(nicheId);
    
    return AlertDialog(
      title: Text('Desativar ${niche.name}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customMessage ?? 
            'Tem certeza que deseja desativar o módulo ${niche.name}?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.red[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ Atenção: Esta ação não pode ser desfeita!',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await ref.read(gamificationServiceProvider).resetMedals(
              nicheId,
              notificationTitle: '${niche.name}: Módulo Desativado',
              notificationBody: 'Seu progresso foi reiniciado.',
              iconPath: niche.iconPath,
              deactivate: true,
            );
            onDeactivated?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('DESATIVAR'),
        ),
      ],
    );
  }

  /// Método estático para mostrar o dialog
  static Future<bool> show({
    required BuildContext context,
    required NicheId nicheId,
    String? customMessage,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeactivateModuleDialog(
        nicheId: nicheId,
        customMessage: customMessage,
      ),
    );
    return result ?? false;
  }

  /// Método alternativo que aceita o serviço como parâmetro
  static Future<bool> showWithService({
    required BuildContext context,
    required GamificationService gamificationService,
    required NicheId nicheId,
    String? customMessage,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _DeactivateModuleDialogWithService(
        nicheId: nicheId,
        customMessage: customMessage,
        gamificationService: gamificationService,
      ),
    );
    return result ?? false;
  }
}

/// Versão do diálogo que recebe o serviço diretamente
class _DeactivateModuleDialogWithService extends StatelessWidget {
  final NicheId nicheId;
  final String? customMessage;
  final GamificationService gamificationService;

  const _DeactivateModuleDialogWithService({
    required this.nicheId,
    this.customMessage,
    required this.gamificationService,
  });

  @override
  Widget build(BuildContext context) {
    final niche = NicheRepository.getById(nicheId);
    
    return AlertDialog(
      title: Text('Desativar ${niche.name}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customMessage ?? 
            'Tem certeza que deseja desativar o módulo ${niche.name}?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.red[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ Atenção: Esta ação não pode ser desfeita!',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await gamificationService.resetMedals(
              nicheId,
              notificationTitle: '${niche.name}: Módulo Desativado',
              notificationBody: 'Seu progresso foi reiniciado.',
              iconPath: niche.iconPath,
              deactivate: true,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('DESATIVAR'),
        ),
      ],
    );
  }
}
