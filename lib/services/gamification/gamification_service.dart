import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/models/user_module_status.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/gamification/insignia.dart';
import 'package:disciplinum/models/gamification/medal.dart';
import 'package:disciplinum/services/gamification/notification_scheduler.dart';
import 'package:disciplinum/services/gamification/gamification_award_engine.dart';
import 'package:disciplinum/services/gamification/app_monitoring_service.dart';
import 'package:disciplinum/services/1_smoking/smoking_checkin_service.dart';
import 'package:disciplinum/services/2_bingeEating/binge_eating_checkin_service.dart';

class GamificationService extends ChangeNotifier {
  static final GamificationService _instance = GamificationService._internal();
  static GamificationService get instance => _instance;
  factory GamificationService() => _instance;

  GamificationService._internal() {
    _loadPreferences();
    NotificationService.onRelapseDetected = _handleRelapseFromNotification;
    NotificationService.onCheckInSim = _handleCheckInSimFromNotification;
    NotificationService.onBingeRelapseDetected =
        _handleBingeRelapseFromNotification;
    NotificationService.onBingeCheckInSim =
        _handleBingeCheckInSimFromNotification;
  }

  // Cache local
  final Map<NicheId, GamificationMedal> _maxMedalByModule = {};
  final Map<NicheId, int> _diasConsecutivosByModule = {};
  final Map<NicheId, DateTime> _moduleStartDates = {};
  final Map<NicheId, int> _periodosFocoRespeitados = {}; // NOVO: Contador de períodos de foco respeitados
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
  bool get isGeneralMonitoringActive => AppMonitoringService.instance.isActive;
  List<String> get monitoredApps => AppMonitoringService.instance.monitoredApps;
  set monitoredApps(List<String> value) {
    AppMonitoringService.instance.monitoredApps = value;
    notifyListeners();
  }

  bool get notificationsPaused =>
      AppMonitoringService.instance.notificationsPaused;
  void setNotificationsPaused(bool value) {
    AppMonitoringService.instance.setNotificationsPaused(value);
    notifyListeners();
  }

  void stopMonitoringApps() {
    AppMonitoringService.instance.stopMonitoring();
    notifyListeners();
  }

  // Estado Centralizado
  NicheId? currentNicheId;
  Map<NicheId, List<TimeOfDay>> scheduleByModule = {};
  Map<NicheId, List<TimeOfDay>> motivationSchedulesByModule = {};
  Map<NicheId, TimeOfDayRange> focusIntervalByModule = {};
  Map<NicheId, int> get diasConsecutivosByModule => _diasConsecutivosByModule;
  Map<NicheId, int> get periodosFocoRespeitados => _periodosFocoRespeitados; // NOVO: Getter para períodos de foco respeitados

  Map<NicheId, String> get medalsByModule =>
      _maxMedalByModule.map((k, v) => MapEntry(k, v.nameBr));
  bool isModuleActive(NicheId nicheId) =>
      _diasConsecutivosByModule.containsKey(nicheId);

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
    AppMonitoringService.instance.notificationsPaused =
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
  }

  Future<void> _restoreAllActiveModules() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('seen_onboarding') ?? false)) return;

    for (final nicheId in NicheId.values) {
      await _syncWithCloud(nicheId);
      if (isModuleActive(nicheId)) {
        final times =
            await CloudSyncService.loadUserNicheTimes(nicheId: nicheId.id);
        if (times.isNotEmpty) {
          scheduleByModule[nicheId] = times
              .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
              .toList();
        }

        final motivTimes = await CloudSyncService.loadUserNicheTimes(
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
            .scheduleNativeNotifications(nicheId, this);
      }
    }
  }

  Future<void> restoreMonitoringSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('seen_onboarding') ?? false)) return;
    await AppMonitoringService.instance.restoreSession();
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
    final cloud = await CloudSyncService.loadModuleStatus(nicheId);
    final local = await _getLocalStatus(nicheId);
    UserModuleStatus? status = (local != null &&
            (local.lastUpdated?.isAfter(cloud?.lastUpdated ?? DateTime(2000)) ??
                false))
        ? local
        : cloud;

    if (status != null) {
      if (!status.isActive) {
        _diasConsecutivosByModule.remove(nicheId);
        _maxMedalByModule.remove(nicheId);
        _moduleStartDates.remove(nicheId);
        if (nicheId == NicheId.focus) _periodosFocoRespeitados.remove(nicheId); // NOVO
      } else {
        _diasConsecutivosByModule[nicheId] = status.consecutiveDays;
        _moduleStartDates[nicheId] = (status.lastUpdated ?? DateTime.now())
            .subtract(Duration(days: status.consecutiveDays));
        
        // NOVO: Carregar períodos de foco respeitados
        if (nicheId == NicheId.focus && status.focusPeriodsRespected != null) {
          _periodosFocoRespeitados[nicheId] = status.focusPeriodsRespected!;
        }
        
        if (status.maxMedal != null) {
          try {
            _maxMedalByModule[nicheId] = GamificationMedal.values
                .firstWhere((m) => m.name == status.maxMedal);
          } catch (_) {}
        }
        GamificationAwardEngine.instance.checkTimeBasedMedals(nicheId, this);
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
      _diasConsecutivosByModule[nicheId] = 0;
      _moduleStartDates[nicheId] = DateTime.now();
      
      // NOVO: Inicializar períodos de foco para módulo Foco
      if (nicheId == NicheId.focus) {
        _periodosFocoRespeitados[nicheId] = 0;
        // Conceder insígnia de madeira imediatamente
        GamificationAwardEngine.instance.checkFocusInsigniasByPeriods(nicheId, this);
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsActiveNicheKey, nicheId.id);
    await _saveLocalStatus(nicheId);
    CloudSyncService.saveModuleStatus(
        nicheId: nicheId,
        isActive: true,
        consecutiveDays: _diasConsecutivosByModule[nicheId] ?? 0,
        focusPeriodsRespected: nicheId == NicheId.focus 
            ? _periodosFocoRespeitados[nicheId] 
            : null); // NOVO: Incluir períodos de foco
    await NotificationScheduler.instance
        .scheduleNativeNotifications(nicheId, this);

    // Força checagem imediata para premiar insígnias de "Dia 0" (ex: Ferro)
    GamificationAwardEngine.instance.checkTimeBasedMedals(nicheId, this);

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
    _diasConsecutivosByModule.remove(nicheId);
    _maxMedalByModule.remove(nicheId);
    _moduleStartDates.remove(nicheId);
    _periodosFocoRespeitados.remove(nicheId);
    scheduleByModule.remove(nicheId);
    motivationSchedulesByModule.remove(nicheId);
    focusIntervalByModule.remove(nicheId);

    await _saveLocalStatus(nicheId);
    CloudSyncService.saveModuleStatus(
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
      _diasConsecutivosByModule.remove(nicheId);
      _maxMedalByModule.remove(nicheId);
      if (nicheId == NicheId.focus) {
        resetFocusInsignias(); // Já chama resetFocusPeriods() internamente
      }
      if (currentNicheId == nicheId) stopMonitoringApps();
    } else {
      _diasConsecutivosByModule[nicheId] = 0;
      _moduleStartDates[nicheId] = DateTime.now();
      // CORRIGIDO: Resetar TUDO em violações (períodos + insígnias)
      if (nicheId == NicheId.focus) {
        resetFocusPeriods(nicheId);
        resetFocusInsignias(); // Resetar insígnias também!
      }
    }
    await _saveLocalStatus(nicheId);
    CloudSyncService.saveModuleStatus(
            nicheId: nicheId,
            isActive: !deactivate,
            consecutiveDays: 0,
            focusPeriodsRespected: nicheId == NicheId.focus ? 0 : null, // Resetar períodos no cloud também
            forceClearMedal: true)
        .catchError((e) => debugPrint('Erro Sync Cloud: $e'));

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
    await CloudSyncService.addEntitlement(
      entitlementType: 'notification', nicheId: nicheId.id, source: 'ad')
        .catchError((e) => debugPrint('Sync Ad Error: $e'));
    notifyListeners();
  }

  Future<void> unlockMotivation(NicheId nicheId) async {
    await _applyLocalUnlockMotivation(nicheId);
    await CloudSyncService.addEntitlement(
      entitlementType: 'motivation', nicheId: nicheId.id, source: 'ad')
        .catchError((e) => debugPrint('Sync Ad Motivation Error: $e'));
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
  void updateConsecutiveDays(NicheId nicheId, int days) {
    _diasConsecutivosByModule[nicheId] = days;
    _saveLocalStatus(nicheId);
    CloudSyncService.saveModuleStatus(
        nicheId: nicheId, isActive: true, consecutiveDays: days);
    notifyListeners();
  }

  // NOVOS: Métodos para períodos de foco respeitados
  void addRespectedFocusPeriod(NicheId nicheId) {
    final current = _periodosFocoRespeitados[nicheId] ?? 0;
    final updated = current + 1;
    _periodosFocoRespeitados[nicheId] = updated;
    _saveLocalStatus(nicheId);
    
    // CORREÇÃO: Sincronizar com cloud
    CloudSyncService.saveModuleStatus(
      nicheId: nicheId,
      isActive: true,
      consecutiveDays: _diasConsecutivosByModule[nicheId] ?? 0,
      focusPeriodsRespected: updated,
      maxMedal: _maxMedalByModule[nicheId]?.name,
    );
    
    notifyListeners();
    GamificationAwardEngine.instance.checkFocusInsigniasByPeriods(nicheId, this);
  }

  void resetFocusPeriods(NicheId nicheId) {
    _periodosFocoRespeitados.remove(nicheId);
    _saveLocalStatus(nicheId);

    // CORREÇÃO OBRIGATÓRIA: Sincronizar com cloud
    CloudSyncService.saveModuleStatus(
      nicheId: nicheId,
      isActive: isModuleActive(nicheId),
      consecutiveDays: _diasConsecutivosByModule[nicheId] ?? 0,
      focusPeriodsRespected: 0,
      maxMedal: _maxMedalByModule[nicheId]?.name,
    );

    notifyListeners();
  }

  int getRespectedFocusPeriods(NicheId nicheId) => 
      _periodosFocoRespeitados[nicheId] ?? 0;

  void setMaxMedal(NicheId nicheId, GamificationMedal medal) {
    _maxMedalByModule[nicheId] = medal;
    _saveLocalStatus(nicheId);
    CloudSyncService.saveModuleStatus(
        nicheId: nicheId, isActive: true, maxMedal: medal.name);
  }

  GamificationMedal? maxMedalForModule(NicheId nicheId) =>
      _maxMedalByModule[nicheId];
  DateTime? getModuleStartDate(NicheId nicheId) => _moduleStartDates[nicheId];
  void awardMedal(NicheId nicheId, GamificationMedal medal) =>
      GamificationAwardEngine.instance.awardMedal(nicheId, medal, this);

  // Foco e Insígnias
  void awardInsignia(FocusInsignia insignia) async {
    if (_earnedFocusInsignias.contains(insignia)) return;
    _earnedFocusInsignias.add(insignia);
    await _saveFocusInsignias();
    _pendingInsignias.add({
      'type': 'focus_insignia',
      'insignia_name': insignia.nameBr.split(' ').last, // CORRIGIDO: Pega apenas "Madeira", "Ferro", etc.
      'insignia_key': insignia.name,
      'insignia_asset': insignia.asset
    });
    notifyListeners();
  }

  void addEarnedFocusInsignia(FocusInsignia insignia) =>
      _earnedFocusInsignias.add(insignia);
  void resetFocusInsignias() {
    _earnedFocusInsignias.clear();
    resetFocusPeriods(NicheId.focus); // NOVO: Resetar períodos de foco também
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
      consecutiveDays: _diasConsecutivosByModule[nicheId] ?? 0,
      focusPeriodsRespected: nicheId == NicheId.focus 
          ? _periodosFocoRespeitados[nicheId] 
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

  Future<void> sendModuleNotification(String body,
      {String? title, String? iconPath}) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    const androidDetails = AndroidNotificationDetails(
      'module_updates', 'Atualizações',
      importance: Importance.high, 
      priority: Priority.high
    );
  
    const details = NotificationDetails(android: androidDetails);
  
    await flutterLocalNotificationsPlugin.show(
      id,
      title ?? 'Aviso', 
      body,
      details,
    );
  }

  void runProgressCheck() {
    for (final nid in List<NicheId>.from(_diasConsecutivosByModule.keys)) {
      final now = DateTime.now();
      if (_lastMidnightCheckByModule[nid]?.day != now.day) {
        _lastMidnightCheckByModule[nid] = now;
        GamificationAwardEngine.instance.checkTimeBasedMedals(nid, this);
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
      await AppMonitoringService.instance
          .startMonitoring(nicheId: nicheId, apps: monitoredApps);
      await NotificationScheduler.instance
          .scheduleNativeNotifications(nicheId, this);
    }
  }

  Future<void> scheduleChallengeNotification() async {
    await NotificationScheduler.instance.scheduleChallengeNotification(this);
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
