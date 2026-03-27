import 'package:flutter/services.dart';

/// MethodChannel para comunicação com Android
/// Gerencia o sistema de App Lock nativo
class AppLockChannel {
  static const MethodChannel _channel = MethodChannel('disciplinum/app_lock');
  
  /// Mostra a tela de bloqueio no Flutter
  static Future<void> showAppLockScreen(Map<String, dynamic> eventData) async {
    try {
      await _channel.invokeMethod('showAppLockScreen', {
        'packageName': eventData['packageName'],
        'appName': eventData['appName'],
        'appIcon': eventData['appIcon'],
        'nicheId': eventData['nicheId'],
        'alertMessage': eventData['alertMessage'],
        'timestamp': eventData['timestamp']?.toString(),
      });
    } catch (e) {
      throw Exception('Erro ao mostrar tela de bloqueio: $e');
    }
  }

  /// Fecha o app bloqueado via sistema Android
  static Future<void> closeBlockedApp(String packageName) async {
    try {
      await _channel.invokeMethod('closeBlockedApp', {
        'packageName': packageName,
      });
    } catch (e) {
      throw Exception('Erro ao fechar app bloqueado: $e');
    }
  }

  /// Verifica se o MethodChannel está disponível
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod('isAvailable');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
