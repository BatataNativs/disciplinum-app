import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';

/// Dialog para desativar módulos com confirmação
/// Widget reutilizável para todos os módulos do app
class DeactivateModuleDialog extends StatelessWidget {
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
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Todo o seu progresso será perdido!',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
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
            await context.read<GamificationService>().resetMedals(
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
}
