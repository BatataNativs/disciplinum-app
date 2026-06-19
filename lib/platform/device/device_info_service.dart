import 'dart:io';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço de plataforma para informações do dispositivo
/// Fornece informações sobre o hardware e sistema operacional
class DeviceInfoService {
  /// Verifica se o dispositivo é Android
  static bool get isAndroid => Platform.isAndroid;
  
  /// Verifica se o dispositivo é iOS
  static bool get isIOS => Platform.isIOS;
  
  /// Obtém o nome do sistema operacional
  static String get operatingSystem => Platform.operatingSystem;
  
  /// Obtém a versão do sistema operacional
  static String get operatingSystemVersion => Platform.operatingSystemVersion;
  
  /// Obtém o número de processadores lógicos
  static int get numberOfProcessors => Platform.numberOfProcessors;
  
  /// Obtém o caminho do diretório temporário
  static String get tempDirectory => Directory.systemTemp.path;
  
  /// Obtém informações detalhadas do dispositivo (Android)
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (isAndroid) {
        return await _getAndroidDeviceInfo();
      } else if (isIOS) {
        return await _getIOSDeviceInfo();
      }
      return {};
    } catch (e) {
      LoggerService.instance.e('Erro ao obter informações do dispositivo', error: e);
      return {};
    }
  }
  
  static Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    // Implementação futura usando device_info_plus
    return {
      'platform': 'android',
      'version': operatingSystemVersion,
    };
  }
  
  static Future<Map<String, dynamic>> _getIOSDeviceInfo() async {
    // Implementação futura usando device_info_plus
    return {
      'platform': 'ios',
      'version': operatingSystemVersion,
    };
  }
}
