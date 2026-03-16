import 'dart:async';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/storage/entities/detection_session_entity.dart';
import 'package:disciplinum/core/storage/entities/monitoring_state_entity.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:isar/isar.dart';

/// SessionPersistenceService com sintaxe Isar 3.0.5 corrigida
/// Baseado na documentação: https://isar.dev/queries.html
class SessionPersistenceService {
  static SessionPersistenceService? _instance;
  static SessionPersistenceService get instance {
    _instance ??= SessionPersistenceService._internal();
    return _instance!;
  }
  
  SessionPersistenceService._internal();
  
  late IsarService _isarService;
  
  /// Inicializa o serviço com a instância do Isar
  void initialize(IsarService isarService) {
    _isarService = isarService;
  }
  
  /// Salva uma sessão de detecção ativa
  Future<void> saveDetectionSession({
    required String packageName,
    required NicheId nicheId,
    required int duration,
    int remainingSeconds = 30,
  }) async {
    try {
      final session = DetectionSession(
        packageName: packageName,
        startTime: DateTime.now(),
        duration: duration,
        isActive: true,
        nicheId: nicheId,
        remainingSeconds: remainingSeconds,
      );
      
      await _isarService.database.writeTxn(() async {
        await _isarService.database.detectionSessions.put(session);
      });
      
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
  
  /// Recupera sessões ativas - Sintaxe Isar 3.0.5
  Future<List<DetectionSession>> getActiveSessions() async {
    try {
      // ✅ Sintaxe simples: buscar tudo e filtrar manualmente
      final allSessions = await _isarService.database.detectionSessions.where().build().findAll();
      final sessions = allSessions.where((session) => session.isActive).toList();
      
      // Remove sessões expiradas
      final activeSessions = <DetectionSession>[];
      for (final session in sessions) {
        if (session.isExpired) {
          await _isarService.database.writeTxn(() async {
            await _isarService.database.detectionSessions.delete(session.id!);
          });
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
      // ✅ Sintaxe simples: buscar tudo e filtrar manualmente
      final allSessions = await _isarService.database.detectionSessions.where().build().findAll();
      final sessions = allSessions.where((session) => 
          session.packageName == packageName && session.isActive).toList();
      
      for (final session in sessions) {
        session.markAsInactive();
      }
      
      await _isarService.database.writeTxn(() async {
        await _isarService.database.detectionSessions.putAll(sessions);
      });
      
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
      final state = MonitoringState(
        activeNicheId: activeNicheId ?? NicheId.reading,
        isMonitoringActive: isMonitoringActive,
        monitoredApps: monitoredApps,
        lastHeartbeat: DateTime.now(),
      );
      
      await _isarService.database.writeTxn(() async {
        await _isarService.database.monitoringStates.put(state);
      });
      
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
      final state = await _isarService.database.monitoringStates.get(1);
      
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
        await _isarService.database.writeTxn(() async {
          await _isarService.database.monitoringStates.put(state);
        });
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
        await _isarService.database.writeTxn(() async {
          await _isarService.database.monitoringStates.put(state);
        });
        
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
      await _isarService.database.writeTxn(() async {
        await _isarService.database.monitoringStates.clear();
      });
      LoggerService.instance.performance('Monitoring state cleared', const Duration(milliseconds: 1));
    } catch (e) {
      LoggerService.instance.e('Failed to clear monitoring state', error: e);
    }
  }
  
  /// Limpa sessões antigas (mais de 24 horas)
  Future<void> cleanupOldSessions() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      
      // ✅ Sintaxe simples: buscar tudo e filtrar manualmente
      final allSessions = await _isarService.database.detectionSessions.where().build().findAll();
      final oldSessions = allSessions.where((session) => session.startTime.isBefore(cutoff)).toList();
      
      await _isarService.database.writeTxn(() async {
        for (final session in oldSessions) {
          await _isarService.database.detectionSessions.delete(session.id!);
        }
      });
      
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
      // ✅ Sintaxe simples: buscar tudo e filtrar manualmente
      final allSessions = await _isarService.database.detectionSessions.where().build().findAll();
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
      final totalSessions = await _isarService.database.detectionSessions.count();
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
