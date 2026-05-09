import 'dart:async';
import 'package:disciplinum/features/modules/digital_detox/data/repositories/digital_detox_session_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/data/repositories/digital_detox_stats_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_config_entity.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_session_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// ServiÃ§o para rastrear tempo de uso de apps
/// Gerencia sessÃµes ativas e calcula tempo total usado
class DigitalDetoxTimeTracker {
  static DigitalDetoxTimeTracker? _instance;
  static DigitalDetoxTimeTracker get instance => _instance ??= DigitalDetoxTimeTracker._internal();

  DigitalDetoxTimeTracker._internal();

  final DigitalDetoxSessionRepository _sessionRepo = DigitalDetoxSessionRepository.instance;
  final DigitalDetoxStatsRepository _statsRepo = DigitalDetoxStatsRepository.instance;

  // SessÃµes ativas por usuÃ¡rio
  final Map<String, DigitalDetoxSessionEntity> _activeSessions = {};

  // Timer para atualizar estatÃ­sticas
  Timer? _statsUpdateTimer;

  /// Inicia tracking quando um app Ã© aberto
  Future<void> onAppOpened(String userId, String packageName, String appName) async {
    try {
      // Se jÃ¡ existe sessÃ£o ativa para outro app, finaliza ela
      if (_activeSessions.containsKey(userId)) {
        final currentSession = _activeSessions[userId]!;
        if (currentSession.appPackageName != packageName) {
          await onAppClosed(userId);
        } else {
          // JÃ¡ estÃ¡ rastreando este app, nÃ£o faz nada
          return;
        }
      }

      // Inicia nova sessÃ£o
      final session = await _sessionRepo.startSession(
        userId: userId,
        appPackage: packageName,
        appName: appName,
        sessionType: "free",
      );

      _activeSessions[userId] = session;
      LoggerService.instance.i('SessÃ£o iniciada: $appName (ID: ${session.id})');

      // Inicia timer de atualizaÃ§Ã£o de estatÃ­sticas
      _startStatsUpdateTimer(userId);
    } catch (e) {
      LoggerService.instance.e('Erro ao iniciar sessÃ£o', error: e);
    }
  }

  /// Finaliza tracking quando um app Ã© fechado
  Future<void> onAppClosed(String userId) async {
    try {
      if (!_activeSessions.containsKey(userId)) return;

      final session = _activeSessions[userId]!;
      await _sessionRepo.endSession(session.id, blocked: false, completed: true);

      _activeSessions.remove(userId);
      LoggerService.instance.i('SessÃ£o finalizada: ${session.appName} - ${session.durationMinutes}min');

      // Atualiza estatÃ­sticas
      await _updateTodayStats(userId);

      // Para o timer se nÃ£o hÃ¡ mais sessÃµes ativas
      if (_activeSessions.isEmpty) {
        _stopStatsUpdateTimer();
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao finalizar sessÃ£o', error: e);
    }
  }

  /// Chamado quando o AppLock bloqueia um app
  Future<void> onAppBlocked(String userId) async {
    try {
      if (!_activeSessions.containsKey(userId)) return;

      final session = _activeSessions[userId]!;
      await _sessionRepo.endSession(session.id, blocked: true, completed: false);

      _activeSessions.remove(userId);
      LoggerService.instance.i('SessÃ£o bloqueada: ${session.appName}');

      // Atualiza estatÃ­sticas
      await _updateTodayStats(userId);
    } catch (e) {
      LoggerService.instance.e('Erro ao registrar bloqueio', error: e);
    }
  }

  /// Verifica se o usuÃ¡rio atingiu o limite de tempo diÃ¡rio
  Future<bool> hasReachedDailyLimit(String userId, DigitalDetoxConfigEntity config) async {
    if (!config.enableDailyLimit) return false;

    try {
      final todayMinutes = await _sessionRepo.getTodayTotalMinutes(userId);
      return todayMinutes >= config.dailyLimitMinutes;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar limite diÃ¡rio', error: e);
      return false;
    }
  }

  /// Verifica se estÃ¡ prÃ³ximo do limite (Ãºltimos X minutos)
  Future<bool> isNearDailyLimit(String userId, DigitalDetoxConfigEntity config) async {
    if (!config.enableDailyLimit) return false;

    try {
      final todayMinutes = await _sessionRepo.getTodayTotalMinutes(userId);
      final remainingMinutes = config.dailyLimitMinutes - todayMinutes;
      return remainingMinutes > 0 && remainingMinutes <= config.warnBeforeLimitMinutes;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar proximidade do limite', error: e);
      return false;
    }
  }

  /// Retorna minutos restantes do limite diÃ¡rio
  Future<int> getRemainingMinutes(String userId, DigitalDetoxConfigEntity config) async {
    if (!config.enableDailyLimit) return -1; // Ilimitado

    try {
      final todayMinutes = await _sessionRepo.getTodayTotalMinutes(userId);
      return (config.dailyLimitMinutes - todayMinutes).clamp(0, config.dailyLimitMinutes);
    } catch (e) {
      LoggerService.instance.e('Erro ao calcular minutos restantes', error: e);
      return 0;
    }
  }

  /// Retorna tempo usado hoje
  Future<int> getTodayUsageMinutes(String userId) async {
    try {
      return await _sessionRepo.getTodayTotalMinutes(userId);
    } catch (e) {
      LoggerService.instance.e('Erro ao obter uso diÃ¡rio', error: e);
      return 0;
    }
  }

  /// Retorna breakdown por app de hoje
  Future<Map<String, int>> getTodayAppUsage(String userId) async {
    try {
      return await _sessionRepo.getTodayAppUsage(userId);
    } catch (e) {
      LoggerService.instance.e('Erro ao obter uso por app', error: e);
      return {};
    }
  }

  /// Inicia timer para atualizar estatÃ­sticas periodicamente
  void _startStatsUpdateTimer(String userId) {
    _stopStatsUpdateTimer();
    _statsUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateTodayStats(userId);
    });
  }

  /// Para o timer de atualizaÃ§Ã£o
  void _stopStatsUpdateTimer() {
    _statsUpdateTimer?.cancel();
    _statsUpdateTimer = null;
  }

  /// Atualiza estatÃ­sticas do dia
  Future<void> _updateTodayStats(String userId) async {
    try {
      final sessions = await _sessionRepo.getTodaySessions(userId);
      final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
      final appUsage = await _sessionRepo.getTodayAppUsage(userId);

      // Encontra a sessÃ£o mais longa
      int longestSession = 0;
      for (final session in sessions) {
        if (session.durationMinutes > longestSession) {
          longestSession = session.durationMinutes;
        }
      }

      // Atualiza ou cria estatÃ­sticas
      await _statsRepo.updateTodayStats(
        userId,
        totalScreenTimeMinutes: totalMinutes,
        appBreakdown: appUsage,
        openCount: sessions.length,
        longestSessionMinutes: longestSession,
      );

      LoggerService.instance.d('EstatÃ­sticas atualizadas: ${totalMinutes}min');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estatÃ­sticas', error: e);
    }
  }

  /// Verifica se hÃ¡ uma sessÃ£o ativa
  bool hasActiveSession(String userId) {
    return _activeSessions.containsKey(userId);
  }

  /// Retorna o app atualmente em uso (se houver)
  String? getCurrentApp(String userId) {
    return _activeSessions[userId]?.appPackageName;
  }

  /// Formata minutos como string legÃ­vel
  static String formatDuration(int minutes) {
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
