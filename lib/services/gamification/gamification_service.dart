import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/infrastructure/monitoring/app_monitoring_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/repositories/user_module_repository.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/domain/models/time_of_day_range.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/infrastructure/notifications/notification_scheduler.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/features/gamification/domain/entities/medal.dart';

/// Estado do serviço de gamificação
class GamificationState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> userStats;
  final List<String> pendingMedals;
  final Map<int, int> diasConsecutivosByModule;
  final Map<int, bool> moduleStatus;
  final Map<int, List<String>> scheduleByModule;
  final Map<int, List<String>> motivationSchedulesByModule;
  final Map<int, List<String>> customPhrases;
  final Map<NicheId, String> customMessages;
  final bool notificationsPaused;
  final bool isGeneralMonitoringActive;
  final List<String> monitoredApps;
  final Map<int, int> periodosFocoRespeitados;
  final Map<int, TimeOfDayRange> focusIntervalByModule;
  final List<int> unlockedMotivationNiches;
  final List<int> unlockedNotificationNiches;

  const GamificationState({
    this.isLoading = false,
    this.error,
    this.userStats = const {},
    this.pendingMedals = const [],
    this.diasConsecutivosByModule = const {},
    this.moduleStatus = const {},
    this.scheduleByModule = const {},
    this.motivationSchedulesByModule = const {},
    this.customPhrases = const {},
    this.customMessages = const {},
    this.notificationsPaused = false,
    this.isGeneralMonitoringActive = false,
    this.monitoredApps = const [],
    this.periodosFocoRespeitados = const {},
    this.focusIntervalByModule = const {},
    this.unlockedMotivationNiches = const [],
    this.unlockedNotificationNiches = const [],
  });

  GamificationState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? userStats,
    List<String>? pendingMedals,
    Map<int, int>? diasConsecutivosByModule,
    Map<int, bool>? moduleStatus,
    Map<int, List<String>>? scheduleByModule,
    Map<int, List<String>>? motivationSchedulesByModule,
    Map<int, List<String>>? customPhrases,
    Map<NicheId, String>? customMessages,
    bool? notificationsPaused,
    bool? isGeneralMonitoringActive,
    List<String>? monitoredApps,
    Map<int, int>? periodosFocoRespeitados,
    Map<int, TimeOfDayRange>? focusIntervalByModule,
    List<int>? unlockedMotivationNiches,
    List<int>? unlockedNotificationNiches,
  }) {
    return GamificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userStats: userStats ?? this.userStats,
      pendingMedals: pendingMedals ?? this.pendingMedals,
      diasConsecutivosByModule:
          diasConsecutivosByModule ?? this.diasConsecutivosByModule,
      moduleStatus: moduleStatus ?? this.moduleStatus,
      scheduleByModule: scheduleByModule ?? this.scheduleByModule,
      motivationSchedulesByModule:
          motivationSchedulesByModule ?? this.motivationSchedulesByModule,
      customPhrases: customPhrases ?? this.customPhrases,
      customMessages: customMessages ?? this.customMessages,
      notificationsPaused: notificationsPaused ?? this.notificationsPaused,
      isGeneralMonitoringActive:
          isGeneralMonitoringActive ?? this.isGeneralMonitoringActive,
      monitoredApps: monitoredApps ?? this.monitoredApps,
      periodosFocoRespeitados:
          periodosFocoRespeitados ?? this.periodosFocoRespeitados,
      focusIntervalByModule:
          focusIntervalByModule ?? this.focusIntervalByModule,
      unlockedMotivationNiches:
          unlockedMotivationNiches ?? this.unlockedMotivationNiches,
      unlockedNotificationNiches:
          unlockedNotificationNiches ?? this.unlockedNotificationNiches,
    );
  }
}

class GamificationService extends StateNotifier<GamificationState> {
  final CloudSyncService _cloudSync;
  final AppMonitoringService _appMonitoring;
  final GamificationAwardEngine _awardEngine;
  final IapService _iapService;
  final UserModuleRepository _moduleRepository;

  GamificationService(
    this._cloudSync,
    this._appMonitoring,
    this._awardEngine,
    this._iapService,
    this._moduleRepository,
  ) : super(const GamificationState()) {
    _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = _cloudSync.supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final allModuleStates = await _moduleRepository.getAllModuleStates(userId);
      
      final Map<int, int> consecutiveMap = {};
      final Map<int, bool> statusMap = {};
      final Map<int, int> periodosFocoMap = {};

      for (final moduleState in allModuleStates) {
        consecutiveMap[moduleState.nicheId] = moduleState.consecutiveDays;
        statusMap[moduleState.nicheId] = moduleState.isActive;
        periodosFocoMap[moduleState.nicheId] = moduleState.focusPeriodsRespected;
      }

      state = state.copyWith(
        diasConsecutivosByModule: consecutiveMap,
        moduleStatus: statusMap,
        periodosFocoRespeitados: periodosFocoMap,
        isLoading: false,
      );

      LoggerService.instance.i('GamificationService state loaded from Isar: ${allModuleStates.length} modules');
    } catch (e) {
      LoggerService.instance.e('Error loading GamificationService state', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Getters para compatibilidade
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  Map<String, dynamic> get userStats => state.userStats;
  List<String> get pendingMedals => state.pendingMedals;
  Map<int, int> get diasConsecutivosByModule => state.diasConsecutivosByModule;
  Map<int, bool> get moduleStatus => state.moduleStatus;
  Map<int, List<String>> get scheduleByModule => state.scheduleByModule;
  Map<int, List<String>> get motivationSchedulesByModule =>
      state.motivationSchedulesByModule;
  Map<int, List<String>> get customPhrases => state.customPhrases;
  Map<NicheId, String> get customMessages => state.customMessages;
  bool get notificationsPaused => state.notificationsPaused;
  bool get isGeneralMonitoringActive => state.isGeneralMonitoringActive;
  List<String> get monitoredApps => state.monitoredApps;
  Map<int, TimeOfDayRange> get focusIntervalByModule => state.focusIntervalByModule;

  // Métodos de compatibilidade
  bool isModuleActive(dynamic nicheId) {
    if (nicheId is NicheId) return getModuleStatus(nicheId.id);
    if (nicheId is int) return getModuleStatus(nicheId);
    return false;
  }

  void addPendingMedal(String medal) {
    if (!state.pendingMedals.contains(medal)) {
      final newMedals = [...state.pendingMedals, medal];
      state = state.copyWith(pendingMedals: newMedals);
    }
  }

  void awardMedal(NicheId nicheId, GamificationMedal medal) {
    _awardEngine.awardMedal(nicheId, medal, this);
  }

  void consumePendingMedal(String medal) {
    if (state.pendingMedals.contains(medal)) {
      final newMedals = state.pendingMedals.where((m) => m != medal).toList();
      state = state.copyWith(pendingMedals: newMedals);
    }
  }

  Future<void> restoreMonitoringSession() async {
    await _appMonitoring.restoreSession();
  }

  DateTime? getModuleStartDate(int nicheId) {
    final consecutive = state.diasConsecutivosByModule[nicheId] ?? 0;
    return DateTime.now().subtract(Duration(days: consecutive));
  }

  void updateConsecutiveDaysSync(int nicheId, int days) async {
    final newMap = Map<int, int>.from(state.diasConsecutivosByModule);
    newMap[nicheId] = days;
    state = state.copyWith(diasConsecutivosByModule: newMap);
    
    // Persistir no Isar
    final userId = _cloudSync.supabase.auth.currentUser?.id;
    if (userId != null) {
      final moduleState = await _moduleRepository.getModuleState(userId, nicheId);
      if (moduleState != null) {
        await _moduleRepository.saveModuleState(moduleState.copyWith(
          consecutiveDays: days,
          updatedAt: DateTime.now(),
        ));
      }
    }
  }

  /// Retorna o ID da maior medalha para o módulo
  int maxMedalForModule(int nicheId) {
    return state.diasConsecutivosByModule[nicheId] ?? 0;
  }

  void setMaxMedal(int nicheId, int medal) {
    LoggerService.instance.i('Set max medal for module $nicheId: $medal');
  }

  bool getModuleStatus(int nicheId) {
    return state.moduleStatus[nicheId] ?? false;
  }

  bool isMotivationUnlocked(dynamic nicheId) {
    if (nicheId == null) return false;
    final int id = (nicheId is NicheId) ? nicheId.id : (nicheId as int);
    return _iapService.isMotivationPhrasesUnlocked ||
        state.unlockedMotivationNiches.contains(id);
  }

  bool isNotificationUnlocked(dynamic nicheId) {
    if (nicheId == null) return false;
    final int id = (nicheId is NicheId) ? nicheId.id : (nicheId as int);
    return _iapService.isCustomNotifUnlocked ||
        state.unlockedNotificationNiches.contains(id);
  }

  Future<void> resetMedals(
    int nicheId, {
    String? notificationTitle,
    String? notificationBody,
    bool deactivate = false,
    String? iconPath,
    bool sendNotification = true,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final newConsecutivos = Map<int, int>.from(state.diasConsecutivosByModule);
      newConsecutivos[nicheId] = 0;

      final newStatus = Map<int, bool>.from(state.moduleStatus);
      if (deactivate) {
        newStatus[nicheId] = false;
        if (state.isGeneralMonitoringActive) {
          stopMonitoringApps();
        }
      }

      state = state.copyWith(
        diasConsecutivosByModule: newConsecutivos,
        moduleStatus: newStatus,
        isLoading: false,
      );

      final niche = NicheId.values.firstWhere((e) => e.id == nicheId);
      await _cloudSync.saveModuleStatus(nicheId: niche, isActive: !deactivate);

      // Persistir no Isar via repositório
      final userId = _cloudSync.supabase.auth.currentUser?.id;
      if (userId != null) {
        if (deactivate) {
          await _moduleRepository.deactivateModule(userId, nicheId);
        } else {
          final mState = await _moduleRepository.getModuleState(userId, nicheId);
          if (mState != null) {
            await _moduleRepository.saveModuleState(mState.copyWith(
              consecutiveDays: 0,
              updatedAt: DateTime.now(),
            ));
          }
        }
      }

      if (sendNotification) {
        await NotificationService.showNotification(
          id: (nicheId * 100) + 99,
          title: notificationTitle ?? 'Medalhas Reiniciadas',
          body: notificationBody ?? 'Seu progresso neste módulo foi reiniciado.',
        );
      }

      await NotificationScheduler.instance.scheduleNativeNotifications(
        niche,
        this,
        _iapService,
      );

      LoggerService.instance
          .i('Medals reset for module $nicheId. Deactivate: $deactivate');

    } catch (e) {
      LoggerService.instance.e('Error resetting medals', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSchedule(int nicheId, List<String> schedule) {
    final newMap = Map<int, List<String>>.from(state.scheduleByModule);
    newMap[nicheId] = schedule;
    state = state.copyWith(scheduleByModule: newMap);
  }

  void setCustomMessage(dynamic nicheId, String message) {
    final NicheId id = (nicheId is int) ? NicheId.tryFromInt(nicheId)! : nicheId;
    final newMap = Map<NicheId, String>.from(state.customMessages);
    newMap[id] = message;
    state = state.copyWith(customMessages: newMap);
  }

  void setCustomPhrases(int nicheId, List<String> phrases) {
    final newMap = Map<int, List<String>>.from(state.customPhrases);
    newMap[nicheId] = phrases;
    state = state.copyWith(customPhrases: newMap);
  }

  void updateMotivationSchedule(int nicheId, List<String> schedule) {
    final newMap = Map<int, List<String>>.from(state.motivationSchedulesByModule);
    newMap[nicheId] = schedule;
    state = state.copyWith(motivationSchedulesByModule: newMap);
  }

  void startModuleCycle(int nicheId) {
    final niche = NicheId.tryFromInt(nicheId);
    if (niche == null) return;

    final newStatus = Map<int, bool>.from(state.moduleStatus);
    newStatus[nicheId] = true;
    state = state.copyWith(moduleStatus: newStatus);

    _cloudSync.saveModuleStatus(nicheId: niche, isActive: true);
    
    // Persistir no Isar
    final userId = _cloudSync.supabase.auth.currentUser?.id;
    if (userId != null) {
      _moduleRepository.activateModule(userId, nicheId);
    }

    NotificationScheduler.instance.scheduleNativeNotifications(
      niche,
      this,
      _iapService,
    );
  }

  void stopModuleCycle(int nicheId) {
    final niche = NicheId.tryFromInt(nicheId);
    if (niche == null) return;

    final newStatus = Map<int, bool>.from(state.moduleStatus);
    newStatus[nicheId] = false;
    state = state.copyWith(moduleStatus: newStatus);

    _cloudSync.saveModuleStatus(nicheId: niche, isActive: false);

    // Persistir no Isar
    final userId = _cloudSync.supabase.auth.currentUser?.id;
    if (userId != null) {
      _moduleRepository.deactivateModule(userId, nicheId);
    }

    NotificationScheduler.instance.scheduleNativeNotifications(
      niche,
      this,
      _iapService,
    );
  }

  void startMonitoringApps({
    required int nicheId,
    required List<String> apps,
    TimeOfDayRange? focusInterval,
  }) {
    final Map<int, TimeOfDayRange> newFocusIntervals =
        Map<int, TimeOfDayRange>.from(state.focusIntervalByModule);
    if (focusInterval != null) newFocusIntervals[nicheId] = focusInterval;

    state = state.copyWith(
      isGeneralMonitoringActive: true,
      monitoredApps: apps,
      focusIntervalByModule: newFocusIntervals,
    );

    final niche = NicheId.tryFromInt(nicheId);
    if (niche != null) {
      _appMonitoring.startMonitoring(nicheId: niche, apps: apps);
    }
  }

  Future<void> scheduleChallengeNotification() async {
    await NotificationScheduler.instance
        .scheduleChallengeNotification(this, _iapService);
  }

  void stopMonitoringApps() {
    state = state.copyWith(isGeneralMonitoringActive: false, monitoredApps: []);
    _appMonitoring.stopMonitoring();
  }

  void runProgressCheck([dynamic nicheId]) {
    if (nicheId == null) {
      // Check all active modules
      for (final entry in state.moduleStatus.entries) {
        if (entry.value) {
          final nid = NicheId.tryFromInt(entry.key);
          if (nid != null) {
            LoggerService.instance.i('Running progress check for $nid');
          }
        }
      }
      return;
    }
    final NicheId id = (nicheId is int) ? NicheId.tryFromInt(nicheId)! : nicheId;
    LoggerService.instance.i('Running progress check for $id');
  }

  void handleAppViolation(int nicheId) {
    final niche = NicheId.tryFromInt(nicheId);
    if (niche == null) return;

    resetMedals(
      nicheId,
      notificationTitle: 'Ops! Recaída detectada 🔴',
      notificationBody: 'Seu streak de progresso foi reiniciado. Não desista!',
    );
  }

  void unlockMotivation(dynamic nicheId) {
    final int id = (nicheId is NicheId) ? nicheId.id : (nicheId as int);
    if (!state.unlockedMotivationNiches.contains(id)) {
      state = state.copyWith(
          unlockedMotivationNiches: [...state.unlockedMotivationNiches, id]);
      LoggerService.instance.i('Motivation unlocked for niche: $id');
    }
  }

  void unlockNotification(dynamic nicheId) {
    final int id = (nicheId is NicheId) ? nicheId.id : (nicheId as int);
    if (!state.unlockedNotificationNiches.contains(id)) {
      state = state.copyWith(
          unlockedNotificationNiches: [...state.unlockedNotificationNiches, id]);
      LoggerService.instance.i('Notification unlocked for niche: $id');
    }
  }

  void setNotificationsPaused(bool paused) {
    state = state.copyWith(notificationsPaused: paused);
    _appMonitoring.setNotificationsPaused(paused);
  }

  void updateMonitoredApps(List<String> apps) {
    state = state.copyWith(monitoredApps: apps);
    if (state.isGeneralMonitoringActive) {
      final activeNiches = state.moduleStatus.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      if (activeNiches.isNotEmpty) {
        final niche = NicheId.tryFromInt(activeNiches.first);
        if (niche != null) {
          _appMonitoring.startMonitoring(nicheId: niche, apps: apps);
        }
      }
    }
  }

  Future<void> syncWithCloud() async {
    state = state.copyWith(isLoading: true);
    try {
      await _cloudSync.syncNow();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
