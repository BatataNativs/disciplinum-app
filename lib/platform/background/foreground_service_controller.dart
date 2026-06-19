import 'package:flutter/services.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço de plataforma para controlar o Foreground Service Android
/// Gerencia o serviço de primeiro plano para monitoramento contínuo
class ForegroundServiceController {
  static const _channel = MethodChannel('com.disciplinum.app/foreground_service');
  
  /// Inicia o foreground service
  static Future<bool> startForegroundService({
    required String title,
    required String content,
    int notificationId = 888,
  }) async {
    try {
      final result = await _channel.invokeMethod('startForegroundService', {
        'title': title,
        'content': content,
        'notificationId': notificationId,
      });
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao iniciar foreground service', error: e);
      return false;
    }
  }
  
  /// Para o foreground service
  static Future<bool> stopForegroundService() async {
    try {
      final result = await _channel.invokeMethod('stopForegroundService');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao parar foreground service', error: e);
      return false;
    }
  }
  
  /// Atualiza a notificação do foreground service
  static Future<bool> updateNotification({
    required String title,
    required String content,
    int notificationId = 888,
  }) async {
    try {
      final result = await _channel.invokeMethod('updateForegroundNotification', {
        'title': title,
        'content': content,
        'notificationId': notificationId,
      });
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar notificação foreground', error: e);
      return false;
    }
  }
  
  /// Verifica se o foreground service está rodando
  static Future<bool> isForegroundServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isForegroundServiceRunning');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar foreground service', error: e);
      return false;
    }
  }
}
