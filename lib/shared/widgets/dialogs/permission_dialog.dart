import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tipos de permissão suportados
enum PermissionType {
  notifications,
  accessibility,
  usageStats,
}

/// Dialog moderno para solicitação de permissões
class PermissionDialog extends StatelessWidget {
  final PermissionType permissionType;
  final String? customTitle;
  final String? customMessage;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onCancel;
  final String? customSettingsButtonText;
  final String? customCancelButtonText;

  const PermissionDialog({
    required this.permissionType,
    this.customTitle,
    this.customMessage,
    this.onOpenSettings,
    this.onCancel,
    this.customSettingsButtonText,
    this.customCancelButtonText,
    super.key,
  });

  /// Mostra o dialog de permissão de forma moderna
  static Future<bool?> show({
    required BuildContext context,
    required PermissionType permissionType,
    String? customTitle,
    String? customMessage,
    VoidCallback? onOpenSettings,
    VoidCallback? onCancel,
    String? customSettingsButtonText,
    String? customCancelButtonText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        permissionType: permissionType,
        customTitle: customTitle,
        customMessage: customMessage,
        onOpenSettings: onOpenSettings,
        onCancel: onCancel,
        customSettingsButtonText: customSettingsButtonText,
        customCancelButtonText: customCancelButtonText,
      ),
    );
  }

  String get _defaultTitle {
    switch (permissionType) {
      case PermissionType.notifications:
        return 'Permissão de Notificação';
      case PermissionType.accessibility:
        return 'Permissão de Acessibilidade';
      case PermissionType.usageStats:
        return 'Permissão de Estatísticas de Uso';
    }
  }

  String get _defaultMessage {
    switch (permissionType) {
      case PermissionType.notifications:
        return 'Para receber notificações do Disciplinum, habilite as notificações do app nas configurações do Android.';
      case PermissionType.accessibility:
        return 'O Disciplinum precisa de acesso à Acessibilidade para monitorar os apps.\n\nIsso permite que o app detecte quando você abre aplicativos selecionados e mostre a tela de bloqueio.';
      case PermissionType.usageStats:
        return 'O Disciplinum precisa de acesso às Estatísticas de Uso para monitorar o tempo de uso dos aplicativos.\n\nIsso permite que o app rastreie quanto tempo você passa em cada aplicativo.';
    }
  }

  IconData get _icon {
    switch (permissionType) {
      case PermissionType.notifications:
        return Icons.notifications_active_outlined;
      case PermissionType.accessibility:
        return Icons.accessibility_new_outlined;
      case PermissionType.usageStats:
        return Icons.analytics_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icone refinado
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 32,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Titulo com tipografia refinada
            Text(
              customTitle ?? _defaultTitle,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Mensagem com tipografia melhorada
            Text(
              customMessage ?? _defaultMessage,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Botoes refinados
            Row(
              children: [
                // Botao Cancelar
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context, false);
                          onCancel?.call();
                        },
                        child: Center(
                          child: Text(
                            customCancelButtonText ?? 'Cancelar',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Botao Abrir Configuracoes
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context, true);
                          onOpenSettings?.call();
                        },
                        child: Center(
                          child: Text(
                            customSettingsButtonText ?? 'Configs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
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

/// Extension para facilitar o uso do PermissionDialog
extension PermissionDialogExtension on BuildContext {
  /// Mostra dialog de permissão de notificação
  Future<bool?> showNotificationPermissionDialog({
    String? title,
    String? message,
    VoidCallback? onOpenSettings,
    VoidCallback? onCancel,
  }) {
    return PermissionDialog.show(
      context: this,
      permissionType: PermissionType.notifications,
      customTitle: title,
      customMessage: message,
      onOpenSettings: onOpenSettings,
      onCancel: onCancel,
    );
  }

  /// Mostra dialog de permissão de acessibilidade
  Future<bool?> showAccessibilityPermissionDialog({
    String? title,
    String? message,
    VoidCallback? onOpenSettings,
    VoidCallback? onCancel,
  }) {
    return PermissionDialog.show(
      context: this,
      permissionType: PermissionType.accessibility,
      customTitle: title,
      customMessage: message,
      onOpenSettings: onOpenSettings,
      onCancel: onCancel,
    );
  }

  /// Mostra dialog de permissão de estatísticas de uso
  Future<bool?> showUsageStatsPermissionDialog({
    String? title,
    String? message,
    VoidCallback? onOpenSettings,
    VoidCallback? onCancel,
  }) {
    return PermissionDialog.show(
      context: this,
      permissionType: PermissionType.usageStats,
      customTitle: title,
      customMessage: message,
      onOpenSettings: onOpenSettings,
      onCancel: onCancel,
    );
  }
}
