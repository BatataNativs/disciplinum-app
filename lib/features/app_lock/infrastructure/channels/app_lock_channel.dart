import 'package:flutter/services.dart';

/// MethodChannel para comunicação com Android
/// Mantido apenas para operações nativas essenciais (fechar apps)
class AppLockChannel {
  static const MethodChannel _channel = MethodChannel('disciplinum/app_lock');

  /// Fecha o app bloqueado via sistema Android
  /// Único método nativo necessário - UI é 100% Flutter
  static Future<void> closeBlockedApp(String packageName) async {
    try {
      await _channel.invokeMethod('closeBlockedApp', {
        'packageName': packageName,
      });
    } catch (e) {
      throw Exception('Erro ao fechar app bloqueado: $e');
    }
  }

  /// Traz o app Disciplinum para o primeiro plano (sobrepondo o app bloqueado)
  static Future<void> bringToForeground() async {
    try {
      await _channel.invokeMethod('bringToForeground');
    } catch (e) {
      // Falha silenciosa ou log
    }
  }
}
