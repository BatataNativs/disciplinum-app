import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/events/events/gamification_events.dart';
import 'package:disciplinum/core/events/events/behavior_events.dart';

/// Serviço de analytics que escuta eventos do EventBus e persiste dados
/// Desacoplado dos serviços que geram os eventos
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  factory AnalyticsService() => _instance;

  AnalyticsService._internal() {
    _initialize();
  }

  late final EventBus _eventBus;

  String? _currentUserId;
  String? _currentSessionId;

  void _initialize() {
    _eventBus = EventBus.instance;
    _setupEventListeners();
  }

  /// Define o usuário atual para rastreamento
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
    LoggerService.instance.analytics('User set', {'userId': userId});
  }

  /// Gera um novo ID de sessão
  String generateNewSessionId() {
    _currentSessionId =
        '${DateTime.now().millisecondsSinceEpoch}_${_currentUserId ?? 'anonymous'}';
    LoggerService.instance.analytics('New session', {'sessionId': _currentSessionId});
    return _currentSessionId!;
  }

  /// Configura listeners para todos os tipos de eventos
  void _setupEventListeners() {
    // Eventos de gamificação
    _eventBus.listen<MedalAwardedEvent>(_handleMedalAwarded);
    _eventBus.listen<ModuleActivatedEvent>(_handleModuleActivated);
    _eventBus.listen<ModuleDeactivatedEvent>(_handleModuleDeactivated);
    _eventBus.listen<StreakUpdatedEvent>(_handleStreakUpdated);
    _eventBus.listen<FocusInsigniaAwardedEvent>(_handleFocusInsigniaAwarded);
    _eventBus.listen<FocusPeriodCompletedEvent>(_handleFocusPeriodCompleted);
    _eventBus.listen<AchievementUnlockedEvent>(_handleAchievementUnlocked);

    // Eventos de comportamento
    _eventBus.listen<CheckInEvent>(_handleCheckIn);
    _eventBus.listen<RelapseEvent>(_handleRelapse);
    _eventBus.listen<FocusSessionStartedEvent>(_handleFocusSessionStarted);
    _eventBus.listen<FocusSessionCompletedEvent>(_handleFocusSessionCompleted);
    _eventBus.listen<AppBlockedEvent>(_handleAppBlocked);
    _eventBus.listen<ModuleInteractionEvent>(_handleModuleInteraction);
    // _eventBus.listen<CustomizationEvent>(_handleCustomization);
  }

  // Handlers para eventos de gamificação

  void _handleMedalAwarded(MedalAwardedEvent event) {
    _recordBehaviorEvent(
      eventType: 'medal_awarded',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'medal_name': event.medal['name'],
        'medal_name_br': event.medal['name_br'],
        'consecutive_days': event.consecutiveDays,
      },
    );

    _recordAchievement(
      achievementType: 'medal_${event.medal['name']}',
      moduleNicheId: event.nicheId.id,
      achievementData: {
        'medal_name': event.medal['name'],
        'medal_name_br': event.medal['name_br'],
        'consecutive_days': event.consecutiveDays,
      },
    );
  }

  void _handleModuleActivated(ModuleActivatedEvent event) {
    _recordBehaviorEvent(
      eventType: 'module_activated',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'start_date': event.activationDate.toIso8601String(),
      },
    );
  }

  void _handleModuleDeactivated(ModuleDeactivatedEvent event) {
    _recordBehaviorEvent(
      eventType: 'module_deactivated',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'reason': event.reason,
        'final_consecutive_days': 0,
        'final_medal': null,
      },
    );
  }

  void _handleStreakUpdated(StreakUpdatedEvent event) {
    _recordBehaviorEvent(
      eventType: 'streak_updated',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'previous_days': event.previousStreak,
        'current_days': event.newStreak,
        'days_gained': event.newStreak - event.previousStreak,
        'is_new_record': event.isRecord,
      },
    );
  }

  void _handleFocusInsigniaAwarded(FocusInsigniaAwardedEvent event) {
    _recordBehaviorEvent(
      eventType: 'focus_insignia_awarded',
      moduleNicheId: 5, // NicheId.focus
      eventData: {
        'insignia_name': event.insignia['name'],
        'insignia_name_br': event.insignia['name_br'],
        'periods_respected': 0,
      },
    );

    _recordAchievement(
      achievementType: 'focus_insignia_${event.insignia['name']}',
      moduleNicheId: 5,
      achievementData: {
        'insignia_name': event.insignia['name'],
        'insignia_name_br': event.insignia['name_br'],
        'periods_respected': 0,
      },
    );
  }

  void _handleFocusPeriodCompleted(FocusPeriodCompletedEvent event) {
    _recordBehaviorEvent(
      eventType: 'focus_period_completed',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'total_periods': event.completedSessions,
        'consecutive_periods': event.completedSessions,
        'focus_duration_minutes': event.focusDuration.inMinutes,
      },
    );
  }

  void _handleAchievementUnlocked(AchievementUnlockedEvent event) {
    _recordAchievement(
      achievementType: event.achievementName,
      moduleNicheId: event.nicheId.id,
      achievementData: {},
    );
  }

  // Handlers para eventos de comportamento

  void _handleCheckIn(CheckInEvent event) {
    _recordBehaviorEvent(
      eventType: 'check_in',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'check_in_type': event.type.toString(),
        'additional_data': event.additionalData,
      },
    );
  }

  void _handleRelapse(RelapseEvent event) {
    _recordBehaviorEvent(
      eventType: 'relapse',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'relapse_type': event.type.toString(),
        'reason': event.reason,
        'streak_lost': event.streakLost,
        'context': event.context,
      },
    );
  }

  void _handleFocusSessionStarted(FocusSessionStartedEvent event) {
    _recordBehaviorEvent(
      eventType: 'focus_session_started',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'blocked_apps': event.blockedApps,
        'planned_duration_minutes': event.plannedDuration.inMinutes,
        'settings': event.settings,
      },
    );
  }

  void _handleFocusSessionCompleted(FocusSessionCompletedEvent event) {
    _recordBehaviorEvent(
      eventType: 'focus_session_completed',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'actual_duration_minutes': event.actualDuration.inMinutes,
        'interruptions_count': event.interruptionsCount,
        'was_successful': event.wasSuccessful,
        'triggered_blocks': event.triggeredBlocks,
      },
    );
  }

  void _handleAppBlocked(AppBlockedEvent event) {
    _recordBehaviorEvent(
      eventType: 'app_blocked',
      moduleNicheId: event.relatedNiche?.id,
      eventData: {
        'package_name': event.packageName,
        'app_name': event.appName,
        'blocking_reason': event.blockingReason,
        'related_niche_id': event.relatedNiche?.id,
      },
    );
  }

  void _handleModuleInteraction(ModuleInteractionEvent event) {
    _recordBehaviorEvent(
      eventType: 'module_interaction',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'interaction_type': event.interactionType.toString(),
        'target_screen': event.data['targetScreen'],
        'parameters': event.data['parameters'],
      },
    );
  }

  /* void _handleCustomization(CustomizationEvent event) {
    _recordBehaviorEvent(
      eventType: 'customization',
      moduleNicheId: event.nicheId.id,
      eventData: {
        'customization_type': event.customizationType.toString(),
        'customization_data': event.customizationData,
      },
    );
  } */

  /// Registra um evento de comportamento no Supabase
  Future<void> _recordBehaviorEvent({
    required String eventType,
    int? moduleNicheId,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('user_behavior_events').insert({
        'user_id': user.id,
        'event_type': eventType,
        'module_niche_id': moduleNicheId,
        'event_data': eventData ?? {},
        'session_id': _currentSessionId,
      });

      LoggerService.instance.analytics(
          'Recorded behavior event $eventType', {'moduleNicheId': moduleNicheId});
    } catch (e) {
      LoggerService.instance.e('AnalyticsService: Error recording behavior event', error: e);
    }
  }

  /// Registra uma conquista no Supabase
  Future<void> _recordAchievement({
    required String achievementType,
    int? moduleNicheId,
    required Map<String, dynamic> achievementData,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('user_achievements').insert({
        'user_id': user.id,
        'achievement_type': achievementType,
        'module_niche_id': moduleNicheId,
        'achievement_data': achievementData,
      });

      LoggerService.instance.analytics(
          'Recorded achievement $achievementType', {'moduleNicheId': moduleNicheId});
    } catch (e) {
      LoggerService.instance.e('AnalyticsService: Error recording achievement', error: e);
    }
  }

  /// Atualiza métricas de retenção diárias
  Future<void> updateDailyRetentionMetrics() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Buscar métricas atuais
      final existing = await Supabase.instance.client
          .from('user_retention_metrics')
          .select()
          .eq('user_id', user.id)
          .eq('metric_date', todayDate.toIso8601String())
          .maybeSingle();

      // Calcular métricas atuais dos eventos do dia
      final todayEvents = await Supabase.instance.client
          .from('user_behavior_events')
          .select()
          .eq('user_id', user.id)
          .gte('created_at', todayDate.toIso8601String())
          .lt('created_at', todayDate.add(Duration(days: 1)).toIso8601String());

      final activeModules = todayEvents
          .where((e) => e['event_type'] == 'module_activated')
          .map((e) => e['module_niche_id'])
          .toSet()
          .length;

      final totalCheckins =
          todayEvents.where((e) => e['event_type'] == 'check_in').length;

      final totalRelapses =
          todayEvents.where((e) => e['event_type'] == 'relapse').length;

      final appBlocksTriggered =
          todayEvents.where((e) => e['event_type'] == 'app_blocked').length;

      // Buscar total de minutos de foco
      final focusEvents = todayEvents.where((e) =>
          e['event_type'] == 'focus_session_completed' &&
          e['event_data']['was_successful'] == true);

      final totalFocusMinutes = focusEvents.fold<int>(
          0,
          (sum, e) =>
              sum +
              ((e['event_data']['actual_duration_minutes'] as num?)?.toInt() ??
                  0));

      // Buscar maior streak atual
      final streakEvents =
          todayEvents.where((e) => e['event_type'] == 'streak_updated');

      final longestStreak = streakEvents.isEmpty
          ? 0
          : streakEvents
              .map<int>((e) => e['event_data']['current_days'] ?? 0)
              .reduce((a, b) => a > b ? a : b);

      final metrics = {
        'active_modules': activeModules,
        'total_focus_minutes': totalFocusMinutes,
        'longest_streak': longestStreak,
        'total_checkins': totalCheckins,
        'total_relapses': totalRelapses,
        'app_blocks_triggered': appBlocksTriggered,
      };

      if (existing != null) {
        // Atualizar métricas existentes
        await Supabase.instance.client
            .from('user_retention_metrics')
            .update(metrics)
            .eq('id', existing['id']);
      } else {
        // Inserir novas métricas
        await Supabase.instance.client.from('user_retention_metrics').insert({
          'user_id': user.id,
          'metric_date': todayDate.toIso8601String(),
          ...metrics,
        });
      }

      LoggerService.instance.analytics(
          'Updated daily retention metrics', metrics);
    } catch (e) {
      LoggerService.instance.e('AnalyticsService: Error updating retention metrics', error: e);
    }
  }

  /// Limpa todas as assinaturas (útil para logout)
  void dispose() {
    _eventBus.clearListeners();
    _currentUserId = null;
    _currentSessionId = null;
  }
}
