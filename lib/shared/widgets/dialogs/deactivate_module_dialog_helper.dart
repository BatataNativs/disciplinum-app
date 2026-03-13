import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'deactivate_module_dialog.dart';

/// Helper para facilitar migração das chamadas antigas do DeactivateModuleDialog
/// Mantém compatibilidade while migrando para nova API
class DeactivateModuleDialogHelper {
  /// Método legacy para compatibilidade - redireciona para nova API
  static Future<bool> showLegacy(
    BuildContext context,
    String content, {
    NicheId? nicheId,
  }) async {
    // Se nicheId não foi fornecido, tenta inferir do contexto ou usa padrão
    final targetNicheId = nicheId ?? NicheId.smoking; // Padrão para legado
    
    return await DeactivateModuleDialog.show(
      context: context,
      nicheId: targetNicheId,
      customMessage: content,
    );
  }
}
