import 'package:flutter/material.dart';
import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:disciplinum/features/app_lock/presentation/screens/app_lock_screen.dart';

/// Serviço de navegação para App Lock
/// Gerencia a exibição da tela de bloqueio Flutter (única implementação)
class AppLockNavigationService {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// GlobalKey para acesso ao NavigatorState
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// Mostra a tela de bloqueio Flutter (UI premium dark)
  /// Esta é a única implementação - garantida para funcionar 100%
  static Future<void> showAppLockScreen(AppLockEvent lockEvent) async {
    final context = _navigatorKey.currentContext;
    if (context == null) {
      throw Exception('Navigator não disponível - contexto nulo');
    }

    // Navega para a tela Flutter de bloqueio
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppLockScreen(lockEvent: lockEvent),
        fullscreenDialog: true,
      ),
    );
  }

  /// Obtém o contexto atual da navegação
  static BuildContext? get currentContext {
    return _navigatorKey.currentContext;
  }

  /// Fecha a tela de bloqueio atual
  static void closeAppLockScreen() {
    final context = currentContext;
    if (context != null && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}
