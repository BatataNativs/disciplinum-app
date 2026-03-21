import 'dart:io';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:path_provider/path_provider.dart';

/// Serviço para gerenciar espaço de armazenamento e cache
class StorageManager {
  static const int _warningThresholdMB = 500; // 500MB
  static const int _criticalThresholdMB = 1000; // 1GB

  /// Verifica espaço disponível no dispositivo
  static Future<Map<String, dynamic>> checkStorageSpace() async {
    try {
      // Tentar obter diretório de aplicativo para cálculo de espaço
      Directory? appDir;
      try {
        appDir = await getApplicationDocumentsDirectory();
      } catch (e) {
        // Fallback para diretório temporário se path_provider falhar
        appDir = Directory.systemTemp;
        LoggerService.instance.w('Fallback para diretório temporário', error: e);
      }
      
      // Calcular espaço usado pelo app (não espaço livre do dispositivo)
      int totalSize = 0;
      try {
        if (await appDir.exists()) {
          await for (final entity in appDir.list(recursive: true)) {
            try {
              final stat = await entity.stat();
              totalSize += stat.size;
            } catch (e) {
              // Ignorar arquivos que não podem ser acessados
            }
          }
        }
      } catch (e) {
        LoggerService.instance.w('Não foi possível calcular tamanho do app', error: e);
      }
      
      final totalMB = (totalSize / (1024 * 1024)).round();
      
      return {
        'usedBytes': totalSize,
        'usedMB': totalMB,
        'isWarning': totalMB > _warningThresholdMB,
        'isCritical': totalMB > _criticalThresholdMB,
        'status': totalMB > _warningThresholdMB ? 'warning' : 
                   totalMB > _criticalThresholdMB ? 'critical' : 'ok'
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar espaço de armazenamento', error: e);
      return {
        'usedBytes': 0,
        'usedMB': 0,
        'isWarning': false,
        'isCritical': false,
        'status': 'error'
      };
    }
  }

  /// Limpa cache do app de forma segura
  static Future<Map<String, dynamic>> clearAppCache() async {
    int cleanedFiles = 0;
    int cleanedBytes = 0;

    try {
      // 1. Limpar cache temporário do sistema
      final tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          try {
            if (entity is File && entity.path.contains('disciplinum')) {
              final stat = await entity.stat();
              await entity.delete();
              cleanedFiles++;
              cleanedBytes += stat.size;
            }
          } catch (e) {
            LoggerService.instance.w('Falha ao deletar arquivo temporário: ${entity.path}', error: e);
          }
        }
      }

      // 2. Limpar cache do aplicativo usando path_provider
      try {
        final cacheDir = await getTemporaryDirectory();
        if (await cacheDir.exists()) {
          await for (final entity in cacheDir.list(recursive: true)) {
            try {
              if (entity is File) {
                final stat = await entity.stat();
                await entity.delete();
                cleanedFiles++;
                cleanedBytes += stat.size;
              }
            } catch (e) {
              LoggerService.instance.w('Falha ao deletar cache: ${entity.path}', error: e);
            }
          }
        }
      } catch (e) {
        LoggerService.instance.w('Não foi possível acessar diretório de cache temporário', error: e);
      }

      // 3. Tentar limpar cache de aplicativo específico
      try {
        final appCacheDir = await getApplicationSupportDirectory();
        final cacheSubDir = Directory('${appCacheDir.path}/cache');
        if (await cacheSubDir.exists()) {
          await for (final entity in cacheSubDir.list(recursive: true)) {
            try {
              if (entity is File) {
                final stat = await entity.stat();
                await entity.delete();
                cleanedFiles++;
                cleanedBytes += stat.size;
              }
            } catch (e) {
              LoggerService.instance.w('Falha ao deletar cache do app: ${entity.path}', error: e);
            }
          }
        }
      } catch (e) {
        LoggerService.instance.w('Não foi possível acessar cache de suporte do aplicativo', error: e);
      }

      final cleanedMB = (cleanedBytes / (1024 * 1024)).round();
      
      LoggerService.instance.i('Cache limpo: $cleanedFiles arquivos, ${cleanedMB}MB liberados');
      
      return {
        'success': true,
        'cleanedFiles': cleanedFiles,
        'cleanedBytes': cleanedBytes,
        'cleanedMB': cleanedMB,
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar cache', error: e);
      return {
        'success': false,
        'error': e.toString(),
        'cleanedFiles': cleanedFiles,
        'cleanedBytes': cleanedBytes,
      };
    }
  }

  /// Verifica e limpa se necessário
  static Future<bool> checkAndCleanIfNeeded() async {
    final storage = await checkStorageSpace();
    
    if (storage['isCritical']) {
      LoggerService.instance.w('Espaço crítico detectado: ${storage['usedMB']}MB usados');
      
      final result = await clearAppCache();
      if (result['success']) {
        LoggerService.instance.i('Cache limpo automaticamente: ${result['cleanedMB']}MB');
        return true;
      } else {
        LoggerService.instance.w('Falha ao limpar cache automaticamente');
      }
    }
    
    return false;
  }

  /// Retorna mensagem amigável sobre espaço
  static String getStorageMessage(Map<String, dynamic> storage) {
    final status = storage['status'] as String;
    final usedMB = storage['usedMB'] as int;
    
    switch (status) {
      case 'critical':
        return '⚠️ Alto uso de armazenamento: $usedMB MB usados. Considere limpar o cache.';
      case 'warning':
        return '⚠️ Uso moderado: $usedMB MB usados. Monitore o espaço.';
      case 'error':
        return '❌ Erro ao verificar espaço. Verifique o armazenamento.';
      default:
        return '✅ Armazenamento OK: $usedMB MB usados.';
    }
  }
}
