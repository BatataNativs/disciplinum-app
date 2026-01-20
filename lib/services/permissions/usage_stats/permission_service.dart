import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notifications/notification_service.dart';

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

      if (!context.mounted) {
        return;
      }

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
        if (!context.mounted) {
          return;
        }

        final bool result = await _showUsagePermissionDialog(context);

        if (!forceUsage && result) {
          await prefs.setBool('asked_usage_permission_onboarding', true);
        }
      }
    } finally {
      _isChecking = false;
    }
  }

  /// Exibe o diálogo de permissão de uso e gerencia o fluxo.
  /// Retorna true se o usuário interagiu com o diálogo (mesmo que clicando em "Agora não").
  static Future<bool> _showUsagePermissionDialog(BuildContext context) async {
    final bool? wentToSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text("⚙️ Acesso necessário"),
          ],
        ),
        content: const Text(
          "Para o app funcionar corretamente, "
          "o Android exige que você ative manualmente o:\n'Acesso a dados de uso'.\n\n"
          "Clique no botão abaixo e, na próxima tela, ative a chave.",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ir para Configurações"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Agora não (app não funcionará)",
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );

    if (!context.mounted) {
      return false;
    }

    if (wentToSettings == true) {
      _shouldVerifySuccess = true;
      await UsageStats.grantUsagePermission();
      return true;
    } else if (wentToSettings == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('⚠️ Sem essa permissão, o app não funcionará corretamente. '
                  'Você precisará ativá-la ao usar os módulos.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return true;
    }
    return false;
  }

  /// Método para ser chamado quando o app volta do background (resumed)
  /// para verificar se a permissão foi concedida após o retorno das configurações.
  static Future<void> verifyPermissionAfterReturn(BuildContext context) async {
    if (!_shouldVerifySuccess) return;

    bool granted = await hasUsagePermission();
    if (!context.mounted) return;

    if (granted) {
      _shouldVerifySuccess = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✔ Permissão concedida com sucesso'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
    // Não mostramos erro aqui se não foi concedida para não ser irritante,
    // já que o diálogo inicial já avisou.
  }

  static Future<bool> hasUsagePermission() async {
    try {
      final bool? granted = await UsageStats.checkUsagePermission();
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }
}
