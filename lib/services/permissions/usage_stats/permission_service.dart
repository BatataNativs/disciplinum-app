import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notifications/notification_service.dart';

class PermissionService {
  static bool _isChecking = false;
  static bool _shouldVerifySuccess = false;

  /// Garante que as permissões de Notificação e Status de Uso sejam verificadas.
  /// No launch, pede ambas sequencialmente apenas UMA vez.
  static Future<void> ensurePermissions(BuildContext context,
      {bool forceUsage = false}) async {
    if (_isChecking && !forceUsage) return;
    _isChecking = true;

    try {
      // 1. Notificação (Bloqueante - espera resposta do usuário)
      await NotificationService.requestPermission();

      if (!context.mounted) return;

      // 2. Status de Uso - Regra: Pedir apenas uma vez no launch (Onboarding)
      final prefs = await SharedPreferences.getInstance();
      bool alreadyAsked =
          prefs.getBool('asked_usage_permission_onboarding') ?? false;

      bool usageGranted = await hasUsagePermission();

      // Se já tiver a permissão, marcamos como "asked" para garantir consistência
      if (usageGranted) {
        if (!alreadyAsked) {
          await prefs.setBool('asked_usage_permission_onboarding', true);
        }
        return;
      }

      // Só pede se não tiver permissão E (não foi pedido ainda OU é forçado)
      if (!usageGranted && (forceUsage || !alreadyAsked)) {
        if (!context.mounted) return;

        // MARCA COMO PEDIDO ANTES de mostrar o diálogo para evitar que
        // reconstruções durante o retorno do app disparem outro diálogo.
        if (!forceUsage) {
          await prefs.setBool('asked_usage_permission_onboarding', true);
        }

        if (!context.mounted) return;
        await _showUsagePermissionDialog(context);
      }
    } finally {
      _isChecking = false;
    }
  }

  /// Exibe o diálogo de permissão de uso e gerencia o fluxo
  static Future<void> _showUsagePermissionDialog(BuildContext context) async {
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
            child:
                const Text("Agora não (app não funcionará)", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (wentToSettings == true) {
      // Abre as configurações de permissão.
      // O Android abre uma Activity externa. Não é awaitable de forma síncrona real.
      _shouldVerifySuccess = true;
      await UsageStats.grantUsagePermission();

      // O fluxo de verificação real ocorrerá na HomeScreen via didChangeAppLifecycleState (resumed).
    } else {
      // Usuário clicou "Agora não"
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('⚠️ Sem essa permissão, o app não funcionará corretamente. '
                  'Você precisará ativá-la ao usar os módulos.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    }
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
