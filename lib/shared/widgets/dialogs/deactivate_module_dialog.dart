import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';

/// Interface para reset de progresso de módulos
/// Permite que cada módulo implemente sua própria lógica de reset
abstract class ModuleResetService {
  Future<void> resetProgress(int nicheId);
}

/// Dialog para desativar módulos com confirmação
/// Widget reutilizável para todos os módulos do app
class DeactivateModuleDialog extends ConsumerWidget {
  final NicheId nicheId;
  final String? customMessage;
  final VoidCallback? onDeactivated;
  final ModuleResetService? resetService;

  const DeactivateModuleDialog({
    super.key,
    required this.nicheId,
    this.customMessage,
    this.onDeactivated,
    this.resetService,
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
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
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
    ModuleResetService? resetService,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeactivateModuleDialog(
        nicheId: nicheId,
        customMessage: customMessage,
        resetService: resetService,
      ),
    );
    return result ?? false;
  }
}
