import 'package:flutter/services.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço de plataforma para gerenciar permissões do dispositivo
/// Fornece métodos para verificar e solicitar permissões nativas
class DevicePermissionService {
  static const _channel = MethodChannel('com.disciplinum.app/permissions');
  
  /// Verifica se tem permissão de sobreposição (SYSTEM_ALERT_WINDOW)
  static Future<bool> hasOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('hasOverlayPermission');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar permissão de sobreposição', error: e);
      return false;
    }
  }
  
  /// Solicita permissão de sobreposição
  static Future<bool> requestOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('requestOverlayPermission');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao solicitar permissão de sobreposição', error: e);
      return false;
    }
  }
  
  /// Abre as configurações de sobreposição do sistema
  static Future<bool> openOverlaySettings() async {
    try {
      final result = await _channel.invokeMethod('openOverlaySettings');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao abrir configurações de sobreposição', error: e);
      return false;
    }
  }
  
  /// Verifica se tem permissão de uso de dados (PACKAGE_USAGE_STATS)
  static Future<bool> hasUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('hasUsageStatsPermission');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar permissão de uso de dados', error: e);
      return false;
    }
  }
  
  /// Solicita permissão de uso de dados
  static Future<bool> requestUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('requestUsageStatsPermission');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao solicitar permissão de uso de dados', error: e);
      return false;
    }
  }
  
  /// Abre as configurações de uso de dados do sistema
  static Future<bool> openUsageStatsSettings() async {
    try {
      final result = await _channel.invokeMethod('openUsageStatsSettings');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao abrir configurações de uso de dados', error: e);
      return false;
    }
  }
  
  /// Verifica se tem permissão de notificações
  static Future<bool> hasNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod('hasNotificationPermission');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar permissão de notificações', error: e);
      return false;
    }
  }
  
  /// Solicita permissão de notificações
  static Future<bool> requestNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod('requestNotificationPermission');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao solicitar permissão de notificações', error: e);
      return false;
    }
  }
  
  /// Abre as configurações de notificações do sistema
  static Future<bool> openNotificationSettings() async {
    try {
      final result = await _channel.invokeMethod('openNotificationSettings');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao abrir configurações de notificações', error: e);
      return false;
    }
  }
  
  /// Verifica se o app está isento de otimização de bateria
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod('isIgnoringBatteryOptimizations');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar otimização de bateria', error: e);
      return false;
    }
  }
  
  /// Solicita isenção de otimização de bateria
  static Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao solicitar isenção de otimização de bateria', error: e);
      return false;
    }
  }
  
  /// Abre as configurações de bateria do sistema
  static Future<bool> openBatterySettings() async {
    try {
      final result = await _channel.invokeMethod('openBatterySettings');
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao abrir configurações de bateria', error: e);
      return false;
    }
  }
}
