import 'dart:async';

import 'package:flutter/material.dart';

import 'package:usage_stats/usage_stats.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:disciplinum/models/niche_id.dart';

import 'package:disciplinum/models/niche.dart';

import 'package:disciplinum/services/gamification/gamification_service.dart';

import 'package:disciplinum/services/gamification/gamification_messages.dart';

import 'package:disciplinum/services/iap/iap_service.dart';

import 'package:disciplinum/services/permissions/notifications/notification_service.dart';



class AppMonitoringService {

  static final AppMonitoringService _instance =

      AppMonitoringService._internal();

  static AppMonitoringService get instance => _instance;



  AppMonitoringService._internal();



  // ID para a notificação persistente (Serviço de Primeiro Plano)

  static const int _foregroundServiceId = 888;

  static const String _prefsActiveNicheKey = 'active_niche_id';

  static const String _prefsMonitoredAppsKey = 'active_monitored_apps';

  static const String _prefsNotificationsPausedKey = 'settings_notifications_paused';

  static const String _prefsLastHeartbeatKey = 'last_heartbeat';



  bool _isModuleActive = false;

  Timer? _monitorTimer;

  List<String> monitoredApps = [];

  bool notificationsPaused = false;



  // Event processing enterprise

  final EventProcessor _eventProcessor = EventProcessor();

  final EventBuffer _eventBuffer = EventBuffer();

  final PerformanceMonitor _perfMonitor = PerformanceMonitor();

  final StateManager _stateManager = StateManager();



  // Enhanced state

  String? _currentForegroundApp;



  // Constants

  static const int _violationTimeoutSeconds = 30;



  // Legacy state (maintained for compatibility)

  final Map<String, DateTime> _violationStartByApp = {};

  final Map<String, DateTime> _warnedApps = {};

  final Map<String, DateTime> _lastSeenMonitoredApp = {};

  DateTime _lastHeartbeatSave = DateTime.fromMillisecondsSinceEpoch(0);

  NicheId? currentNicheId;



  bool get isActive => _isModuleActive;



  void setNotificationsPaused(bool value) async {

    notificationsPaused = value;

    if (value) {

      _clearViolationState();

    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_prefsNotificationsPausedKey, value);

  }



  Future<void> startMonitoring({

    required NicheId nicheId,

    required List<String> apps,

  }) async {

    // Reset explícito para evitar contaminação

    _eventProcessor.reset();

    _eventBuffer.clear();



    _isModuleActive = true;

    currentNicheId = nicheId;

    monitoredApps = List<String>.from(apps);



    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_prefsActiveNicheKey, nicheId.id);

    await prefs.setStringList(_prefsMonitoredAppsKey, monitoredApps);

    await prefs.setBool(_prefsNotificationsPausedKey, notificationsPaused);



    _clearViolationState();

    // Estado inicial seguro com mapa explícito

    await _stateManager.saveEventState(DateTime.now(), <String>{});



    await _startForegroundService();

    await _checkRetroactiveViolations(nicheId);



    _monitorTimer?.cancel();

    _monitorTimer = Timer.periodic(const Duration(seconds: 2), _monitorLoop);

  }



  Future<void> stopMonitoring() async {

    _isModuleActive = false;

    _monitorTimer?.cancel();

    _monitorTimer = null;

    

    _clearViolationState();

    _eventBuffer.clear();

    _eventProcessor.reset();

    await _stateManager.saveEventState(DateTime.now(), <String>{});

    

    monitoredApps.clear();

    currentNicheId = null;

    notificationsPaused = false;



    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_prefsActiveNicheKey);

    await prefs.remove(_prefsMonitoredAppsKey);

    await prefs.setBool(_prefsNotificationsPausedKey, notificationsPaused);



    await _stopForegroundService();

  }



  void _monitorLoop(Timer timer) async {

    try {

      if (!_isModuleActive) {

        timer.cancel();

        return;

      }



      await _saveHeartbeat();



      // O GamificationService ainda precisa rodar o loop de progresso (dias consecutivos)

      // Delegamos isso de volta ou Rodamos aqui se passarmos a referência

      GamificationService.instance.runProgressCheck();



      if (notificationsPaused) {

        _clearViolationState();

        return;

      }



      final activeNicheId = currentNicheId;

      if (activeNicheId == null || monitoredApps.isEmpty) {

        _clearViolationState();

        return;

      }



      // Focus validation

      if (activeNicheId == NicheId.focus) {

        if (!GamificationService.instance.historyFocusInterval(activeNicheId, DateTime.now())) {

          _clearViolationState();

          return;

        }

      }



      // 🎯 TROCA CRUCIAL: queryEvents em vez de queryUsageStats

      final foregroundApp = await _getCurrentForegroundFromEvents();



      if (foregroundApp == null) {

        _clearViolationState();

        return;

      }



      if (_isSystemPackage(foregroundApp)) {

        _clearViolationState();

        return;

      }



      if (!monitoredApps.contains(foregroundApp)) {

        _clearViolationState();

        return;

      }



      // ✅ CORREÇÃO: Reavaliar timer contínuo mesmo sem transição

      await _checkViolationTimeout(foregroundApp);

      

      // Logging estruturado para debugging em produção

      if (DateTime.now().millisecondsSinceEpoch % 30000 < 2000) {

        _logSystemState();

      }

    } catch (e) {

      debugPrint('Erro no loop de monitoramento: $e');

    }

  }



  Future<void> _startForegroundService() async {

    const androidDetails = AndroidNotificationDetails(

      'disciplinum_monitor_channel',

      'Monitoramento Disciplinum',

      channelDescription: 'Mantém o app ativo para monitorar seus hábitos',

      importance: Importance.low,

      priority: Priority.low,

      ongoing: true,

      autoCancel: false,

      showWhen: false,

    );



    const details = NotificationDetails(android: androidDetails);



    await flutterLocalNotificationsPlugin.show(

      _foregroundServiceId,

      'Monitoramento Ativo',

      'O Disciplinum está te ajudando a manter bons hábitos e disciplina.',

      details,

    );

  }



  Future<void> _stopForegroundService() async {

    await flutterLocalNotificationsPlugin.cancel(_foregroundServiceId);

  }



  Future<void> _saveHeartbeat() async {

    final now = DateTime.now();

    if (now.difference(_lastHeartbeatSave).inSeconds < 10) return;



    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_prefsLastHeartbeatKey, now.millisecondsSinceEpoch);

    _lastHeartbeatSave = now;

    

    // NOVO: Verificar se período de foco foi concluído

    await _checkFocusPeriodCompletion();

  }



  // NOVO: Verificar conclusão de períodos de foco

  Future<void> _checkFocusPeriodCompletion() async {

    final activeNicheId = currentNicheId;

    if (activeNicheId == null || activeNicheId != NicheId.focus) return;

    

    final gamification = GamificationService.instance;

    final focusInterval = gamification.focusIntervalByModule[activeNicheId];

    if (focusInterval == null) return;

    

    final now = DateTime.now();



    final window = _getLastCompletedFocusWindow(

      now: now,

      startHour: focusInterval.start.hour,

      startMinute: focusInterval.start.minute,

      endHour: focusInterval.end.hour,

      endMinute: focusInterval.end.minute,

    );



    if (window == null) return;



    final startTime = window[0];

    final endTime = window[1];



    if (now.isBefore(endTime)) return;



    final prefs = await SharedPreferences.getInstance();

    final lastCheckedEnd = prefs.getInt('last_focus_checked_end_${activeNicheId.id}');



    if (lastCheckedEnd == endTime.millisecondsSinceEpoch) {

      return;

    }



    final hadViolations = await _hadViolationsInFocusPeriod(startTime, endTime);



    if (!hadViolations) {

      gamification.addRespectedFocusPeriod(activeNicheId);

      debugPrint(

        '✅ Período de foco respeitado! Total: ${gamification.getRespectedFocusPeriods(activeNicheId)}',

      );

    }



    await prefs.setInt(

      'last_focus_checked_end_${activeNicheId.id}',

      endTime.millisecondsSinceEpoch,

    );

  }



  List<DateTime>? _getLastCompletedFocusWindow({

    required DateTime now,

    required int startHour,

    required int startMinute,

    required int endHour,

    required int endMinute,

  }) {

    final startMinutes = startHour * 60 + startMinute;

    final endMinutes = endHour * 60 + endMinute;



    if (startMinutes <= endMinutes) {

      // Período não cruza meia-noite (ex: 9:00-17:00)

      final todayStart = DateTime(

        now.year, now.month, now.day, startHour, startMinute,

      );

      final todayEnd = DateTime(

        now.year, now.month, now.day, endHour, endMinute,

      );



      if (!now.isBefore(todayEnd)) {

        return [todayStart, todayEnd];

      }



      final yesterday = now.subtract(const Duration(days: 1));

      final yesterdayStart = DateTime(

        yesterday.year, yesterday.month, yesterday.day, startHour, startMinute,

      );

      final yesterdayEnd = DateTime(

        yesterday.year, yesterday.month, yesterday.day, endHour, endMinute,

      );



      return [yesterdayStart, yesterdayEnd];

    } else {

      // Período cruza meia-noite (ex: 22:00-6:00)

      final currentMinutes = now.hour * 60 + now.minute;



      if (currentMinutes < endMinutes) {

        // Ainda estamos na janela "de hoje", então a última COMPLETA terminou ontem

        final yesterday = now.subtract(const Duration(days: 1));

        final twoDaysAgo = now.subtract(const Duration(days: 2));



        final start = DateTime(

          twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, startHour, startMinute,

        );

        final end = DateTime(

          yesterday.year, yesterday.month, yesterday.day, endHour, endMinute,

        );



        return [start, end];

      } else {

        // Já passou do fim hoje, então a última COMPLETA terminou hoje

        final yesterday = now.subtract(const Duration(days: 1));



        final start = DateTime(

          yesterday.year, yesterday.month, yesterday.day, startHour, startMinute,

        );

        final end = DateTime(

          now.year, now.month, now.day, endHour, endMinute,

        );



        return [start, end];

      }

    }

  }

  

  // NOVO: Verificar se houve violações em um período

  Future<bool> _hadViolationsInFocusPeriod(DateTime startTime, DateTime endTime) async {

    try {

      final events = await UsageStats.queryEvents(startTime, endTime);

      

      // Cache de cálculos para evitar múltiplas chamadas

      final calculatedPackages = <String, int>{};



      for (final event in events) {

        final pkg = event.packageName;

        if (pkg == null) continue;

        if (!monitoredApps.contains(pkg)) continue;

        if (!_isForegroundEvent(event.eventType)) continue;

        

        // Se já calculamos para este package, reutilizar

        if (calculatedPackages.containsKey(pkg)) {

          if (calculatedPackages[pkg]! >= 30000) return true;

          continue;

        }

        

        // Calcular tempo total em foreground no período

        final totalTime = await _calculateForegroundTime(pkg, startTime, endTime);

        calculatedPackages[pkg] = totalTime;

        

        if (totalTime >= 30000) return true;

      }

    } catch (e) {

      debugPrint('Erro ao verificar violações: $e');

    }



    return false;

  }



  Future<void> _checkRetroactiveViolations(NicheId nicheId) async {

    final prefs = await SharedPreferences.getInstance();

    final lastHeartbeat = prefs.getInt(_prefsLastHeartbeatKey);

    if (lastHeartbeat == null) return;



    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastHeartbeat);

    final now = DateTime.now();



    if (now.difference(lastTime).inMinutes >= 1) {

      // USAR EVENTS em vez de usage stats para consistência

      final events = await UsageStats.queryEvents(lastTime, now);

      

      // Cache por pacote para evitar múltiplas chamadas

      final calculatedPackages = <String, int>{};

      

      for (final event in events) {

        if (_isForegroundEvent(event.eventType) &&

            monitoredApps.contains(event.packageName ?? '')) {

          

          final pkg = event.packageName!;

          

          // Se já calculamos para este package, reutilizar

          if (calculatedPackages.containsKey(pkg)) {

            if (calculatedPackages[pkg]! >= 30000) {

              await GamificationService.instance.resetMedals(

                nicheId,

                notificationTitle: 'Progresso Resetado (Offline) 🕵️',

                notificationBody: 'Uso de app monitorado por 30+ segundos detectado.',

                deactivate: true,

              );

              return;

            }

            continue;

          }

          

          // Calcular tempo real em foreground

          final totalTime = await _calculateForegroundTime(pkg, lastTime, now);

          calculatedPackages[pkg] = totalTime;

          

          if (totalTime >= 30000) { // 30 segundos reais

            await GamificationService.instance.resetMedals(

              nicheId,

              notificationTitle: 'Progresso Resetado (Offline) 🕵️',

              notificationBody: 'Uso de app monitorado por 30+ segundos detectado.',

              deactivate: true,

            );

            return;

          }

        }

      }

    }

  }



  Future<void> restoreSession() async {

    final prefs = await SharedPreferences.getInstance();

  

    // Restore niche

    final savedId = prefs.getInt(_prefsActiveNicheKey);

    if (savedId == null) return;

    

    final nicheId = NicheId.tryFromInt(savedId);

    if (nicheId == null) return;

    

    // Restore monitored apps - CRITICAL FIX

    final savedApps = prefs.getStringList(_prefsMonitoredAppsKey) ?? [];

    if (savedApps.isEmpty) return;

    

    // Reset explícito para evitar lixo de memória

    _eventProcessor.reset();

    _eventBuffer.clear();

    _clearViolationState();

    

    // Restore state

    currentNicheId = nicheId;

    monitoredApps = List<String>.from(savedApps);

    notificationsPaused = prefs.getBool(_prefsNotificationsPausedKey) ?? false;

    _isModuleActive = true;

    

    // Restore event processing state

    final eventState = await _stateManager.restoreEventState();

    if (eventState['lastQuery'] != null) {

      _eventProcessor.restoreState(eventState['lastQuery'], eventState['processedIds']);

    }

    

    // Start monitoring

    await _startForegroundService();

    await _checkRetroactiveViolations(nicheId);

    _restartMonitorTimer();

  }



  void _restartMonitorTimer() {

    _monitorTimer?.cancel();

    _monitorTimer = Timer.periodic(const Duration(seconds: 2), _monitorLoop);

  }



  // ==================== ENTERPRISE EVENT PROCESSING ====================



  /// Enhanced system package detection

  bool _isSystemPackage(String packageName) {

    const systemPackages = {

      'com.disciplinum.app',

      'com.android.systemui',

      'android',

      'com.sec.android.app.launcher',

      'com.google.android.apps.nexuslauncher',

      'com.miui.home',

      'com.huawei.android.launcher',

      'com.oneplus.launcher',

      'com.oppo.launcher',

      'com.vivo.launcher',

      'com.xiaomi.miui.home',

    };

    

    return systemPackages.contains(packageName) ||

           packageName.startsWith('com.android.') ||

           packageName.startsWith('com.google.android.') ||

           packageName.contains('.launcher');

  }

  

  bool _isForegroundEvent(String? eventType) {

    return eventType == 'MOVE_TO_FOREGROUND' || 

           eventType == 'ACTIVITY_RESUMED';

  }

  

  bool _isBackgroundEvent(String? eventType) {

    return eventType == 'MOVE_TO_BACKGROUND' || 

           eventType == 'ACTIVITY_PAUSED';

  }



  /// Get current foreground app using queryEvents (enterprise method)

  Future<String?> _getCurrentForegroundFromEvents() async {

    try {

      final newEvents = await _eventProcessor.getUnprocessedEvents();



      if (newEvents.isNotEmpty) {

        _perfMonitor.recordQuery(newEvents.length, _eventBuffer.size);

        _eventBuffer.addEvents(newEvents);



        await _stateManager.saveEventState(

          _eventProcessor.lastQueryTime ?? DateTime.now(),

          _eventProcessor.processedEventIds,

        );

      }



      String? foregroundApp = _eventBuffer.getCurrentForegroundApp();



      // Fallback para cold start / restore:

      // se não há evento suficiente para inferir o foreground atual,

      // tenta heurística por lastTimeUsed.

      foregroundApp ??= await _getLikelyForegroundFromUsageStatsFallback();



      if (foregroundApp != _currentForegroundApp) {

        await _handleAppTransition(_currentForegroundApp, foregroundApp);

        _currentForegroundApp = foregroundApp;

      }



      return foregroundApp;

    } catch (e) {

      debugPrint('❌ Error in foreground detection: $e');

      return null;

    }

  }



  Future<String?> _getLikelyForegroundFromUsageStatsFallback() async {

    try {

      final now = DateTime.now();

      final usageList = await UsageStats.queryUsageStats(

        now.subtract(const Duration(minutes: 8)),

        now,

      );



      if (usageList.isEmpty) return null;



      usageList.sort((a, b) {

        final lastA = int.tryParse(a.lastTimeUsed ?? '0') ?? 0;

        final lastB = int.tryParse(b.lastTimeUsed ?? '0') ?? 0;

        return lastB.compareTo(lastA);

      });



      for (final usage in usageList) {

        final pkg = usage.packageName;

        if (pkg == null || pkg.isEmpty) continue;

        if (_isSystemPackage(pkg)) continue;



        final lastUsedMs = int.tryParse(usage.lastTimeUsed ?? '0') ?? 0;

        if (lastUsedMs <= 0) continue;



        final ageMs = now.millisecondsSinceEpoch - lastUsedMs;



        // Heurística bem mais conservadora: só aceita se o último uso foi muito recente

        if (ageMs <= const Duration(seconds: 8).inMilliseconds) {

          return pkg;

        }

      }



      return null;

    } catch (e) {

      debugPrint('Error in usage stats fallback: $e');

      return null;

    }

  }



  /// Handle smart app transitions

  Future<void> _handleAppTransition(String? fromApp, String? toApp) async {

    debugPrint('🔄 App transition: $fromApp → $toApp');

    

    // Cancel violation if leaving monitored app

    if (fromApp != null && monitoredApps.contains(fromApp)) {

      await _cancelViolationForApp(fromApp);

    }

    

    // Start monitoring if entering monitored app

    if (toApp != null && monitoredApps.contains(toApp)) {

      await _handleMonitoredAppEntry(toApp);

    }

  }



  /// Check violation timeout continuously for active monitored app

  Future<void> _checkViolationTimeout(String packageName) async {

    final now = DateTime.now();

    

    if (_violationStartByApp.containsKey(packageName)) {

      final start = _violationStartByApp[packageName]!;

      final duration = now.difference(start).inSeconds;

      

      if (duration >= _violationTimeoutSeconds) {

        await _triggerViolationReset(packageName);

      }

    }

  }



  /// Cancel violation for specific app

  Future<void> _cancelViolationForApp(String packageName) async {

    if (_violationStartByApp.containsKey(packageName)) {

      _violationStartByApp.remove(packageName);

      _warnedApps.remove(packageName);

      _lastSeenMonitoredApp.remove(packageName);

      

      debugPrint('✅ Violation cancelled for $packageName');

    }

  }



  /// Handle monitored app entry

  Future<void> _handleMonitoredAppEntry(String packageName) async {

    final now = DateTime.now();

    _lastSeenMonitoredApp[packageName] = now;



    if (!_violationStartByApp.containsKey(packageName)) {

      if (!_warnedApps.containsKey(packageName)) {

        final niche = NicheRepository.getById(currentNicheId!);

        final baseMessage = GamificationMessages.getModuleMessage(

          currentNicheId!,

          isUnlocked: IapService().isCustomNotifUnlocked ||

              GamificationService.instance

                  .isNotificationUnlocked(currentNicheId!),

          customMessages: GamificationService.instance.customMessages,

        );

        

        await GamificationService.instance.sendModuleNotification(

          '$baseMessage\n\n⚠️ Saia do app em até 30s para não perder seu progresso.',

          title: 'Disciplinum: ${niche.name}',

          iconPath: niche.iconPath,

        );

        

        _warnedApps[packageName] = now;

        _violationStartByApp[packageName] = now;

      }

    } else {

      final start = _violationStartByApp[packageName]!;

      final duration = now.difference(start).inSeconds;

      if (duration >= _violationTimeoutSeconds) {

        await _triggerViolationReset(packageName);

      }

    }

  }



  /// Trigger violation reset

  Future<void> _triggerViolationReset(String packageName) async {

    final niche = NicheRepository.getById(currentNicheId!);

    await GamificationService.instance.resetMedals(

      currentNicheId!,

      notificationTitle: 'Progresso Zerado 😢',

      notificationBody:

          'Você utilizou o app monitorado por 30 segundos ou mais. Progresso reiniciado.',

      iconPath: niche.iconPath,

      deactivate: true,

    );



    _violationStartByApp.remove(packageName);

    _warnedApps.remove(packageName);

    _lastSeenMonitoredApp.remove(packageName);

  }



  /// Calculate real foreground time for a package

  Future<int> _calculateForegroundTime(String packageName, DateTime start, DateTime end) async {

    try {

      final rawEvents = await UsageStats.queryEvents(start, end);



      final events = rawEvents.where((e) => e.packageName == packageName).toList()

        ..sort((a, b) {

          final timeA = int.tryParse(a.timeStamp ?? '0') ?? 0;

          final timeB = int.tryParse(b.timeStamp ?? '0') ?? 0;

          return timeA.compareTo(timeB);

        });



      int totalTime = 0;

      DateTime? foregroundStart;



      for (final event in events) {

        final eventTime = DateTime.fromMillisecondsSinceEpoch(

          int.tryParse(event.timeStamp ?? '0') ?? 0,

        );



        if (eventTime.isBefore(start) || eventTime.isAfter(end)) {

          continue; // Ignora eventos fora da janela

        }



        if (_isForegroundEvent(event.eventType)) {

          foregroundStart = eventTime;

        } else if (_isBackgroundEvent(event.eventType) && foregroundStart != null) {

          totalTime += eventTime.difference(foregroundStart).inMilliseconds;

          foregroundStart = null;

        }

      }



      if (foregroundStart != null) {

        totalTime += end.difference(foregroundStart).inMilliseconds;

      }



      return totalTime;

    } catch (e) {

      debugPrint('Error calculating foreground time: $e');

      return 0;

    }

  }



  /// Clear violation state

  void _clearViolationState() {

    _violationStartByApp.clear();

    _warnedApps.clear();

    _lastSeenMonitoredApp.clear();

    _currentForegroundApp = null;

  }



  /// Log comprehensive system state

  void _logSystemState() {

    debugPrint('🔍 AppMonitoring State:');

    debugPrint('  Active: $_isModuleActive');

    debugPrint('  Niche: $currentNicheId');

    debugPrint('  Monitored Apps: ${monitoredApps.length}');

    debugPrint('  Notifications Paused: $notificationsPaused');

    debugPrint('  Current Foreground: $_currentForegroundApp');

    debugPrint('  Violations Active: ${_violationStartByApp.length}');

    debugPrint('  Buffer Size: ${_eventBuffer.size}');

    debugPrint('  Processed Events: ${_eventProcessor.processedEventIds.length}');

    debugPrint('  Last Query: ${_eventProcessor.lastQueryTime}');

  }



  /// Validate system health and configuration

  Future<bool> validateSystemHealth() async {

    try {

      // Check if we have permission to query usage stats

      final hasPermission = await UsageStats.checkUsagePermission();

      if (hasPermission != true) {

        debugPrint('❌ Usage Stats permission not granted');

        return false;

      }



      // Test queryEvents functionality

      final now = DateTime.now();

      final testEvents = await UsageStats.queryEvents(

        now.subtract(const Duration(minutes: 1)),

        now,

      );



      debugPrint('✅ System validation passed:');

      debugPrint('  - Usage Stats permission: $hasPermission');

      debugPrint('  - Events in last minute: ${testEvents.length}');

      debugPrint('  - Event processing ready: true');

      debugPrint('  - Buffer ready: true');



      return true;

    } catch (e) {

      debugPrint('❌ System validation failed: $e');

      return false;

    }

  }

}



// ==================== ENTERPRISE CLASSES ====================



/// Event processor with incremental query and fallback

class EventProcessor {

  final Set<String> _processedEventIds = {};

  DateTime? _lastQueryTime;

  static const Duration _maxQueryWindow = Duration(minutes: 10);

  static const int _maxProcessedIds = 1000;

  

  // Expose for state management

  DateTime? get lastQueryTime => _lastQueryTime;

  Set<String> get processedEventIds => Set.unmodifiable(_processedEventIds);

  

  Future<List<EventUsageInfo>> getUnprocessedEvents() async {

    final now = DateTime.now();

    

    // Strategy: Incremental com fallback inteligente

    final queryStart = _calculateQueryStart(now);

    final events = await UsageStats.queryEvents(queryStart, now);

    

    // Filter e mark processed

    final unprocessed = _filterUnprocessed(events);

    _markAsProcessed(unprocessed);

    _cleanupOldProcessedIds();

    

    _lastQueryTime = now;

    return unprocessed;

  }

  

  DateTime _calculateQueryStart(DateTime now) {

    // Cold start ou gap grande: query maior

    if (_lastQueryTime == null || 

        now.difference(_lastQueryTime!).inMinutes > 10) {

      return now.subtract(_maxQueryWindow);

    }

    // Normal: incremental do último ponto

    return _lastQueryTime!;

  }

  

  List<EventUsageInfo> _filterUnprocessed(List<EventUsageInfo> events) {

    return events.where((e) {

      if (e.timeStamp == null) return false;

      return !_processedEventIds.contains(_eventId(e));

    }).toList();

  }

  

  void _markAsProcessed(List<EventUsageInfo> events) {

    for (final event in events) {

      _processedEventIds.add(_eventId(event));

    }

  }

  

  String _eventId(EventUsageInfo e) {

    final pkg = e.packageName ?? '';

    final type = e.eventType ?? '';

    final ts = e.timeStamp ?? '';



    String className = '';

    try {

      final dynamic ev = e;

      className = (ev.className ?? '').toString();

    } catch (_) {

      className = '';

    }



    return '$pkg|$className|$type|$ts';

  }

  

  void _cleanupOldProcessedIds() {

    if (_processedEventIds.length > _maxProcessedIds) {

      _processedEventIds.removeAll(_processedEventIds.take(500).toList());

    }

  }

  

  void restoreState(DateTime? lastQuery, Set<String> processedIds) {

    _lastQueryTime = lastQuery;

    _processedEventIds.clear();

    _processedEventIds.addAll(processedIds);

  }

  

  void reset() {

    _lastQueryTime = null;

    _processedEventIds.clear();

  }

}



/// Event buffer with circular management

class EventBuffer {

  final List<EventUsageInfo> _buffer = [];

  final int _maxSize = 100;

  final Map<String, EventUsageInfo> _lastForegroundByApp = {};

  

  void addEvents(List<EventUsageInfo> events) {

    // Ordenação defensiva para blindar contra eventos fora de ordem

    final sortedEvents = List<EventUsageInfo>.from(events);

    sortedEvents.sort((a, b) {

      final timeA = int.tryParse(a.timeStamp ?? '0') ?? 0;

      final timeB = int.tryParse(b.timeStamp ?? '0') ?? 0;

      return timeA.compareTo(timeB);

    });

    

    for (final event in sortedEvents) {

      _buffer.add(event);

      if (_buffer.length > _maxSize) _buffer.removeAt(0);

      

      // Track last foreground per app (compatível com ambos os formatos)

      if (_isForegroundEvent(event.eventType)) {

        _lastForegroundByApp[event.packageName ?? ''] = event;

      }

    }

  }

  

  String? getCurrentForegroundApp() {

    // ✅ CORREÇÃO: Processar em ordem cronológica (mais antigo → mais novo)

    String? currentApp;

    

    for (final event in _buffer) {

      if (_isForegroundEvent(event.eventType) && 

          !_isSystemPackage(event.packageName ?? '')) {

        currentApp = event.packageName;

      } else if (_isBackgroundEvent(event.eventType) && 

                 event.packageName == currentApp) {

        currentApp = null; // Saída explícita do app

      }

    }

    return currentApp;

  }

  

  bool _isSystemPackage(String packageName) {

    const systemPackages = {

      'com.disciplinum.app',

      'com.android.systemui',

      'android',

      'com.sec.android.app.launcher',

      'com.google.android.apps.nexuslauncher',

      'com.miui.home',

      'com.huawei.android.launcher',

    };

    

    return systemPackages.contains(packageName) ||

           packageName.startsWith('com.android.') ||

           packageName.startsWith('com.google.android.') ||

           packageName.contains('.launcher');

  }

  

  bool _isForegroundEvent(String? eventType) {

    return eventType == 'MOVE_TO_FOREGROUND' || 

           eventType == 'ACTIVITY_RESUMED';

  }

  

  bool _isBackgroundEvent(String? eventType) {

    return eventType == 'MOVE_TO_BACKGROUND' || 

           eventType == 'ACTIVITY_PAUSED';

  }

  

  int get size => _buffer.length;

  

  void clear() {

    _buffer.clear();

    _lastForegroundByApp.clear();

  }

}



/// Performance monitor for metrics

class PerformanceMonitor {

  int _totalQueries = 0;

  int _totalEvents = 0;

  int _bufferSize = 0;

  DateTime _lastCleanup = DateTime.now();

  

  void recordQuery(int eventCount, int bufferSize) {

    _totalQueries++;

    _totalEvents += eventCount;

    _bufferSize = bufferSize;

    

    if (DateTime.now().difference(_lastCleanup).inMinutes >= 10) {

      _logStats();

      _lastCleanup = DateTime.now();

    }

  }

  

  void _logStats() {

    debugPrint('📊 EventProcessing Stats:');

    debugPrint('  Queries: $_totalQueries');

    debugPrint('  Events: $_totalEvents');

    debugPrint('  Avg/Query: ${(_totalEvents / _totalQueries).toStringAsFixed(1)}');

    debugPrint('  Buffer: $_bufferSize');

  }

}



/// State manager for persistence

class StateManager {

  static const String _lastQueryKey = 'last_event_query_time';

  static const String _processedIdsKey = 'processed_event_ids';

  

  Future<void> saveEventState(DateTime lastQuery, Set<String> processedIds) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_lastQueryKey, lastQuery.toIso8601String());

    await prefs.setStringList(_processedIdsKey, processedIds.toList());

  }

  

  Future<Map<String, dynamic>> restoreEventState() async {

    final prefs = await SharedPreferences.getInstance();

    final lastQueryStr = prefs.getString(_lastQueryKey);

    final processedIds = prefs.getStringList(_processedIdsKey) ?? [];

    

    return {

      'lastQuery': lastQueryStr != null ? DateTime.parse(lastQueryStr) : null,

      'processedIds': processedIds.toSet(),

    };

  }

}

