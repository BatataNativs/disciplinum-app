import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_service_local.dart';

/// InformaÃ§Ãµes sobre uma sessÃ£o de uso
class DigitalDetoxSessionInfo {
  final String packageName;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final bool isActive;

  const DigitalDetoxSessionInfo({
    required this.packageName,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.isActive,
  });
}

/// EstatÃ­sticas das sessÃµes do dia
class DigitalDetoxSessionStats {
  final int totalSessionsUsed;
  final int totalSessionMinutes;
  final int remainingSessions;
  final int remainingSessionMinutes;
  final DateTime? nextSessionAvailableAt;
  final bool isInCooldown;

  const DigitalDetoxSessionStats({
    required this.totalSessionsUsed,
    required this.totalSessionMinutes,
    required this.remainingSessions,
    required this.remainingSessionMinutes,
    this.nextSessionAvailableAt,
    required this.isInCooldown,
  });
}

/// Gerenciador de sessÃµes controladas do Jejum Digital
/// Controla o uso de apps em sessÃµes com duraÃ§Ã£o e cooldown definidos
class DigitalDetoxSessionManager {
  static final DigitalDetoxSessionManager instance = DigitalDetoxSessionManager._internal();
  factory DigitalDetoxSessionManager() => instance;
  DigitalDetoxSessionManager._internal();

  final DigitalDetoxServiceLocal _service = DigitalDetoxServiceLocal.instance;
  DigitalDetoxSessionInfo? _currentSession;
  Timer? _sessionTimer;
  Timer? _cooldownTimer;

  /// Verifica se o modo de sessÃ£o estÃ¡ ativo
  Future<bool> isSessionModeEnabled(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      return config.enableSessionMode;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar modo de sessÃ£o', error: e);
      return false;
    }
  }

  /// Inicia uma sessÃ£o de uso para um app
  Future<bool> startSession(String userId, String packageName) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableSessionMode) {
        LoggerService.instance.i('Modo de sessÃ£o desativado, permitindo uso normal');
        return true;
      }

      // Verifica se jÃ¡ estÃ¡ em uma sessÃ£o ativa
      if (_currentSession != null && _currentSession!.isActive) {
        LoggerService.instance.i('SessÃ£o jÃ¡ ativa para ${_currentSession!.packageName}');
        return _currentSession!.packageName == packageName;
      }

      // Verifica cooldown
      if (await isInCooldown(userId)) {
        LoggerService.instance.i('App em cooldown, bloqueando acesso');
        return false;
      }

      // Verifica limites diÃ¡rios
      final stats = await getSessionStats(userId);
      if (stats.remainingSessions <= 0 || stats.remainingSessionMinutes <= 0) {
        LoggerService.instance.i('Limites diÃ¡rios de sessÃ£o atingidos');
        return false;
      }

      // Inicia nova sessÃ£o
      _currentSession = DigitalDetoxSessionInfo(
        packageName: packageName,
        startTime: DateTime.now(),
        endTime: null,
        durationMinutes: 0,
        isActive: true,
      );

      // Configura timer para finalizar sessÃ£o
      _sessionTimer?.cancel();
      _sessionTimer = Timer(Duration(minutes: config.sessionDurationMinutes), () {
        endSession(userId);
      });

      LoggerService.instance.gamification('SessÃ£o iniciada para $packageName - ${config.sessionDurationMinutes}min');
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro ao iniciar sessÃ£o', error: e);
      return false;
    }
  }

  /// Finaliza a sessÃ£o atual
  Future<void> endSession(String userId) async {
    try {
      if (_currentSession == null || !_currentSession!.isActive) {
        return;
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(_currentSession!.startTime).inMinutes;

      _currentSession = DigitalDetoxSessionInfo(
        packageName: _currentSession!.packageName,
        startTime: _currentSession!.startTime,
        endTime: endTime,
        durationMinutes: duration,
        isActive: false,
      );

      _sessionTimer?.cancel();

      // Inicia cooldown
      await _startCooldown(userId);

      LoggerService.instance.gamification('SessÃ£o finalizada - DuraÃ§Ã£o: ${duration}min');
    } catch (e) {
      LoggerService.instance.e('Erro ao finalizar sessÃ£o', error: e);
    }
  }

  /// Verifica se estÃ¡ em perÃ­odo de cooldown
  Future<bool> isInCooldown(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      final lastSessionEnd = _getLastSessionEnd(userId);
      
      if (lastSessionEnd == null) {
        return false;
      }

      final cooldownEnd = lastSessionEnd.add(Duration(hours: config.sessionCooldownHours));
      return DateTime.now().isBefore(cooldownEnd);
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar cooldown', error: e);
      return false;
    }
  }

  /// ObtÃ©m estatÃ­sticas das sessÃµes do dia
  Future<DigitalDetoxSessionStats> getSessionStats(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      // SimulaÃ§Ã£o - dados viriam do TimeTracker ou repositÃ³rio especÃ­fico
      final totalSessionsUsed = _getTodaySessionCount(userId);
      final totalSessionMinutes = _getTodaySessionMinutes(userId);
      
      final remainingSessions = config.maxSessionsPerDay - totalSessionsUsed;
      final remainingSessionMinutes = config.sessionDailyLimitMinutes - totalSessionMinutes;
      
      DateTime? nextSessionAvailableAt;
      bool isInCooldown = false;
      
      if (_currentSession == null || !_currentSession!.isActive) {
        final lastSessionEnd = _getLastSessionEnd(userId);
        if (lastSessionEnd != null) {
          final cooldownEnd = lastSessionEnd.add(Duration(hours: config.sessionCooldownHours));
          if (DateTime.now().isBefore(cooldownEnd)) {
            nextSessionAvailableAt = cooldownEnd;
            isInCooldown = true;
          }
        }
      }

      return DigitalDetoxSessionStats(
        totalSessionsUsed: totalSessionsUsed,
        totalSessionMinutes: totalSessionMinutes,
        remainingSessions: remainingSessions.clamp(0, config.maxSessionsPerDay),
        remainingSessionMinutes: remainingSessionMinutes.clamp(0, config.sessionDailyLimitMinutes),
        nextSessionAvailableAt: nextSessionAvailableAt,
        isInCooldown: isInCooldown,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatÃ­sticas de sessÃ£o', error: e);
      return const DigitalDetoxSessionStats(
        totalSessionsUsed: 0,
        totalSessionMinutes: 0,
        remainingSessions: 0,
        remainingSessionMinutes: 0,
        isInCooldown: false,
      );
    }
  }

  /// Verifica se pode iniciar uma sessÃ£o
  Future<bool> canStartSession(String userId) async {
    try {
      if (!(await isSessionModeEnabled(userId))) {
        return true; // Se modo desativado, permite uso normal
      }

      if (_currentSession != null && _currentSession!.isActive) {
        return false; // JÃ¡ em sessÃ£o ativa
      }

      if (await isInCooldown(userId)) {
        return false; // Em cooldown
      }

      final stats = await getSessionStats(userId);
      return stats.remainingSessions > 0 && stats.remainingSessionMinutes > 0;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar se pode iniciar sessÃ£o', error: e);
      return true; // Em caso de erro, permite acesso
    }
  }

  /// ObtÃ©m informaÃ§Ãµes da sessÃ£o atual
  DigitalDetoxSessionInfo? getCurrentSession() {
    return _currentSession;
  }

  /// ForÃ§a o fim de todas as sessÃµes (usado ao desativar mÃ³dulo)
  void forceEndAllSessions() {
    _sessionTimer?.cancel();
    _cooldownTimer?.cancel();
    _currentSession = null;
    LoggerService.instance.i('Todas as sessÃµes foram finalizadas');
  }

  /// Inicia o perÃ­odo de cooldown
  Future<void> _startCooldown(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer(Duration(hours: config.sessionCooldownHours), () {
        LoggerService.instance.i('PerÃ­odo de cooldown finalizado');
        _cooldownTimer = null;
      });
    } catch (e) {
      LoggerService.instance.e('Erro ao iniciar cooldown', error: e);
    }
  }

  /// ObtÃ©m a data do fim da Ãºltima sessÃ£o (simulaÃ§Ã£o)
  DateTime? _getLastSessionEnd(String userId) {
    // Na implementaÃ§Ã£o real, isto viria do repositÃ³rio de sessÃµes
    // Por agora, retorna null para permitir testes
    return null;
  }

  /// ObtÃ©m o nÃºmero de sessÃµes hoje (simulaÃ§Ã£o)
  int _getTodaySessionCount(String userId) {
    // Na implementaÃ§Ã£o real, isto viria do repositÃ³rio de sessÃµes
    // Por agora, retorna 0 para permitir testes
    return 0;
  }

  /// ObtÃ©m os minutos de sessÃ£o hoje (simulaÃ§Ã£o)
  int _getTodaySessionMinutes(String userId) {
    // Na implementaÃ§Ã£o real, isto viria do repositÃ³rio de sessÃµes
    // Por agora, retorna 0 para permitir testes
    return 0;
  }

  /// Limpa recursos
  void dispose() {
    _sessionTimer?.cancel();
    _cooldownTimer?.cancel();
    _currentSession = null;
  }
}
