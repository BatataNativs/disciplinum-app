import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/gamification/domain/entities/insignia.dart';
import 'package:disciplinum/features/gamification/domain/entities/medal.dart';
import 'package:disciplinum/infrastructure/notifications/notification_scheduler.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/infrastructure/monitoring/app_monitoring_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_checkin_service.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_checkin_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';

class GamificationService extends ChangeNotifier {
  final CloudSyncService _cloudSync;
  final AppMonitoringService _appMonitoring;
  final GamificationAwardEngine _awardEngine;
  final IapService _iapService;

  GamificationService(this._cloudSync, this._appMonitoring, this._awardEngine, this._iapService) {
    _loadPreferences();
    NotificationService.onRelapseDetected = _handleRelapseFromNotification;
    NotificationService.onCheckInSim = _handleCheckInSimFromNotification;
    NotificationService.onBingeRelapseDetected =
        _handleBingeRelapseFromNotification;
    NotificationService.onBingeCheckInSim =
        _handleBingeCheckInSimFromNotification;
  }

  // Cache local
  final Map<NicheId, UserModuleStatus> _moduleStates = {};
  final Map<NicheId, String> _customMessages = {};
  final Map<NicheId, List<String>> _customPhrases = {};
  final Set<NicheId> _unlockedNotifications = {};
  final Set<NicheId> _unlockedMotivations = {};

  final List<Map<String, dynamic>> _pendingMedals = [];
  List<Map<String, dynamic>> get pendingMedals =>
      List.unmodifiable(_pendingMedals);

  final Set<FocusInsignia> _earnedFocusInsignias = {};
  Set<FocusInsignia> get earnedFocusInsignias =>
      Set.unmodifiable(_earnedFocusInsignias);

  final List<Map<String, dynamic>> _pendingInsignias = [];
  List<Map<String, dynamic>> get pendingInsignias =>
      List.unmodifiable(_pendingInsignias);

  static const String _prefsActiveNicheKey = 'active_niche_id';
  static const String _prefsModuleStatusPrefix = 'module_status_';
  static const String _prefsPendingMedalsKey = 'pending_medals';
  static const String _prefsUnlockedNotifsKey = 'unlocked_notifications';
  static const String _prefsUnlockedMotivationsKey = 'unlocked_motivations';
  static const String _prefsFocusInsigniasKey = 'focus_insignias_earned';

  // Getters Públicos para Sub-serviços e Telas
  Map<NicheId, String> get customMessages => _customMessages;
  Map<NicheId, List<String>> get customPhrases => _customPhrases;
  bool isNotificationUnlocked(NicheId niche) =>
      _unlockedNotifications.contains(niche);
  bool isMotivationUnlocked(NicheId niche) =>
      _unlockedMotivations.contains(niche);

  // Getters/Setters Delegados para AppMonitoringService
  bool get isGeneralMonitoringActive => _appMonitoring.isActive;
  Set<String> get monitoredApps =>
      Set<String>.from(_appMonitoring.monitoredApps);
  set monitoredApps(Set<String> value) {
    _appMonitoring.monitoredApps = value.toList();
    notifyListeners();
  }

  bool get notificationsPaused =>
      _appMonitoring.notificationsPaused;
  void setNotificationsPaused(bool value) {
    _appMonitoring.setNotificationsPaused(value);
    notifyListeners();
  }

  void stopMonitoringApps() {
    _appMonitoring.stopMonitoring();
    notifyListeners();
  }

  // Estado Centralizado
  NicheId? currentNicheId;
  Map<NicheId, List<TimeOfDay>> scheduleByModule = {};
  Map<NicheId, List<TimeOfDay>> motivationSchedulesByModule = {};
  Map<NicheId, TimeOfDayRange> focusIntervalByModule = {};
  Map<NicheId, int> get diasConsecutivosByModule =>
      _moduleStates.map((k, v) => MapEntry(k, v.consecutiveDays));
  Map<NicheId, int> get periodosFocoRespeitados =>
      _moduleStates.map((k, v) => MapEntry(k, v.focusPeriodsRespected ?? 0));

  Map<NicheId, String> get medalsByModule => _moduleStates.map((k, v) {
        final m = maxMedalForModule(k);
        return MapEntry(k, m?.nameBr ?? '');
      })
        ..removeWhere((k, v) => v.isEmpty);
  bool isModuleActive(NicheId nicheId) =>
      _moduleStates.containsKey(nicheId) && _moduleStates[nicheId]!.isActive;

  // Handlers de Notificação
  void _handleRelapseFromNotification(String? payload) {
    if (payload?.startsWith('medal_ack') ?? false) return;
    NicheId? nicheId = payload != null
        ? NicheId.values.firstWhere((e) => e.id.toString() == payload,
            orElse: () => NicheId.smoking)
        : currentNicheId;
    if (nicheId == NicheId.smoking) {
      SmokingCheckinService().clearAllCheckins();
      resetMedals(nicheId!,
          notificationTitle: 'Módulo Desativado 🛑', deactivate: true);
    }
  }

  void _handleBingeRelapseFromNotification(String? payload) {
    if (payload == 'binge_checkin') {
      BingeEatingCheckinService().clearAllCheckins();
      resetMedals(NicheId.bingeEating,
          notificationTitle: 'Módulo Desativado 🛑', deactivate: true);
    }
  }

  void _handleBingeCheckInSimFromNotification(String? payload) =>
      BingeEatingCheckinService().recordCheckin();
  void _handleCheckInSimFromNotification(String? payload) =>
      SmokingCheckinService().recordCheckin();

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _appMonitoring.notificationsPaused =
        prefs.getBool('settings_notifications_paused') ?? false;

    for (final niche in NicheId.values) {
      final msg = prefs.getString('custom_msg_${niche.id}');
      if (msg != null) _customMessages[niche] = msg;
      final phrases = prefs.getStringList('custom_phrases_${niche.id}');
      if (phrases != null) _customPhrases[niche] = phrases;
    }

    final unlockedIds = prefs.getStringList(_prefsUnlockedNotifsKey) ?? [];
    for (var id in unlockedIds) {
      final nid = NicheId.tryFromInt(int.parse(id));
      if (nid != null) _unlockedNotifications.add(nid);
    }

    final unlockedMotivsIds =
        prefs.getStringList(_prefsUnlockedMotivationsKey) ?? [];
    for (var id in unlockedMotivsIds) {
      final nid = NicheId.tryFromInt(int.parse(id));
      if (nid != null) _unlockedMotivations.add(nid);
    }

    final pendingJson = prefs.getString(_prefsPendingMedalsKey);
    if (pendingJson != null) {
      try {
        _pendingMedals
            .addAll(jsonDecode(pendingJson).cast<Map<String, dynamic>>());
      } catch (_) {}
    }

    final insigniasList = prefs.getStringList(_prefsFocusInsigniasKey) ?? [];
    for (var name in insigniasList) {
      try {
        _earnedFocusInsignias
            .add(FocusInsignia.values.firstWhere((e) => e.name == name));
      } catch (_) {}
    }

    notifyListeners();
    await _restoreAllActiveModules();
    await restoreMonitoringSession();
  }

  Future<void> _restoreAllActiveModules() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('seen_onboarding') ?? false)) return;

    for (final nicheId in NicheId.values) {
      await _syncWithCloud(nicheId);
      if (isModuleActive(nicheId)) {
        final times =
            await _cloudSync.loadUserNicheTimes(nicheId: nicheId.id);
        if (times.isNotEmpty) {
          scheduleByModule[nicheId] = times
              .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
              .toList();
        }

        final motivTimes = await _cloudSync.loadUserNicheTimes(
            nicheId: nicheId.id + 100);
        if (motivTimes.isNotEmpty) {
          motivationSchedulesByModule[nicheId] = motivTimes
              .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
              .toList();
          final phrases = motivTimes
              .map((t) => t.phrase ?? '')
              .where((p) => p.isNotEmpty)
              .toList();
          if (phrases.isNotEmpty) _customPhrases[nicheId] = phrases;
        }
        await NotificationScheduler.instance
            .scheduleNativeNotifications(nicheId, this, _iapService);

        // REMOVIDO: reconcileFocusInsignias estava concedendo múltiplas insígnias
        // Agora as insígnias são concedidas apenas quando os critérios são atingidos
      }
    }
  }

  Future<void> restoreMonitoringSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('seen_onboarding') ?? false)) return;
    await _appMonitoring.restoreSession();
    final savedId = prefs.getInt(_prefsActiveNicheKey);
    if (savedId != null) {
      final nicheId = NicheId.tryFromInt(savedId);
      if (nicheId != null) {
        currentNicheId = nicheId;
        await _syncWithCloud(nicheId);
      }
    }
  }

  // Sincronização e Cloud
  Future<void> _syncWithCloud(NicheId nicheId) async {
    final cloud = await _cloudSync.loadModuleStatus(nicheId);
    final local = await _getLocalStatus(nicheId);
    UserModuleStatus? status = (local != null &&
            (local.lastUpdated?.isAfter(cloud?.lastUpdated ?? DateTime(2000)) ??
                false))
        ? local
        : cloud;

    if (status != null) {
      if (!status.isActive) {
        if (_moduleStates.containsKey(nicheId)) _moduleStates.remove(nicheId);
      } else {
        _moduleStates[nicheId] = status;

        // NOVO: Carregar períodos de foco respeitados

        if (status.maxMedal != null) {}
        _awardEngine.checkTimeBasedMedals(nicheId, this);
      }
      _saveLocalStatus(nicheId);
    }
  }

  Future<void> refreshAllDataFromCloud() async {
    for (final niche in NicheId.values) {
      await _syncWithCloud(niche);
    }
    notifyListeners();
  }

  // API Pública para Telas
  Future<void> startModuleCycle({required NicheId nicheId}) async {
    currentNicheId = nicheId;
    await _syncWithCloud(nicheId);

    if (!isModuleActive(nicheId)) {
      _ensureStateExistsAnd(nicheId, consecutiveDays: 0);

      // NOVO: Inicializar períodos de foco para módulo Foco
      if (nicheId == NicheId.focus) {
        _ensureStateExistsAnd(nicheId, focusPeriodsRespected: 0);
        // Conceder insígnia de madeira imediatamente ao ativar o módulo
        await _awardEngine.awardMadeiraOnActivation(this);
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsActiveNicheKey, nicheId.id);
    await _saveLocalStatus(nicheId);
    _cloudSync.saveModuleStatus(
            nicheId: nicheId,
            isActive: true,
            consecutiveDays: _moduleStates[nicheId]?.consecutiveDays ?? 0,
            focusPeriodsRespected: nicheId == NicheId.focus
                ? _moduleStates[nicheId]?.focusPeriodsRespected
                : null) // NOVO: Incluir períodos de foco
        .catchError((e) => LoggerService.instance.e('Erro Sync startModuleCycle', error: e));
    await NotificationScheduler.instance
        .scheduleNativeNotifications(nicheId, this, _iapService);

    // Força checagem imediata para premiar insígnias de "Dia 0" (ex: Ferro)
    await _awardEngine.checkTimeBasedMedals(nicheId, this);

    notifyListeners();
  }

  Future<void> stopModuleCycle({required NicheId nicheId}) async {
    if (currentNicheId == nicheId) {
      currentNicheId = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsActiveNicheKey);
      stopMonitoringApps();
    }

    // CORREÇÃO: Limpeza completa de estado órfão
    if (_moduleStates.containsKey(nicheId)) _moduleStates.remove(nicheId);

    scheduleByModule.remove(nicheId);
    motivationSchedulesByModule.remove(nicheId);
    focusIntervalByModule.remove(nicheId);

    await _saveLocalStatus(nicheId);
    _cloudSync.saveModuleStatus(
      nicheId: nicheId,
      isActive: false,
      consecutiveDays: 0,
      focusPeriodsRespected: nicheId == NicheId.focus ? 0 : null,
      forceClearMedal: true,
    );

    await NotificationScheduler.instance.cancelModuleNotifications(nicheId);
    notifyListeners();
  }

  Future<void> resetMedals(NicheId nicheId,
      {String? notificationTitle,
      String? notificationBody,
      bool deactivate = false,
      String? iconPath,
      bool sendNotification = true}) async {
    if (deactivate) {
      if (_moduleStates.containsKey(nicheId)) _moduleStates.remove(nicheId);

      if (nicheId == NicheId.focus) {
        resetFocusInsignias();
      }
      if (currentNicheId == nicheId) stopMonitoringApps();
    } else {
      _ensureStateExistsAnd(nicheId, consecutiveDays: 0);

      // CORRIGIDO: Resetar TUDO em violações (períodos + insígnias)
      if (nicheId == NicheId.focus) {
        resetFocusPeriods(nicheId);
        resetFocusInsignias(); // Resetar insígnias também!
      }
    }
    await _saveLocalStatus(nicheId);
    _cloudSync.saveModuleStatus(
            nicheId: nicheId,
            isActive: !deactivate,
            consecutiveDays: 0,
            focusPeriodsRespected: nicheId == NicheId.focus
                ? 0
                : null, // Resetar períodos no cloud também
            forceClearMedal: true)
        .catchError((e) => LoggerService.instance.e('Erro Sync Cloud', error: e));

    if (sendNotification) {
      await sendModuleNotification(notificationBody ?? 'Progresso resetado.',
          title: notificationTitle ?? 'Aviso', iconPath: iconPath);
    }

    if (deactivate) {
      await NotificationScheduler.instance.cancelModuleNotifications(nicheId);
    }
    notifyListeners();
  }

  // Popup e UI
  void consumePendingMedal(Map<String, dynamic> medal) {
    _pendingMedals.remove(medal);
    _savePendingMedals();
    notifyListeners();
  }

  void consumePendingInsignia(Map<String, dynamic> insignia) {
    _pendingInsignias.remove(insignia);
    notifyListeners();
  }

  void addPendingMedal(Map<String, dynamic> medal) {
    if (!_pendingMedals.any((m) => m['medal_name'] == medal['medal_name'])) {
      _pendingMedals.add(medal);
      _savePendingMedals();
      notifyListeners();
    }
  }

  void addPendingInsignia(Map<String, dynamic> insignia) {
    _pendingInsignias.add(insignia);
    notifyListeners();
  }

  // Ad Desbloqueios
  Future<void> unlockNotification(NicheId nicheId) async {
    await _applyLocalUnlockNotification(nicheId);
    await _cloudSync.addEntitlement(
            entitlementType: 'notification', nicheId: nicheId.id, source: 'ad')
        .catchError((e) => LoggerService.instance.e('Sync Ad Error', error: e));
    notifyListeners();
  }

  Future<void> unlockMotivation(NicheId nicheId) async {
    await _applyLocalUnlockMotivation(nicheId);
    await _cloudSync.addEntitlement(
            entitlementType: 'motivation', nicheId: nicheId.id, source: 'ad')
        .catchError((e) => LoggerService.instance.e('Sync Ad Motivation Error', error: e));
    notifyListeners();
  }

  // Métodos privados para controle local vs remoto
  Future<void> _applyLocalUnlockNotification(NicheId nicheId) async {
    if (_unlockedNotifications.contains(nicheId)) return;
    _unlockedNotifications.add(nicheId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsUnlockedNotifsKey,
        _unlockedNotifications.map((n) => n.id.toString()).toList());
  }

  Future<void> _applyLocalUnlockMotivation(NicheId nicheId) async {
    if (_unlockedMotivations.contains(nicheId)) return;
    _unlockedMotivations.add(nicheId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsUnlockedMotivationsKey,
        _unlockedMotivations.map((n) => n.id.toString()).toList());
  }

  // Métodos públicos para sincronização da nuvem (sem regravar na nuvem)
  Future<void> syncUnlockNotificationFromCloud(NicheId nicheId) async {
    await _applyLocalUnlockNotification(nicheId);
    notifyListeners();
  }

  Future<void> syncUnlockMotivationFromCloud(NicheId nicheId) async {
    await _applyLocalUnlockMotivation(nicheId);
    notifyListeners();
  }

  // Customizações
  Future<void> setCustomMessage(NicheId nicheId, String message) async {
    _customMessages[nicheId] = message;
    (await SharedPreferences.getInstance())
        .setString('custom_msg_${nicheId.id}', message);
    notifyListeners();
  }

  Future<void> setCustomPhrases(NicheId nicheId, List<String> phrases) async {
    _customPhrases[nicheId] = phrases;
    (await SharedPreferences.getInstance())
        .setStringList('custom_phrases_${nicheId.id}', phrases);
    notifyListeners();
  }

  // Gamification Engine Interface
  void updateConsecutiveDaysSync(NicheId nicheId, int days) {
    _ensureStateExistsAnd(nicheId, consecutiveDays: days);
    _saveLocalStatus(nicheId);
    _cloudSync.saveModuleStatus(
            nicheId: nicheId, isActive: true, consecutiveDays: days)
        .catchError((e) => LoggerService.instance.e('Erro Sync updateConsecutiveDays', error: e));
    notifyListeners();
  }

  void _ensureStateExistsAnd(NicheId nicheId,
      {int? consecutiveDays, int? focusPeriodsRespected, String? maxMedal}) {
    final user = Supabase.instance.client.auth.currentUser;
    final exist = _moduleStates[nicheId];
    _moduleStates[nicheId] = UserModuleStatus(
        userId: user?.id ?? 'local',
        nicheId: nicheId.id,
        isActive: true,
        consecutiveDays: consecutiveDays ?? exist?.consecutiveDays ?? 0,
        focusPeriodsRespected:
            focusPeriodsRespected ?? exist?.focusPeriodsRespected,
        maxMedal: maxMedal ?? exist?.maxMedal,
        lastUpdated: DateTime.now(),
        earnedInsignias: exist?.earnedInsignias ?? []);
  }

  // NOVOS: Métodos para períodos de foco respeitados
  Future<void> addRespectedFocusPeriod(NicheId nicheId) async {
    final current = _moduleStates[nicheId]?.focusPeriodsRespected ?? 0;
    final updated = current + 1;
    
    // CORREÇÃO: Verificar se já foi incrementado para evitar duplicação
    if (_moduleStates[nicheId]?.focusPeriodsRespected == updated) {
      return; // Já foi incrementado, evitar duplicação
    }
    
    _ensureStateExistsAnd(nicheId, focusPeriodsRespected: updated);
    await _saveLocalStatus(nicheId);

    // CORREÇÃO: Sincronizar com cloud
    await _cloudSync.saveModuleStatus(
      nicheId: nicheId,
      isActive: true,
      consecutiveDays: _moduleStates[nicheId]?.consecutiveDays ?? 0,
      focusPeriodsRespected: updated,
      maxMedal: _moduleStates[nicheId]?.maxMedal,
    );
    
    notifyListeners();
    await _awardEngine.checkFocusInsigniasByPeriods(nicheId, this);
  }

  Future<void> resetFocusPeriods(NicheId nicheId) async {
    await _saveLocalStatus(nicheId);

    // CORREÇÃO OBRIGATÓRIA: Sincronizar com cloud
    await _cloudSync.saveModuleStatus(
      nicheId: nicheId,
      isActive: isModuleActive(nicheId),
      consecutiveDays: _moduleStates[nicheId]?.consecutiveDays ?? 0,
      focusPeriodsRespected: 0,
      maxMedal: _moduleStates[nicheId]?.maxMedal,
    );

    // NOVO: Verificar insígnias ao resetar períodos
    await _awardEngine.checkFocusInsigniasByPeriods(nicheId, this);

    notifyListeners();
  }

  int getRespectedFocusPeriods(NicheId nicheId) =>
      _moduleStates[nicheId]?.focusPeriodsRespected ?? 0;

  void setMaxMedal(NicheId nicheId, GamificationMedal medal) {
    _ensureStateExistsAnd(nicheId, maxMedal: medal.name);
    _saveLocalStatus(nicheId);
    _cloudSync.saveModuleStatus(
            nicheId: nicheId, isActive: true, maxMedal: medal.name)
        .catchError((e) => LoggerService.instance.e('Erro Sync setMaxMedal', error: e));
  }

  GamificationMedal? maxMedalForModule(NicheId nicheId) {
    var raw = _moduleStates[nicheId]?.maxMedal;
    if (raw == null) return null;
    try {
      return GamificationMedal.values.firstWhere((m) => m.name == raw);
    } catch (_) {
      return null;
    }
  }

  DateTime? getModuleStartDate(NicheId nicheId) => _moduleStates[nicheId]
      ?.lastUpdated
      ?.subtract(Duration(days: _moduleStates[nicheId]?.consecutiveDays ?? 0));
  void awardMedal(NicheId nicheId, GamificationMedal medal) =>
      _awardEngine.awardMedal(nicheId, medal, this);

  // Foco e Insígnias
  void awardInsignia(FocusInsignia insignia) async {
    if (_earnedFocusInsignias.contains(insignia)) return;
    _earnedFocusInsignias.add(insignia);
    await _saveFocusInsignias();
    _pendingInsignias.add({
      'type': 'focus_insignia',
      'insignia_name': insignia.nameBr
          .split(' ')
          .last, // CORRIGIDO: Pega apenas "Madeira", "Ferro", etc.
      'insignia_key': insignia.name,
      'insignia_asset': insignia.asset
    });
    notifyListeners();
  }

  void addEarnedFocusInsignia(FocusInsignia insignia) =>
      _earnedFocusInsignias.add(insignia);
  void resetFocusInsignias() {
    // Preserva a insígnia de Madeira — ela é permanente (concedida na primeira ativação)
    final hadMadeira = _earnedFocusInsignias.contains(FocusInsignia.madeira);
    _earnedFocusInsignias.clear();
    if (hadMadeira) {
      _earnedFocusInsignias.add(FocusInsignia.madeira);
    }
    resetFocusPeriods(NicheId.focus);
    _saveFocusInsignias();
    notifyListeners();
  }

  Future<void> saveFocusInsignias() async =>
      (await SharedPreferences.getInstance()).setStringList(
          _prefsFocusInsigniasKey,
          _earnedFocusInsignias.map((e) => e.name).toList());
  Future<void> _saveFocusInsignias() async => saveFocusInsignias();

  // Utilitários
  Future<void> _savePendingMedals() async =>
      (await SharedPreferences.getInstance())
          .setString(_prefsPendingMedalsKey, jsonEncode(_pendingMedals));

  Future<void> _saveLocalStatus(NicheId nicheId) async {
    final prefs = await SharedPreferences.getInstance();
    final user = Supabase.instance.client.auth.currentUser;
    final status = UserModuleStatus(
      userId: user?.id ?? 'local',
      nicheId: nicheId.id,
      isActive: isModuleActive(nicheId),
      consecutiveDays: _moduleStates[nicheId]?.consecutiveDays ?? 0,
      focusPeriodsRespected: nicheId == NicheId.focus
          ? _moduleStates[nicheId]?.focusPeriodsRespected
          : null, // NOVO: Salvar períodos de foco apenas para módulo Foco
      lastUpdated: DateTime.now(),
      earnedInsignias: nicheId == NicheId.focus
          ? _earnedFocusInsignias.map((e) => e.name).toList()
          : [],
    );
    await prefs.setString(
        '$_prefsModuleStatusPrefix${nicheId.id}', jsonEncode(status.toJson()));
  }

  Future<UserModuleStatus?> _getLocalStatus(NicheId nicheId) async {
    final json = (await SharedPreferences.getInstance())
        .getString('$_prefsModuleStatusPrefix${nicheId.id}');
    return json != null ? UserModuleStatus.fromJson(jsonDecode(json)) : null;
  }

  /// Retorna o status atual do módulo (método público)
  Future<UserModuleStatus?> getModuleStatus(NicheId nicheId) async {
    // Primeiro tenta do cache
    if (_moduleStates.containsKey(nicheId)) {
      return _moduleStates[nicheId];
    }
    
    // Se não estiver no cache, tenta carregar do localStorage
    final localStatus = await _getLocalStatus(nicheId);
    if (localStatus != null) {
      _moduleStates[nicheId] = localStatus;
      return localStatus;
    }
    
    // Se não encontrar, retorna null
    return null;
  }

  Future<void> sendModuleNotification(String body,
      {String? title, String? iconPath}) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    const androidDetails = AndroidNotificationDetails(
        'module_updates', 'Atualizações',
        importance: Importance.high, priority: Priority.high);

    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title ?? 'Aviso',
      body,
      details,
    );
  }

  Future<void> runProgressCheck() async {
    for (final nid in List<NicheId>.from(_moduleStates.keys)) {
      final now = DateTime.now();
      if (_lastMidnightCheckByModule[nid]?.day != now.day) {
        _lastMidnightCheckByModule[nid] = now;
        await _awardEngine.checkTimeBasedMedals(nid, this);
      }
    }
  }

  final Map<NicheId, DateTime> _lastMidnightCheckByModule = {};

  Future<void> startMonitoringApps(
      {NicheId? nicheId,
      List<TimeOfDay>? horarios,
      TimeOfDayRange? intervaloFoco}) async {
    if (nicheId != null) {
      currentNicheId = nicheId;
      if (horarios != null) scheduleByModule[nicheId] = horarios;
      if (intervaloFoco != null) focusIntervalByModule[nicheId] = intervaloFoco;
      await _appMonitoring.startMonitoring(nicheId: nicheId, apps: monitoredApps.toList());
      await NotificationScheduler.instance
          .scheduleNativeNotifications(nicheId, this, _iapService);
    }
  }

  Future<void> scheduleChallengeNotification() async {
    await NotificationScheduler.instance.scheduleChallengeNotification(this, _iapService);
  }

  bool historyFocusInterval(NicheId? nicheId, DateTime now) {
    if (nicheId == null || focusIntervalByModule[nicheId] == null) {
      return nicheId != NicheId.focus;
    }
    final foco = focusIntervalByModule[nicheId]!;
    final minsNow = now.hour * 60 + now.minute;
    final minsIni = foco.start.hour * 60 + foco.start.minute;
    final minsFim = foco.end.hour * 60 + foco.end.minute;
    return minsIni > minsFim
        ? (minsNow >= minsIni || minsNow <= minsFim)
        : (minsNow >= minsIni && minsNow <= minsFim);
  }
}

class TimeOfDayRange {
  final TimeOfDay start;
  final TimeOfDay end;
  TimeOfDayRange({required this.start, required this.end});
}
