import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Estratégia de fallback para problemas de conectividade
class ConnectivityFallback {
  static final ConnectivityFallback _instance = ConnectivityFallback._internal();
  factory ConnectivityFallback() => _instance;
  ConnectivityFallback._internal();

  // Cache local temporário para operações que falharam
  final Map<String, dynamic> _localCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Duração do cache local (5 minutos)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Executa operação com fallback para cache local
  Future<T?> executeWithFallback<T>(
    String operationKey,
    Future<T?> Function() cloudOperation,
    T? Function()? localFallback,
  ) async {
    // 1. Tentar operação na nuvem
    try {
      final result = await cloudOperation();
      if (result != null) {
        // Sucesso: atualizar cache local
        _updateCache(operationKey, result);
        return result;
      }
    } catch (e) {
      LoggerService.instance.w('Operação cloud falhou para $operationKey: $e');
    }

    // 2. Tentar cache local
    final cachedResult = _getCachedData<T>(operationKey);
    if (cachedResult != null) {
      LoggerService.instance.i('Usando cache local para $operationKey');
      return cachedResult;
    }

    // 3. Tentar fallback local
    if (localFallback != null) {
      try {
        final result = localFallback();
        if (result != null) {
          LoggerService.instance.i('Usando fallback local para $operationKey');
          _updateCache(operationKey, result);
          return result;
        }
      } catch (e) {
        LoggerService.instance.e('Fallback local falhou para $operationKey: $e');
      }
    }

    // 4. Retornar null se tudo falhar
    LoggerService.instance.w('Todas as opções falharam para $operationKey');
    return null;
  }

  /// Atualiza cache local
  void _updateCache(String key, dynamic data) {
    _localCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    
    // Limpar cache antigo
    _cleanExpiredCache();
  }

  /// Obtém dados do cache local
  T? _getCachedData<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      // Cache expirado
      _localCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    final data = _localCache[key];
    return data is T ? data : null;
  }

  /// Limpa cache expirado
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheDuration) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _localCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Limpa todo o cache
  void clearCache() {
    _localCache.clear();
    _cacheTimestamps.clear();
  }

  /// Força atualização de um item específico
  void invalidateCache(String key) {
    _localCache.remove(key);
    _cacheTimestamps.remove(key);
  }
}
