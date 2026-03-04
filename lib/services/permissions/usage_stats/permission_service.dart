import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/main.dart'; // Para acessar o navigatorKey
import 'package:disciplinum/utils/snackbar_helper.dart';

class PermissionService {
  static bool _isChecking = false;
  static bool _shouldVerifySuccess = false;
  static DateTime? _lastCheckTime;

  /// Garante que as permissões de Notificação e Status de Uso sejam verificadas.
  /// No launch, pede ambas sequencialmente apenas UMA vez.
  static Future<void> ensurePermissions(BuildContext context,
      {bool forceUsage = false}) async {
    final now = DateTime.now();

    // LOCK & THROTTLING: Impede re-entrada e evita chamadas duplicadas por
    // lógicas de rebuild rápido (piscadas) nos primeiros 2 segundos.
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

      if (!context.mounted) return;

      // 2. Status de Uso
      final prefs = await SharedPreferences.getInstance();
      bool alreadyAsked =
          prefs.getBool('asked_usage_permission_onboarding') ?? false;

      bool usageGranted = await hasUsagePermission();

      if (usageGranted) {
        if (!alreadyAsked) {
          await prefs.setBool('asked_usage_permission_onboarding', true);
        }
        return;
      }

      if (!usageGranted && (forceUsage || !alreadyAsked)) {
        if (!context.mounted) return;

        final bool result = await _showUsagePermissionDialog(context);

        if (!forceUsage && result) {
          await prefs.setBool('asked_usage_permission_onboarding', true);
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

    bool granted = await hasUsagePermission();

    // Tenta obter o contexto mais atualizado (global) ou usa o local se ainda montado
    final effectiveContext = navigatorKey.currentContext ?? context;
    if (!effectiveContext.mounted) return;

    if (granted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('asked_usage_permission_onboarding', true);

      if (effectiveContext.mounted) {
        SnackBarHelper.showSuccess(
          effectiveContext,
          'Permissão de uso detectada! O app agora pode monitorar seus hábitos.',
        );
      }
    }
  }

  /// Exibe o diálogo de permissão de uso e gerencia o fluxo.
  /// Retorna true se o usuário interagiu com o diálogo (mesmo que clicando em "Agora não").
  static Future<bool> _showUsagePermissionDialog(BuildContext context) async {
    // Tenta usar o Contexto Global (Navigator) para evitar que o diálogo suma
    // se o HomeScreen for unmounted/remounted durante a inicialização.
    final dialogContext = navigatorKey.currentContext ?? context;

    final bool? wentToSettings = await showDialog<bool>(
      context: dialogContext,
      barrierDismissible: false,
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
                // cores degradê (imitar esse degradê em outros locais do app)
                Colors.white,
                const Color.fromARGB(255, 96, 107, 135),
              ],
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone
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
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Título premium
              Text(
                "Ação Necessária",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Conteúdo
              Text(
                "Para o app Disciplinum funcionar corretamente, o Android exige que você ative manualmente a seguinte permissão:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 0, 0, 0),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFE5E7EB)),
                ),
                child: Text(
                  "Acesso a dados de uso",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 0, 0, 0),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Basta clicar no botão abaixo e, na próxima tela, ativar a chave 👇🏻",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 0, 0, 0),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              // Botões premium
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Text(
                        "Agora não",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.settings, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Configurações",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (wentToSettings == true) {
      _shouldVerifySuccess = true;
      await UsageStats.grantUsagePermission();
      return true;
    } else if (wentToSettings == false) {
      // Usa o context global para o SnackBar também
      final scaffoldContext = navigatorKey.currentContext ?? context;
      if (scaffoldContext.mounted) {
        SnackBarHelper.showInfo(
          scaffoldContext,
          'Sem essa permissão, o app não funcionará corretamente. Você precisará ativá-la ao usar os módulos.',
        );
      }
      return true;
    }
    return false;
  }

  /// Atalho para verificar se tem a permissão de uso (sem pedir).
  static Future<bool> hasUsagePermission() async {
    try {
      final bool? granted = await UsageStats.checkUsagePermission();
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }
}
