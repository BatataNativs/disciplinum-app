import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/core/navigation/navigation_service.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

class PermissionService {
  static bool _isChecking = false;
  static bool _shouldVerifySuccess = false;
  static DateTime? _lastCheckTime;

  static const _methodChannel =
      MethodChannel('com.disciplinum.app/accessibility_methods');

  /// Garante que as permissões de Notificação e Acessibilidade sejam verificadas.
  static Future<void> ensurePermissions(BuildContext context,
      {bool forceUsage = false, NicheId? nicheId}) async {
    final now = DateTime.now();

    if (_isChecking && !forceUsage) return;
    if (_lastCheckTime != null &&
        now.difference(_lastCheckTime!) < const Duration(seconds: 2) &&
        !forceUsage) {
      return;
    }

    _isChecking = true;
    _lastCheckTime = now;

    try {
      // 1. Notificação
      await NotificationService.requestPermission();

      // 2. Sobreposição (Fase 7) - Apenas para módulos que monitoram apps
      if (nicheId != null && await shouldRequestOverlayPermission(nicheId)) {
        if (context.mounted) {
          await ensureOverlayPermission(context);
        }
      }

      // 3. Acessibilidade (Fase 6) - Apenas para módulos que monitoram apps
      if (nicheId != null && _moduleNeedsAccessibilityPermission(nicheId)) {
        final prefs = await SharedPreferences.getInstance();
        bool alreadyAsked =
            prefs.getBool('asked_accessibility_permission_onboarding') ?? false;

        bool accessibilityGranted = await hasAccessibilityPermission();

        if (accessibilityGranted) {
          if (!alreadyAsked) {
            await prefs.setBool(
                'asked_accessibility_permission_onboarding', true);
          }
          return;
        }

        if (!accessibilityGranted && (forceUsage || !alreadyAsked)) {
          if (context.mounted) {
            final bool result = await _showAccessibilityPermissionDialog(context);

            if (!forceUsage && result) {
              await prefs.setBool(
                  'asked_accessibility_permission_onboarding', true);
            }
          }
        }
      }
    } finally {
      _isChecking = false;
    }
  }

  /// Verifica se a permissão foi concedida após o retorno do usuário das configurações.
  static Future<void> verifyPermissionAfterReturn(BuildContext context) async {
    if (!_shouldVerifySuccess) return;
    _shouldVerifySuccess = false;

    bool granted = await hasAccessibilityPermission();

    final effectiveContext = NavigationService.navigator?.context ?? context;
    if (!effectiveContext.mounted) return;

    if (granted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('asked_accessibility_permission_onboarding', true);

      if (effectiveContext.mounted) {
        if (Overlay.maybeOf(effectiveContext) != null) {
          EnhancedSnackBarHelper.showSuccess(
            effectiveContext,
            'Serviço de Acessibilidade ativado! Monitoramento preciso dos seus apps selecionados habilitado.',
          );
        }
      }
    }
  }

  /// Exibe o diálogo de permissão de acessibilidade (Fase 6).
  static Future<bool> _showAccessibilityPermissionDialog(
      BuildContext context) async {
    final dialogContext = NavigationService.navigator?.context ?? context;

    final bool? wentToSettings = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color.fromARGB(255, 96, 107, 135),
              ],
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.accessibility_new_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Permissão de Acessibilidade",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Para a detecção de uso de apps selecionados por VOCÊ funcionar corretamente, o app Disciplinum precisa ativar o Serviço de Acessibilidade:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 0, 0, 0),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF3F4F6),
                      foregroundColor: Color.fromARGB(255, 0, 0, 0),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.settings, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Ativar Acessibilidade",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Em 'Aplicativos Instalados' selecione o Disciplinum",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: const Text(
                      "Agora não",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (wentToSettings == true) {
      _shouldVerifySuccess = true;
      await openAccessibilitySettings();
      return true;
    } else if (wentToSettings == false) {
      if (context.mounted) {
        EnhancedSnackBarHelper.showInfo(
          context,
          'Sem acessibilidade, o app não funcionará corretamente. Ative-a para usar o app.',
        );
      }
      return true;
    }
    return false;
  }

  /// Verifica se tem a permissão de acessibilidade (Fase 6).
  static Future<bool> hasAccessibilityPermission() async {
    try {
      final bool? enabled = await _methodChannel
          .invokeMethod<bool>('isAccessibilityServiceEnabled');
      return enabled ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar acessibilidade', error: e);
      return false;
    }
  }

  /// Abre a tela de configurações de acessibilidade (Fase 6) com hints visuais.
  static Future<void> openAccessibilitySettings() async {
    try {
      await _methodChannel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      LoggerService.instance
          .e('Erro ao abrir configurações de acessibilidade', error: e);
    }
  }

  // --- FASE 7: SOBREPOSIÇÃO (OVERLAY) ---

  /// Verifica se o app tem permissão para sobrepor outros apps.
  static Future<bool> hasOverlayPermission() async {
    try {
      final bool? granted =
          await _methodChannel.invokeMethod<bool>('hasOverlayPermission');
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Abre a tela de configuração para permissão de sobreposição.
  static Future<void> requestOverlayPermission() async {
    try {
      await _methodChannel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      LoggerService.instance
          .e('Erro ao solicitar permissão de sobreposição', error: e);
    }
  }

  /// Verifica se o módulo deve pedir permissão de sobreposição.
  /// Retorna true se precisa, false se não precisa.
  static Future<bool> shouldRequestOverlayPermission(NicheId nicheId) async {
    return _moduleNeedsOverlayPermission(nicheId);
  }

  /// Verifica se o módulo precisa de permissão de acessibilidade (monitora apps).
  static bool _moduleNeedsAccessibilityPermission(NicheId nicheId) {
    // Apenas módulos que realmente monitoram apps precisam de acessibilidade
    switch (nicheId) {
      case NicheId.focus:
        return true; // Focus monitora outros apps
      case NicheId.spending:
        return true; // Spending monitora apps
      case NicheId.adultContent:
        return true; // Adult Content monitora apps
      case NicheId.bingeEating:
        return true; // Binge Eating monitora apps
      case NicheId.procrastination:
        return false; // Procrastination NÃO monitora apps (apenas gerencia tarefas)
      default:
        return false; // Demais módulos não monitoram apps
    }
  }

  /// Verifica se o módulo precisa de permissão de sobreposição (monitora apps).
  static bool _moduleNeedsOverlayPermission(NicheId nicheId) {
    // Apenas módulos que realmente monitoram apps precisam de overlay
    switch (nicheId) {
      case NicheId.focus:
        return true; // Focus monitora outros apps
      default:
        return false; // Demais módulos não monitoram apps
    }
  }

  /// Retorna o texto personalizado para o diálogo de sobreposição.
  static String _getOverlayPermissionText(NicheId nicheId) {
    // Apenas módulos que realmente monitoram apps precisam desta permissão
    switch (nicheId) {
      case NicheId.focus:
        return "Para você ser alertado a sair de apps que VOCÊ selecionou para bloqueio ou que você queira evitar (neste caso, você terá 30 segundos para sair do app), ative a permissão de 'Sobrepor a outros apps':";
      default:
        // Módulos que não monitoram apps não devem pedir esta permissão
        return ""; // Retorna vazio para não mostrar diálogo
    }
  }

  /// Exibe o diálogo de permissão de sobreposição se necessário.
  static Future<bool> ensureOverlayPermission(BuildContext context) async {
    if (await hasOverlayPermission()) return true;

    if (!context.mounted) return false;
    return await _showOverlayPermissionDialog(context);
  }

  /// Exibe o diálogo de permissão de sobreposição personalizado por módulo.
  /// Retorna true se permissão foi concedida, false se usuário clicou "Depois".
  static Future<bool> ensureOverlayPermissionForModule(
    BuildContext context,
    NicheId nicheId,
  ) async {
    if (await hasOverlayPermission()) return true;

    if (!context.mounted) return false;
    return await _showOverlayPermissionDialogForModule(context, nicheId);
  }

  static Future<bool> _showOverlayPermissionDialog(BuildContext context) async {
    return await _showOverlayPermissionDialogForModule(context, NicheId.focus);
  }

  /// Exibe o diálogo de permissão de sobreposição personalizado por módulo.
  static Future<bool> _showOverlayPermissionDialogForModule(
    BuildContext context,
    NicheId nicheId,
  ) async {
    final dialogContext = NavigationService.navigator?.context ?? context;
    final permissionText = _getOverlayPermissionText(nicheId);

    // Se não houver texto de permissão, não mostra o diálogo
    if (permissionText.isEmpty) return false;

    final bool? wentToSettings = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF3F4F6)],
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.layers_rounded,
                    color: Color(0xFF6366F1),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Permissão de sobreposição",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  permissionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      "Configurar Agora",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    "Depois",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (wentToSettings == true) {
      await requestOverlayPermission();
      return true;
    }
    return false;
  }
}
