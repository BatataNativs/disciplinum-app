import 'package:flutter/services.dart';

/// MethodChannel para comunicação com Android
/// Mantido apenas para operações nativas essenciais (fechar apps)
class AppLockChannel {
  static const MethodChannel _channel = MethodChannel('com.disciplinum.app/app_lock');

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

  /// Atualiza a lista de apps monitorados no AccessibilityMonitorService nativo
  static Future<void> updateMonitoredApps(List<String> apps) async {
    try {
      await _channel.invokeMethod('updateMonitoredApps', {
        'apps': apps,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar apps monitorados: $e');
    }
  }

  /// Atualiza o estado dos módulos (ativos/inativos) no LockDecisionEngine
  static Future<void> updateActiveModules(Map<String, bool> modules) async {
    try {
      await _channel.invokeMethod('updateActiveModules', {
        'modules': modules,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar módulos ativos: $e');
    }
  }

  /// Atualiza as configurações detalhadas dos módulos no LockDecisionEngine
  static Future<void> updateModuleConfigs(List<Map<String, dynamic>> configs) async {
    try {
      await _channel.invokeMethod('updateModuleConfigs', {
        'configs': configs,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar configurações dos módulos: $e');
    }
  }

  /// Verifica se o serviço de acessibilidade está habilitado
  static Future<bool> isAccessibilityEnabled() async {
    try {
      final bool? result = await _channel.invokeMethod('isAccessibilityEnabled');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se tem permissão de sobreposição (Overlay)
  static Future<bool> checkOverlayPermission() async {
    try {
      final bool? result = await _channel.invokeMethod('checkOverlayPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Solicita permissão de sobreposição
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      throw Exception('Erro ao solicitar permissão de sobreposição: $e');
    }
  }
}
