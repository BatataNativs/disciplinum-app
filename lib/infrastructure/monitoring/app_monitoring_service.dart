import 'dart:async';

import 'package:flutter/services.dart';

import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';

import 'package:disciplinum/infrastructure/services/gamification_messages.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart';

import 'package:disciplinum/infrastructure/iap/iap_service.dart';

import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/session_persistence_service.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_service.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';

class AppMonitoringService {
  late final ObjectBoxPreferencesRepository _prefsRepo;
  IapService? _iapService;
  final SessionPersistenceService _sessionPersistence;
  final FocusService? _focusService;

  AppMonitoringService(
    ObjectBoxPreferencesRepository prefsRepo,
    this._sessionPersistence, {
    IapService? iapService,
    FocusService? focusService,
  }) : _focusService = focusService {
    _prefsRepo = prefsRepo;
    _iapService = iapService;
  }

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
  StreamSubscription? _accessibilitySubscription;
  String? _lastAccessibilityApp;

  void setNotificationsPaused(bool value) async {
    notificationsPaused = value;

    if (value) {
      _clearViolationState();
    }

    await _prefsRepo.setBool(_prefsNotificationsPausedKey, value);
  }

  Future<void> startMonitoring({
    required NicheId nicheId,
    required List<String> apps,
  }) async {
    // Reset explícito para evitar contaminação

    _isModuleActive = true;

    currentNicheId = nicheId;

    monitoredApps = List<String>.from(apps);

    await _prefsRepo.setInt(_prefsActiveNicheKey, nicheId.id);

    await _prefsRepo.setStringList(_prefsMonitoredAppsKey, monitoredApps);

    await _prefsRepo.setBool(_prefsNotificationsPausedKey, notificationsPaused);

    // ✅ Persistir estado de monitoramento com Isar
    await _sessionPersistence.saveMonitoringState(
      activeNicheId: nicheId,
      isMonitoringActive: true,
      monitoredApps: apps,
    );

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

    // ✅ Cancelar subscription de acessibilidade (MEMORY LEAK FIX)
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

    await _prefsRepo.remove(_prefsActiveNicheKey);

    await _prefsRepo.remove(_prefsMonitoredAppsKey);

    await _prefsRepo.setBool(_prefsNotificationsPausedKey, notificationsPaused);

    // Limpar estado de monitoramento com Isar
    await _sessionPersistence.clearMonitoringState();

    await _stopForegroundService();
  }

  void _monitorLoop(Timer timer) async {
    try {
      if (!_isModuleActive) {
        timer.cancel();
        return;
      }

      await _saveHeartbeat();
      
      // ✅ Atualizar heartbeat no Isar a cada 60 segundos
      if (timer.tick % 60 == 0) {
        await _sessionPersistence.updateHeartbeat();
      }
      
      // Cleanup periódico a cada 5 minutos
      if (timer.tick % 300 == 0) {
        await _sessionPersistence.cleanupOldSessions();
      }
      
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
        final interval = await _focusService?.getInterval();
        if (!(_focusService?.isWithinInterval(DateTime.now(), interval) ?? false)) {
          _violationStartByApp.clear();
          _warnedApps.clear();
          _lastSeenMonitoredApp.clear();
          _currentForegroundApp = null;
          return;
        }
      }

      // Detectar app em foreground
      final foregroundApp = _lastAccessibilityApp;

      if (foregroundApp == null) return;

      // Se estamos em um app monitorado, continuamos verificando o timeout
      if (monitoredApps.contains(foregroundApp)) {
        await _checkViolationTimeout(foregroundApp);
      } else if (_violationStartByApp.isNotEmpty) {
        // CORREÇÃO: Se não estamos mais em um app monitorado, verificar se devemos cancelar
        // Se está em sistema interativo OU no Disciplinum, manter overlay ativo
        final isDisciplinum = foregroundApp == 'com.disciplinum.app';
        final isInteractiveSystem = _isSystemPackage(foregroundApp);

        if (!isDisciplinum && !isInteractiveSystem) {
          LoggerService.instance.system('Saiu de app monitorado, cancelando todas as violações ativas');
          
          // Pegamos todos os apps ativos e cancelamos para garantir que o timer pare
          final appsToCancel = List<String>.from(_violationStartByApp.keys);
          for (var pkg in appsToCancel) {
            await _cancelViolationForApp(pkg);
          }
        } else {
          // CORREÇÃO: Se está no Disciplinum ou sistema interativo, continuar atualizando o overlay
          LoggerService.instance.system('No Disciplinum/sistema interativo com violação ativa - continuando timer');
          final activeViolationApp = _violationStartByApp.keys.first;
          await _checkViolationTimeout(activeViolationApp);
        }
      }

      // Detectar transições de apps
      if (_currentForegroundApp != null && _currentForegroundApp != foregroundApp) {
        await _handleAppTransition(_currentForegroundApp!, foregroundApp);
      }

      _currentForegroundApp = foregroundApp;
    } catch (e) {
      LoggerService.instance.e('Error in monitor loop', error: e);
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

    await _prefsRepo.setInt(_prefsLastHeartbeatKey, now.millisecondsSinceEpoch);

    _lastHeartbeatSave = now;

    // NOVO: Verificar se período de foco foi concluído

    await _checkFocusPeriodCompletion();
  }

  // NOVO: Verificar conclusão de períodos de foco

  Future<void> _checkFocusPeriodCompletion() async {
    final activeNicheId = currentNicheId;

    if (activeNicheId == null || activeNicheId != NicheId.focus) return;

    return;
  }

  /// Handle real-time accessibility event
  void _handleAccessibilityEvent(String packageName) async {
    if (!_isModuleActive || notificationsPaused) return;

    if (_isSystemPackage(packageName)) {
      _lastAccessibilityApp = packageName;
      return;
    }

    if (packageName != _lastAccessibilityApp) {
      LoggerService.instance.system(
          'Real-time transition (Accessibility): $_lastAccessibilityApp → $packageName');
      await _handleAppTransition(_lastAccessibilityApp, packageName);
      _lastAccessibilityApp = packageName;
    }
  }

  Future<void> _checkRetroactiveViolations(NicheId nicheId) async {
    // Retroatividade agora depende de persistência de sessão e não mais de UsageStats query.
    // O sistema de 30s é resiliente por design.
  }

  Future<void> restoreSession() async {
    // ✅ Primeiro tentar recuperar do Isar
    final monitoringState = await _sessionPersistence.getMonitoringState();
    
    if (monitoringState != null && monitoringState.isMonitoringActive) {
      LoggerService.instance.i('Recuperando estado de monitoramento do Isar');
      
      currentNicheId = monitoringState.activeNicheId;
      monitoredApps = List<String>.from(monitoringState.monitoredApps);
      notificationsPaused = false;
      _isModuleActive = true;
      
      // Recuperar sessões ativas
      final activeSessions = await _sessionPersistence.getActiveSessions();
      if (activeSessions.isNotEmpty) {
        LoggerService.instance.i('Recuperadas ${activeSessions.length} sessões ativas');
        
        // Restaurar violações em andamento
        for (final session in activeSessions) {
          _violationStartByApp[session.packageName] = session.startTime;
          _warnedApps[session.packageName] = session.startTime;
        }
      }
      
      await _startForegroundService();
      await _checkRetroactiveViolations(monitoringState.activeNicheId);
      _restartMonitorTimer();
      return;
    }
    
    // Fallback para SharedPreferences (legado) - agora migrado para Isar via _prefsRepo
    
    // Restore niche
    final savedId = await _prefsRepo.getInt(_prefsActiveNicheKey);

    if (savedId == null) return;

    final nicheId = NicheId.tryFromInt(savedId);

    if (nicheId == null) return;

    // Restore monitored apps - CRITICAL FIX
    final savedApps = await _prefsRepo.getStringList(_prefsMonitoredAppsKey) ?? [];

    if (savedApps.isEmpty) return;

    // Restore state
    currentNicheId = nicheId;
    monitoredApps = List<String>.from(savedApps);
    notificationsPaused = await _prefsRepo.getBool(_prefsNotificationsPausedKey) ?? false;
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

    LoggerService.instance.system('App transition: $fromApp → $toApp');

    // Se saiu de um app monitorado, verificamos se devemos cancelar a violação.
    if (fromApp != null && monitoredApps.contains(fromApp)) {
      // CORREÇÃO: Verificar se foi para sistema interativo (notificações, segurança, etc)
      // Se foi para sistema interativo OU para o próprio Disciplinum, NÃO cancelar
      final isDisciplinum = toApp == 'com.disciplinum.app';
      final isInteractiveSystem = toApp != null && _isInteractiveSystemPackage(toApp);
      
      if (toApp == null || (!monitoredApps.contains(toApp) && !isDisciplinum && !isInteractiveSystem)) {
        LoggerService.instance.system('Saindo de app monitorado $fromApp para $toApp - CANCELANDO violação');
        await _cancelViolationForApp(fromApp);
      } else {
        LoggerService.instance.system(
            'Suspected transition to overlay/notif/launcher (to $toApp). Keeping violation active for $fromApp.');
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
      }
    }
  }

  /// Cancel violation for specific app
  Future<void> _cancelViolationForApp(String packageName) async {
    if (_violationStartByApp.containsKey(packageName)) {
      // Só cancelamos a violação se soubermos que o usuário
      // SAIU do app monitorado E não há carência ativa no buffer
      // ou se ele voltou para o Disciplinum.

      // ✅ Marcar sessão como inativa com Isar
      await _sessionPersistence.markSessionInactive(packageName);

      _violationStartByApp.remove(packageName);
      _warnedApps.remove(packageName);
      _lastSeenMonitoredApp.remove(packageName);

      LoggerService.instance.system('Violation cancelled for $packageName');
    }
  }

  /// Handle monitored app entry

  Future<void> _handleMonitoredAppEntry(String packageName) async {
    final now = DateTime.now();

    _lastSeenMonitoredApp[packageName] = now;

    // Preparar mensagem para o App Lock
    final baseMessage = GamificationMessages.getModuleMessage(
      currentNicheId!,
      isUnlocked: (_iapService?.isCustomNotifUnlocked ?? false),
      customMessages: {},
    );

    // 🚀 INTEGRAÇÃO COM APP LOCK - Substituir overlay por App Lock
    if (!_violationStartByApp.containsKey(packageName)) {
      // Se não há violação ativa para este app, iniciamos uma nova com App Lock
      _warnedApps[packageName] = now;
      _violationStartByApp[packageName] = now;

      // 🎯 MOSTRAR APP LOCK em vez de overlay
      await _showAppLockScreen(packageName, baseMessage);
    } else {
      final start = _violationStartByApp[packageName]!;
      final duration = now.difference(start).inSeconds;

      if (duration >= _violationTimeoutSeconds) {
        await _triggerViolationReset(packageName);
      }
      // Nota: Não atualizamos App Lock como fazíamos com overlay
      // App Lock é uma decisão única, não um countdown
    }
  }

  /// Mostra a tela de App Lock para um app monitorado
  Future<void> _showAppLockScreen(String packageName, String alertMessage) async {
    try {
      final niche = currentNicheId!;
      final appName = _getAppName(packageName);
      
      // Buscar ícone real do app
      final Uint8List? appIconBytes = await InstalledAppService().getAppIcon(packageName);
      
      await AppLockService.instance.showAppLockScreen(
        packageName: packageName,
        appName: appName,
        appIconBytes: appIconBytes,
        nicheId: niche,
        onExitApp: () async {
          LoggerService.instance.gamification('Usuário escolheu sair do app: $appName');
          await _cancelViolationForApp(packageName);
        },
        onOpenApp: () async {
          LoggerService.instance.gamification('Usuário escolheu abrir app: $appName');
          await _triggerViolationReset(packageName);
        },
      );
      
      LoggerService.instance.gamification('App Lock exibido para: $appName');
      
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar App Lock', error: e);
    }
  }

  /// Obtém o nome do app a partir do package name
  String _getAppName(String packageName) {
    // Mapeamento básico de apps conhecidos
    final appNames = {
      'com.whatsapp': 'WhatsApp',
      'com.instagram.android': 'Instagram',
      'com.facebook.katana': 'Facebook',
      'com.twitter.android': 'Twitter',
      'com.tiktok': 'TikTok',
      'com.snapchat.android': 'Snapchat',
      'com.spotify.music': 'Spotify',
      'com.netflix.mediaclient': 'Netflix',
      'com.youtube.android': 'YouTube',
      'com.discord': 'Discord',
      'com.telegram.messenger': 'Telegram',
      'com.google.android.youtube': 'YouTube',
      'com.google.android.gm': 'Gmail',
      'com.google.android.apps.photos': 'Google Photos',
    };
    
    return appNames[packageName] ?? packageName.split('.').last;
  }

  /// Trigger violation reset

  Future<void> _triggerViolationReset(String packageName) async {
    final niche = NicheRepository.getById(currentNicheId!);

    LoggerService.instance.w('TRIGGERING VIOLATION RESET for $packageName');

    // CORREÇÃO: Para Compulsão Alimentar, desativar o módulo quando o overlay termina
    final shouldDeactivate = currentNicheId == NicheId.bingeEating;
    
    if (shouldDeactivate) {
      LoggerService.instance.w('DESATIVANDO módulo ${niche.name} por violação de overlay');
    }

    // Persistir sessão de violação com Isar
    await _sessionPersistence.saveDetectionSession(
      packageName: packageName,
      nicheId: currentNicheId!,
      duration: 30, // 30 segundos de violação
      remainingSeconds: 0, // Violação completou
    );

    _violationStartByApp.remove(packageName);

    _warnedApps.remove(packageName);

    _lastSeenMonitoredApp.remove(packageName);
  }

  void _clearViolationState() {
    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();
    _currentForegroundApp = null;
  }

  /// Identifica pacotes de sistema que são considereados "saída segura" (Launcher, Settings, etc)
  bool _isSystemPackage(String packageName) {
    final systemPackages = [
      'com.android.launcher',
      'com.android.systemui',
      'com.android.settings',
      'com.google.android.apps.nexuslauncher',
      'com.teslacoilsw.launcher.prime',
      'com.microsoft.launcher',
      'com.niagara.launcher',
      'com.smartlauncher.set.v2',
      'com.miui.home',
      'com.huawei.android.launcher',
      'com.oneplus.launcher',
      'com.oppo.launcher',
      'com.vivo.launcher',
      'com.xiaomi.miui.home',
    ];

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

  /// MÉTODO ESSENCIAL: Libera todos os recursos para prevenir memory leaks
  void dispose() {
    try {
      // 1. Cancelar timer de monitoramento
      _monitorTimer?.cancel();
      _monitorTimer = null;
      
      // 2. Cancelar subscription de acessibilidade
      _accessibilitySubscription?.cancel();
      _accessibilitySubscription = null;
      
      // 3. Limpar maps e lists
      _violationStartByApp.clear();
      monitoredApps.clear();
      
      // 4. Limpar estados
      _isModuleActive = false;
      _lastAccessibilityApp = null;
      
      LoggerService.instance.i('AppMonitoringService disposed - memory leaks prevenidos');
    } catch (e) {
      LoggerService.instance.e('Erro ao fazer dispose do AppMonitoringService', error: e);
    }
  }
}
