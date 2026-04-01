import 'package:flutter/material.dart';
import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/app_lock/presentation/screens/app_lock_screen.dart';

/// Botão para testar a tela de bloqueio
/// Widget reutilizável para ProfileScreen
class AppLockButton extends StatelessWidget {
  const AppLockButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showAppLockTest(context),
      icon: const Icon(Icons.security),
      label: const Text('🧪 Testar Tela de Bloqueio'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan.withValues(alpha: 0.2),
        foregroundColor: Colors.cyan,
        side: BorderSide(
          color: Colors.cyan.withValues(alpha: 0.5),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Mostra a tela de bloqueio para teste
  void _showAppLockTest(BuildContext context) {
    final testEvent = AppLockEvent(
      packageName: 'com.whatsapp',
      appName: 'WhatsApp',
      appIconBytes: null, // Ícone será buscado automaticamente
      nicheId: NicheId.focus, // Teste com módulo Focus
      alertMessage: '⏳ Atenção aos objetivos. Mantenha o foco e a disciplina para alcançar seu objetivo!',
      timestamp: DateTime.now(),
      onExitApp: () => Navigator.of(context).pop(),
      onOpenApp: () => Navigator.of(context).pop(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppLockScreen(lockEvent: testEvent),
      ),
    );
  }
}
