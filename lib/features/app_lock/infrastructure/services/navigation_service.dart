import 'package:flutter/material.dart';
import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:disciplinum/features/app_lock/infrastructure/channels/app_lock_channel.dart';

/// Serviço de navegação para App Lock
/// Gerencia a exibição da tela de bloqueio
class AppLockNavigationService {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  /// Mostra a tela de bloqueio como modal
  static Future<void> showAppLockScreen(AppLockEvent lockEvent) async {
    try {
      // Verifica se o MethodChannel está disponível
      final isAvailable = await AppLockChannel.isAvailable();
      if (!isAvailable) {
        throw Exception('MethodChannel não disponível');
      }

      // Prepara os dados para o MethodChannel
      // Nota: appIconBytes pode ser null se o ícone não for encontrado
      final eventData = {
        'packageName': lockEvent.packageName,
        'appName': lockEvent.appName,
        'appIconBytes': lockEvent.appIconBytes,
        'nicheId': lockEvent.nicheId.index,
        'alertMessage': lockEvent.alertMessage,
        'timestamp': lockEvent.timestamp.millisecondsSinceEpoch,
      };

      // Chama o MethodChannel para mostrar a tela
      await AppLockChannel.showAppLockScreen(eventData);
      
    } catch (e) {
      throw Exception('Erro ao navegar para tela de bloqueio: $e');
    }
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
