import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_service_local.dart';

/// InformaÃ§Ãµes sobre minutos acumulados (rollover)
class DigitalDetoxRolloverInfo {
  final int accumulatedMinutes;
  final int usedToday;
  final int availableToday;
  final DateTime? expiresAt;
  final bool isExpired;

  const DigitalDetoxRolloverInfo({
    required this.accumulatedMinutes,
    required this.usedToday,
    required this.availableToday,
    this.expiresAt,
    this.isExpired = false,
  });

  /// Minutos restantes hoje (incluindo rollover)
  int get remainingMinutes => availableToday - usedToday;

  /// FormataÃ§Ã£o para exibiÃ§Ã£o
  String get formattedAccumulated => _formatDuration(accumulatedMinutes);
  String get formattedAvailable => _formatDuration(availableToday);
  String get formattedRemaining => _formatDuration(remainingMinutes);

  static String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}min';
    }
  }
}

/// Gerenciador de Horas Cumulativas (Rollover) do Jejum Digital
/// Controla minutos nÃ£o usados que acumulam para o prÃ³ximo dia
class DigitalDetoxRolloverManager {
  static final DigitalDetoxRolloverManager instance = DigitalDetoxRolloverManager._internal();
  factory DigitalDetoxRolloverManager() => instance;
  DigitalDetoxRolloverManager._internal();

  final DigitalDetoxServiceLocal _service = DigitalDetoxServiceLocal.instance;
  Timer? _dailyResetTimer;

  /// Verifica se o modo rollover estÃ¡ ativo
  Future<bool> isRolloverEnabled(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      return config.enableRolloverMinutes;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar modo rollover', error: e);
      return false;
    }
  }

  /// Calcula minutos disponÃ­veis hoje (incluindo rollover)
  Future<int> getAvailableMinutesToday(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableRolloverMinutes) {
        return config.dailyLimitMinutes;
      }

      final rolloverMinutes = await _getAccumulatedMinutes(userId);
      final baseLimit = config.dailyLimitMinutes;
      
      // NÃ£o pode exceder o mÃ¡ximo configurado
      final totalAvailable = baseLimit + rolloverMinutes;
      final maxAllowed = baseLimit + config.maxRolloverMinutes;
      
      return totalAvailable.clamp(0, maxAllowed);
    } catch (e) {
      LoggerService.instance.e('Erro ao calcular minutos disponÃ­veis', error: e);
      return 0;
    }
  }

  /// ObtÃ©m informaÃ§Ãµes detalhadas do rollover
  Future<DigitalDetoxRolloverInfo> getRolloverInfo(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableRolloverMinutes) {
        return DigitalDetoxRolloverInfo(
          accumulatedMinutes: 0,
          usedToday: 0,
          availableToday: config.dailyLimitMinutes,
        );
      }

      final accumulatedMinutes = await _getAccumulatedMinutes(userId);
      final usedToday = await _getTodayUsageMinutes(userId);
      final baseLimit = config.dailyLimitMinutes;
      final maxTotal = baseLimit + config.maxRolloverMinutes;
      
      final availableToday = (baseLimit + accumulatedMinutes).clamp(0, maxTotal);
      
      // Verifica expiraÃ§Ã£o
      DateTime? expiresAt;
      bool isExpired = false;
      
      if (accumulatedMinutes > 0) {
        final lastAccumulationDate = await _getLastAccumulationDate(userId);
        if (lastAccumulationDate != null) {
          expiresAt = lastAccumulationDate.add(Duration(days: config.rolloverExpirationDays));
          isExpired = DateTime.now().isAfter(expiresAt);
        }
      }

      return DigitalDetoxRolloverInfo(
        accumulatedMinutes: accumulatedMinutes,
        usedToday: usedToday,
        availableToday: availableToday,
        expiresAt: expiresAt,
        isExpired: isExpired,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao obter informaÃ§Ãµes de rollover', error: e);
      return const DigitalDetoxRolloverInfo(
        accumulatedMinutes: 0,
        usedToday: 0,
        availableToday: 0,
      );
    }
  }

  /// Processa o final do dia e acumula minutos nÃ£o usados
  Future<void> processDayEnd(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableRolloverMinutes) {
        LoggerService.instance.i('Modo rollover desativado, ignorando processamento');
        return;
      }

      final usedToday = await _getTodayUsageMinutes(userId);
      final dailyLimit = config.dailyLimitMinutes;
      
      if (usedToday < dailyLimit) {
        final unusedMinutes = dailyLimit - usedToday;
        await _addAccumulatedMinutes(userId, unusedMinutes);
        LoggerService.instance.gamification('Minutos acumulados: $unusedMinutes minutos');
      } else {
        LoggerService.instance.i('Nenhum minuto para acumular - limite atingido');
      }

      // Limpa uso do dia
      await _clearTodayUsage(userId);
      
      // Verifica expiraÃ§Ã£o de minutos antigos
      await _expireOldMinutes(userId);
      
    } catch (e) {
      LoggerService.instance.e('Erro ao processar final do dia', error: e);
    }
  }

  /// Usa minutos do rollover (chamado quando usuÃ¡rio usa tempo)
  Future<void> useMinutes(String userId, int minutes) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableRolloverMinutes) {
        return;
      }

      // Primeiro usa minutos do dia normal
      final dailyLimit = config.dailyLimitMinutes;
      final usedToday = await _getTodayUsageMinutes(userId);
      
      if (usedToday < dailyLimit) {
        // Ainda estÃ¡ usando minutos do dia normal
        await _addTodayUsage(userId, minutes);
        return;
      }

      // JÃ¡ excedeu o limite do dia, usa do rollover
      final accumulatedMinutes = await _getAccumulatedMinutes(userId);
      final rolloverToUse = minutes.clamp(0, accumulatedMinutes);
      
      if (rolloverToUse > 0) {
        await _subtractAccumulatedMinutes(userId, rolloverToUse);
        LoggerService.instance.gamification('Minutos rollover usados: $rolloverToUse minutos');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao usar minutos', error: e);
    }
  }

  /// Reseta todos os minutos acumulados
  Future<void> resetRollover(String userId) async {
    try {
      await _clearAccumulatedMinutes(userId);
      LoggerService.instance.gamification('Minutos acumulados resetados');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar rollover', error: e);
    }
  }

  /// Inicia timer para reset diÃ¡rio automÃ¡tico
  void startDailyResetTimer() {
    _dailyResetTimer?.cancel();
    
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilTomorrow = tomorrow.difference(now);
    
    _dailyResetTimer = Timer(timeUntilTomorrow, () async {
      LoggerService.instance.i('Iniciando reset diÃ¡rio de rollover');
      // Processar rollover para o usuÃ¡rio ativo
      // Nota: O userId Ã© obtido no momento da execuÃ§Ã£o pelo caller
      // O timer apenas agenda - o processamento real ocorre via processDayEnd(userId)
      _scheduleNextDailyReset();
    });
    
    LoggerService.instance.i('Timer diÃ¡rio configurado para: ${tomorrow.toString()}');
  }

  /// Agenda prÃ³ximo reset diÃ¡rio
  void _scheduleNextDailyReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilTomorrow = tomorrow.difference(now);
    
    _dailyResetTimer = Timer(timeUntilTomorrow, () async {
      LoggerService.instance.i('Iniciando reset diÃ¡rio de rollover');
      _scheduleNextDailyReset();
    });
  }

  /// ObtÃ©m minutos acumulados (simulaÃ§Ã£o)
  Future<int> _getAccumulatedMinutes(String userId) async {
    // Na implementaÃ§Ã£o real, isto viria do repositÃ³rio de rollover
    // Por agora, retorna 0 para permitir testes
    return 0;
  }

  /// Adiciona minutos acumulados (simulaÃ§Ã£o)
  Future<void> _addAccumulatedMinutes(String userId, int minutes) async {
    // Na implementaÃ§Ã£o real, salvaria no repositÃ³rio de rollover
    LoggerService.instance.i('Adicionando $minutes minutos ao rollover para $userId');
  }

  /// Subtrai minutos acumulados (simulaÃ§Ã£o)
  Future<void> _subtractAccumulatedMinutes(String userId, int minutes) async {
    // Na implementaÃ§Ã£o real, atualizaria o repositÃ³rio de rollover
    LoggerService.instance.i('Subtraindo $minutes minutos do rollover para $userId');
  }

  /// Limpa minutos acumulados (simulaÃ§Ã£o)
  Future<void> _clearAccumulatedMinutes(String userId) async {
    // Na implementaÃ§Ã£o real, limparia o repositÃ³rio de rollover
    LoggerService.instance.i('Limpando minutos acumulados para $userId');
  }

  /// ObtÃ©m uso de hoje (simulaÃ§Ã£o)
  Future<int> _getTodayUsageMinutes(String userId) async {
    // Na implementaÃ§Ã£o real, viria do TimeTracker
    return 0;
  }

  /// Adiciona uso de hoje (simulaÃ§Ã£o)
  Future<void> _addTodayUsage(String userId, int minutes) async {
    // Na implementaÃ§Ã£o real, atualizaria o TimeTracker
    LoggerService.instance.i('Adicionando $minutes minutos ao uso de hoje para $userId');
  }

  /// Limpa uso de hoje (simulaÃ§Ã£o)
  Future<void> _clearTodayUsage(String userId) async {
    // Na implementaÃ§Ã£o real, resetaria o uso diÃ¡rio no TimeTracker
    LoggerService.instance.i('Limpando uso diÃ¡rio para $userId');
  }

  /// ObtÃ©m data da Ãºltima acumulaÃ§Ã£o (simulaÃ§Ã£o)
  Future<DateTime?> _getLastAccumulationDate(String userId) async {
    // Na implementaÃ§Ã£o real, viria do repositÃ³rio de rollover
    return null;
  }

  /// Expira minutos antigos (simulaÃ§Ã£o)
  Future<void> _expireOldMinutes(String userId) async {
    // Na implementaÃ§Ã£o real, verificaria e removeria minutos expirados
    LoggerService.instance.i('Verificando minutos expirados para $userId');
  }

  /// Limpa recursos
  void dispose() {
    _dailyResetTimer?.cancel();
    _dailyResetTimer = null;
  }
}
