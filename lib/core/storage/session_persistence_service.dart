import 'dart:async';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/storage/entities/detection_session_entity.dart';
import 'package:disciplinum/core/storage/entities/monitoring_state_entity.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// SessionPersistenceService com ObjectBox
/// Baseado na documentação: https://docs.objectbox.io/queries
class SessionPersistenceService {
  final ObjectBoxService _objectBoxService;
  
  SessionPersistenceService(this._objectBoxService);
  
  /// Salva uma sessão de detecção ativa
  Future<void> saveDetectionSession({
    required String packageName,
    required NicheId nicheId,
    required int duration,
    int remainingSeconds = 30,
  }) async {
    try {
      final session = DetectionSession.create(
        packageName: packageName,
        startTime: DateTime.now(),
        duration: duration,
        isActive: true,
        nicheId: nicheId,
        remainingSeconds: remainingSeconds,
      );
      
      _objectBoxService.store.box<DetectionSession>().put(session);
      
      LoggerService.instance.performance(
        'Detection session saved',
        const Duration(milliseconds: 1),
        metadata: {
          'packageName': packageName,
          'nicheId': nicheId.name,
          'remainingSeconds': remainingSeconds,
        },
      );
    } catch (e) {
      LoggerService.instance.e('Failed to save detection session', error: e);
    }
  }
  
  /// Recupera sessões ativas
  Future<List<DetectionSession>> getActiveSessions() async {
    try {
      final allSessions = _objectBoxService.store.box<DetectionSession>().getAll();
      final sessions = allSessions.where((session) => session.isActive).toList();
      
      // Remove sessões expiradas
      final activeSessions = <DetectionSession>[];
      for (final session in sessions) {
        if (session.isExpired) {
          _objectBoxService.store.box<DetectionSession>().remove(session.id);
        } else {
          activeSessions.add(session);
        }
      }
      
      return activeSessions;
    } catch (e) {
      LoggerService.instance.e('Failed to get active sessions', error: e);
      return [];
    }
  }
  
  /// Marca uma sessão como inativa
  Future<void> markSessionInactive(String packageName) async {
    try {
      final allSessions = _objectBoxService.store.box<DetectionSession>().getAll();
      final sessions = allSessions.where((session) => 
          session.packageName == packageName && session.isActive).toList();
      
      for (final session in sessions) {
        session.markAsInactive();
      }
      
      _objectBoxService.store.box<DetectionSession>().putMany(sessions);
      
      LoggerService.instance.performance(
        'Detection session marked inactive',
        const Duration(milliseconds: 1),
        metadata: {'packageName': packageName},
      );
    } catch (e) {
      LoggerService.instance.e('Failed to mark session inactive', error: e);
    }
  }
  
  /// Salva o estado de monitoramento
  Future<void> saveMonitoringState({
    NicheId? activeNicheId,
    required bool isMonitoringActive,
    required List<String> monitoredApps,
  }) async {
    try {
      final state = MonitoringState.create(
        activeNicheId: activeNicheId ?? NicheId.reading,
        isMonitoringActive: isMonitoringActive,
        monitoredApps: monitoredApps,
        lastHeartbeat: DateTime.now(),
      );
      
      // MonitoringState usa ID fixo = 1
      state.id = 1;
      _objectBoxService.store.box<MonitoringState>().put(state);
      
      LoggerService.instance.performance(
        'Monitoring state saved',
        const Duration(milliseconds: 1),
        metadata: {
          'activeNicheId': activeNicheId?.name,
          'isMonitoringActive': isMonitoringActive,
          'monitoredAppsCount': monitoredApps.length,
        },
      );
    } catch (e) {
      LoggerService.instance.e('Failed to save monitoring state', error: e);
    }
  }
  
  /// Recupera o estado de monitoramento
  Future<MonitoringState?> getMonitoringState() async {
    try {
      final state = _objectBoxService.store.box<MonitoringState>().get(1);
      
      if (state != null && state.isStale) {
        LoggerService.instance.w('Monitoring state is stale, clearing');
        await clearMonitoringState();
        return null;
      }
      
      return state;
    } catch (e) {
      LoggerService.instance.e('Failed to get monitoring state', error: e);
      return null;
    }
  }
  
  /// Atualiza o heartbeat do estado de monitoramento
  Future<void> updateHeartbeat() async {
    try {
      final state = await getMonitoringState();
      if (state != null) {
        state.updateHeartbeat();
        _objectBoxService.store.box<MonitoringState>().put(state);
      }
    } catch (e) {
      LoggerService.instance.e('Failed to update heartbeat', error: e);
    }
  }
  
  /// Registra uma violação no estado de monitoramento
  Future<void> registerViolation() async {
    try {
      final state = await getMonitoringState();
      if (state != null) {
        state.registerViolation();
        _objectBoxService.store.box<MonitoringState>().put(state);
        
        LoggerService.instance.performance(
          'Violation registered',
          const Duration(milliseconds: 1),
          metadata: {
            'totalViolations': state.violationCount,
            'lastViolation': state.lastViolationTime?.toIso8601String(),
          },
        );
      }
    } catch (e) {
      LoggerService.instance.e('Failed to register violation', error: e);
    }
  }
  
  /// Limpa o estado de monitoramento
  Future<void> clearMonitoringState() async {
    try {
      _objectBoxService.store.box<MonitoringState>().removeAll();
      LoggerService.instance.performance('Monitoring state cleared', const Duration(milliseconds: 1));
    } catch (e) {
      LoggerService.instance.e('Failed to clear monitoring state', error: e);
    }
  }
  
  /// Limpa sessões antigas (mais de 24 horas)
  Future<void> cleanupOldSessions() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      
      final allSessions = _objectBoxService.store.box<DetectionSession>().getAll();
      final oldSessions = allSessions.where((session) => session.startTime.isBefore(cutoff)).toList();
      
      for (final session in oldSessions) {
        _objectBoxService.store.box<DetectionSession>().remove(session.id);
      }
      
      if (oldSessions.isNotEmpty) {
        LoggerService.instance.performance(
          'Old sessions cleaned up',
          const Duration(milliseconds: 1),
          metadata: {'count': oldSessions.length},
        );
      }
    } catch (e) {
      LoggerService.instance.e('Failed to cleanup old sessions', error: e);
    }
  }
  
  /// Recupera sessões para um nicho específico
  Future<List<DetectionSession>> getSessionsForNiche(NicheId nicheId) async {
    try {
      final allSessions = _objectBoxService.store.box<DetectionSession>().getAll();
      return allSessions.where((session) => 
          session.nicheId == nicheId && session.isActive).toList();
    } catch (e) {
      LoggerService.instance.e('Failed to get sessions for niche', error: e);
      return [];
    }
  }
  
  /// Obtém estatísticas das sessões
  Future<Map<String, dynamic>> getSessionStats() async {
    try {
      final totalSessions = _objectBoxService.store.box<DetectionSession>().count();
      final activeSessions = await getActiveSessions();
      final state = await getMonitoringState();
      
      return {
        'totalSessions': totalSessions,
        'activeSessions': activeSessions.length,
        'isMonitoringActive': state?.isMonitoringActive ?? false,
        'activeNicheId': state?.activeNicheId.name,
        'violationCount': state?.violationCount ?? 0,
        'activeDuration': state?.activeDuration?.inMinutes ?? 0,
      };
    } catch (e) {
      LoggerService.instance.e('Failed to get session stats', error: e);
      return {};
    }
  }
}
