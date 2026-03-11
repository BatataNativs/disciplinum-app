import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:disciplinum/shared/models/enums/niche_id.dart';

import 'package:disciplinum/shared/models/common/niche.dart';

import 'package:disciplinum/services/gamification/gamification_service.dart';

import 'package:disciplinum/features/gamification/domain/services/gamification_messages.dart';

import 'package:disciplinum/infrastructure/iap/iap_service.dart';

import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';

class AppMonitoringService {
  static final AppMonitoringService _instance =
      AppMonitoringService._internal();

  static AppMonitoringService get instance => _instance;

  AppMonitoringService._internal();

  // ID para a notificação persistente (Serviço de Primeiro Plano)

  static const int _foregroundServiceId = 888;

  static const String _prefsActiveNicheKey = 'active_niche_id';

  static const String _prefsMonitoredAppsKey = 'active_monitored_apps';

  static const String _prefsNotificationsPausedKey =
      'settings_notifications_paused';

  static const String _prefsLastHeartbeatKey = 'last_heartbeat';

  bool _isModuleActive = false;

  Timer? _monitorTimer;

  List<String> monitoredApps = [];

  bool notificationsPaused = false;

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

  // Acessibilidade
  static const _accessibilityChannel =
      EventChannel('com.disciplinum.app/accessibility');
  static const _methodChannel =
      MethodChannel('com.disciplinum.app/accessibility_methods');
  StreamSubscription? _accessibilitySubscription;
  String? _lastAccessibilityApp;
  String? _currentOverlayMessage;
  DateTime? _lastInteractiveSystemTime;

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

    _isModuleActive = true;

    currentNicheId = nicheId;

    monitoredApps = List<String>.from(apps);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_prefsActiveNicheKey, nicheId.id);

    await prefs.setStringList(_prefsMonitoredAppsKey, monitoredApps);

    await prefs.setBool(_prefsNotificationsPausedKey, notificationsPaused);

    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();
    _currentForegroundApp = null;

    // Estado inicial seguro

    await _startForegroundService();

    await _checkRetroactiveViolations(nicheId);

    _monitorTimer?.cancel();

    _monitorTimer = Timer.periodic(const Duration(seconds: 1), _monitorLoop);

    // Escuta de acessibilidade em tempo real
    _accessibilitySubscription?.cancel();
    _accessibilitySubscription =
        _accessibilityChannel.receiveBroadcastStream().listen((packageName) {
      if (packageName is String) {
        _handleAccessibilityEvent(packageName);
      }
    });
  }

  Future<void> stopMonitoring() async {
    _isModuleActive = false;

    _monitorTimer?.cancel();
    _monitorTimer = null;

    _accessibilitySubscription?.cancel();
    _accessibilitySubscription = null;
    _lastAccessibilityApp = null;

    _clearViolationState();

    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();
    _currentForegroundApp = null;

    monitoredApps.clear();

    currentNicheId = null;

    notificationsPaused = false;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_prefsActiveNicheKey);

    await prefs.remove(_prefsMonitoredAppsKey);

    await prefs.setBool(_prefsNotificationsPausedKey, notificationsPaused);

    await _stopForegroundService();

    // Garantir que o overlay suma
    await _hideOverlay();
  }

  void _monitorLoop(Timer timer) async {
    try {
      if (!_isModuleActive) {
        timer.cancel();
        return;
      }

      await _saveHeartbeat();
      GamificationService.instance.runProgressCheck();

      if (notificationsPaused) {
        _violationStartByApp.clear();
        _warnedApps.clear();
        _lastSeenMonitoredApp.clear();
        _currentForegroundApp = null;
        return;
      }

      final activeNicheId = currentNicheId;
      if (activeNicheId == null || monitoredApps.isEmpty) {
        _violationStartByApp.clear();
        _warnedApps.clear();
        _lastSeenMonitoredApp.clear();
        _currentForegroundApp = null;
        return;
      }

      // Focus validation
      if (activeNicheId == NicheId.focus) {
        if (!GamificationService.instance
            .historyFocusInterval(activeNicheId, DateTime.now())) {
          _violationStartByApp.clear();
          _warnedApps.clear();
          _lastSeenMonitoredApp.clear();
          _currentForegroundApp = null;
          return;
        }
      }

      // Coleta o app em foreground
      String? foregroundApp = _lastAccessibilityApp;

      // ✅ Mudança Crítica: Não limpamos TUDO se o foreground for nulo ou sistema.
      // Apenas tratamos como uma transição.
      if (foregroundApp != _currentForegroundApp) {
        await _handleAppTransition(_currentForegroundApp, foregroundApp);
        _currentForegroundApp = foregroundApp;
      }

      // Se estamos em um app monitorado, continuamos verificando o timeout
      if (foregroundApp != null && monitoredApps.contains(foregroundApp)) {
        await _checkViolationTimeout(foregroundApp);
      } else if (_violationStartByApp.isNotEmpty) {
        // Resiliência de Overlay
        // Se saímos do app monitorado mas fomos para o Sistema (notificações/vRI/Samsung Protector),
        // mantemos o overlay visível para o usuário ver o tempo passando.
        bool isInteractiveSystem =
            foregroundApp != null && _isInteractiveSystemPackage(foregroundApp);

        if (isInteractiveSystem) {
          // Se for sistema interativo (notif), continuamos o timer do primeiro app em violação encontrado
          final activeViolationApp = _violationStartByApp.keys.first;
          await _checkViolationTimeout(activeViolationApp);
        } else {
          // Se foi para Launcher/Home/Recents ou outro App: CANCELA e ESCONDE.
          // Pegamos todos os apps ativos e cancelamos para garantir que o timer pare.
          final appsToCancel = List<String>.from(_violationStartByApp.keys);
          for (var pkg in appsToCancel) {
            await _cancelViolationForApp(pkg);
          }
        }
      }

      // Logging periódico
      if (DateTime.now().millisecondsSinceEpoch % 30000 < 2000) {
        // _logSystemState removed
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

    final lastCheckedEnd =
        prefs.getInt('last_focus_checked_end_${activeNicheId.id}');

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
        now.year,
        now.month,
        now.day,
        startHour,
        startMinute,
      );

      final todayEnd = DateTime(
        now.year,
        now.month,
        now.day,
        endHour,
        endMinute,
      );

      if (!now.isBefore(todayEnd)) {
        return [todayStart, todayEnd];
      }

      final yesterday = now.subtract(const Duration(days: 1));

      final yesterdayStart = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        startHour,
        startMinute,
      );

      final yesterdayEnd = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        endHour,
        endMinute,
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
          twoDaysAgo.year,
          twoDaysAgo.month,
          twoDaysAgo.day,
          startHour,
          startMinute,
        );

        final end = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          endHour,
          endMinute,
        );

        return [start, end];
      } else {
        // Já passou do fim hoje, então a última COMPLETA terminou hoje

        final yesterday = now.subtract(const Duration(days: 1));

        final start = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          startHour,
          startMinute,
        );

        final end = DateTime(
          now.year,
          now.month,
          now.day,
          endHour,
          endMinute,
        );

        return [start, end];
      }
    }
  }

  // NOVO: Verificar se houve violações em um período

  Future<bool> _hadViolationsInFocusPeriod(
      DateTime startTime, DateTime endTime) async {
    return false;
  }

  /// Handle real-time accessibility event
  void _handleAccessibilityEvent(String packageName) async {
    if (!_isModuleActive || notificationsPaused) return;

    if (_isSystemPackage(packageName)) {
      _lastAccessibilityApp = packageName;
      return;
    }

    if (packageName != _lastAccessibilityApp) {
      debugPrint(
          '⚡ Real-time transition (Accessibility): $_lastAccessibilityApp → $packageName');
      await _handleAppTransition(_lastAccessibilityApp, packageName);
      _lastAccessibilityApp = packageName;
    }
  }

  Future<void> _checkRetroactiveViolations(NicheId nicheId) async {
    // Retroatividade agora depende de persistência de sessão e não mais de UsageStats query.
    // O sistema de 30s é resiliente por design.
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

    // Restore state
    currentNicheId = nicheId;
    monitoredApps = List<String>.from(savedApps);
    notificationsPaused = prefs.getBool(_prefsNotificationsPausedKey) ?? false;
    _isModuleActive = true;

    // Start monitoring

    await _startForegroundService();

    await _checkRetroactiveViolations(nicheId);

    _restartMonitorTimer();
  }

  void _restartMonitorTimer() {
    _monitorTimer?.cancel();

    _monitorTimer = Timer.periodic(const Duration(seconds: 2), _monitorLoop);
  }

  /// Handle smart app transitions

  Future<void> _handleAppTransition(String? fromApp, String? toApp) async {
    if (fromApp == toApp) return;

    debugPrint('🔄 App transition: $fromApp → $toApp');

    // Se saiu de um app monitorado, verificamos se devemos cancelar a violação.
    if (fromApp != null && monitoredApps.contains(fromApp)) {
      // Correção de Home/Recents.
      // Se o usuário foi para um app 'seguro' (Launcher, Home, Settings, etc), cancelamos IMEDIATAMENTE.
      // Se foi para o Sistema INTERATIVO (Notificações) ou o próprio Disciplinum, NÃO cancelamos.

      bool isInteractiveSystem =
          toApp != null && _isInteractiveSystemPackage(toApp);
      bool isTargetDisciplinum = toApp == 'com.disciplinum.app';

      if (isInteractiveSystem) {
        _lastInteractiveSystemTime = DateTime.now();
      }

      // Carência para o Launcher se veio de Sistema Interativo
      bool isTargetLauncher = toApp != null && _isSystemPackage(toApp);
      bool isSuspectedSamsungOscillation = false;

      if (isTargetLauncher && _lastInteractiveSystemTime != null) {
        final timeSinceSystem =
            DateTime.now().difference(_lastInteractiveSystemTime!);
        if (timeSinceSystem.inSeconds < 2) {
          isSuspectedSamsungOscillation = true;
          debugPrint(
              '🛡️ Samsung Launcher oscillation detected after security check. Ignoring transition.');
        }
      }

      // Se o destino NÃO for o app monitorado, nem sistema interativo (notif),
      // nem o nosso app, NEM uma oscilação do launcher: CANCELA.
      if (toApp != null &&
          !monitoredApps.contains(toApp) &&
          !isInteractiveSystem &&
          !isTargetDisciplinum &&
          !isSuspectedSamsungOscillation) {
        await _cancelViolationForApp(fromApp);
      } else {
        debugPrint(
            '⏳ Suspected transition to overlay/notif/launcher (to $toApp). Keeping violation active for $fromApp.');
      }
    }

    // Se entrou em um app monitorado, iniciamos a lógica de transgressão
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
      } else {
        await _updateOverlay(
            secondsRemaining: _violationTimeoutSeconds - duration,
            message: _currentOverlayMessage);
      }
    }
  }

  /// Cancel violation for specific app
  Future<void> _cancelViolationForApp(String packageName) async {
    if (_violationStartByApp.containsKey(packageName)) {
      // Só cancelamos a violação se soubermos que o usuário
      // SAIU do app monitorado E não há carência ativa no buffer
      // ou se ele voltou para o Disciplinum.

      _violationStartByApp.remove(packageName);
      _warnedApps.remove(packageName);
      _lastSeenMonitoredApp.remove(packageName);
      _currentOverlayMessage = null; // Limpa mensagem ativa

      debugPrint('✅ Violation cancelled for $packageName');
      await _hideOverlay();
    }
  }

  /// Handle monitored app entry

  Future<void> _handleMonitoredAppEntry(String packageName) async {
    final now = DateTime.now();

    _lastSeenMonitoredApp[packageName] = now;

    // Preparar mensagem para o Overlay
    final baseMessage = GamificationMessages.getModuleMessage(
      currentNicheId!,
      isUnlocked: IapService().isCustomNotifUnlocked ||
          GamificationService.instance.isNotificationUnlocked(currentNicheId!),
      customMessages: GamificationService.instance.customMessages,
    );
    _currentOverlayMessage =
        '$baseMessage\nSaia em 30s para manter seu progresso no Disciplinum!';

    if (!_violationStartByApp.containsKey(packageName)) {
      // Se não há violação ativa para este app, iniciamos uma nova
      _warnedApps[packageName] = now;
      _violationStartByApp[packageName] = now;

      // MOSTRAR NO OVERLAY (e não via notificação do sistema)
      await _showOverlay(_violationTimeoutSeconds,
          message: _currentOverlayMessage);
    } else {
      final start = _violationStartByApp[packageName]!;
      final duration = now.difference(start).inSeconds;

      if (duration >= _violationTimeoutSeconds) {
        await _triggerViolationReset(packageName);
      } else {
        await _updateOverlay(
            secondsRemaining: _violationTimeoutSeconds - duration,
            message: _currentOverlayMessage);
      }
    }
  }

  /// Trigger violation reset

  Future<void> _triggerViolationReset(String packageName) async {
    final niche = NicheRepository.getById(currentNicheId!);

    debugPrint('🚨 TRIGGERING VIOLATION RESET for $packageName');

    await GamificationService.instance.resetMedals(
      currentNicheId!,
      notificationTitle: 'Disciplinum: ${niche.name}',
      notificationBody:
          _currentOverlayMessage ?? 'Saia do app para manter seu progresso!',
      iconPath: niche.iconPath,
      deactivate: true,
    );

    _violationStartByApp.remove(packageName);

    _warnedApps.remove(packageName);

    _lastSeenMonitoredApp.remove(packageName);

    await _hideOverlay();
  }

  void _clearViolationState() {
    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();
    _currentForegroundApp = null;
  }

  /// Identifica pacotes de sistema que são considereados "saída segura" (Launcher, Settings, etc)
  bool _isSystemPackage(String packageName) {
    const systemPackages = {
      'com.android.systemui',
      'android',
      // Samsung
      'com.sec.android.app.launcher',
      'com.samsung.android.sm',
      // Google/Android Original
      'com.google.android.apps.nexuslauncher',
      'com.android.launcher3',
      'com.google.android.inputmethod.latin', // Teclado (não deve contar como saída)
      // Custom Launchers Populares
      'teslacoilsw.launcher', // Nova Launcher
      'ch.deletescape.lawnchair.plah', // Lawnchair
      'com.teslacoilsw.launcher.prime',
      'com.microsoft.launcher',
      'com.niagara.launcher',
      'com.smartlauncher.set.v2',
      // Outros
      'com.miui.home',
      'com.huawei.android.launcher',
      'com.oneplus.launcher',
      'com.oppo.launcher',
      'com.vivo.launcher',
      'com.xiaomi.miui.home',
    };

    return systemPackages.contains(packageName) ||
        packageName.contains('.launcher') ||
        packageName.contains('.home') ||
        packageName.endsWith('.launcher');
  }

  /// Identifica pacotes de sistema que são "interativos" e NÃO representam saída do monitoramento
  /// (ex: barra de notificações, sensor de impressões digitais, diálogos de segurança)
  bool _isInteractiveSystemPackage(String packageName) {
    const interactivePackages = {
      'com.android.systemui', // Notifications/Quick Settings
      'android', // System Dialogs
      'com.sp.protector.free', // Samsung Security/App Protector (CAUSADOR DO BUG)
      'com.samsung.android.securitylogagent',
      'com.disciplinum.app', // Próprio app (evita cancelar durante transição de sistema)
    };

    return interactivePackages.contains(packageName) ||
        (packageName.startsWith('com.sec.android.') &&
            !packageName.contains('launcher')) ||
        (packageName.startsWith('com.samsung.android.') &&
            !packageName.contains('launcher'));
  }

  Future<bool> validateSystemHealth() async {
    return true; // Accessibility service handled natively
  }

  // --- MÉTODOS AUXILIARES DE OVERLAY ---

  Future<void> _showOverlay(int secondsRemaining, {String? message}) async {
    try {
      await _methodChannel.invokeMethod('showTimerOverlay', {
        'seconds': secondsRemaining,
        'message': message,
      });
    } catch (e) {
      debugPrint('Erro ao mostrar overlay: $e');
    }
  }

  Future<void> _updateOverlay(
      {required int secondsRemaining, String? message}) async {
    try {
      await _methodChannel.invokeMethod('updateTimerOverlay', {
        'seconds': secondsRemaining,
        'message': message,
      });
    } catch (e) {
      // Ignorar erros de atualização rápida
    }
  }

  Future<void> _hideOverlay() async {
    try {
      await _methodChannel.invokeMethod('hideTimerOverlay');
    } catch (e) {
      debugPrint('Erro ao esconder overlay: $e');
    }
  }
}
