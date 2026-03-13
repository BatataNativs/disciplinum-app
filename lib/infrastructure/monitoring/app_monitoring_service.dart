import 'dart:async';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço otimizado de monitoramento com HashSet para performance O(1)
/// Implementa detecção híbrida e persistência de estado
class AppMonitoringService {
  static final AppMonitoringService _instance = AppMonitoringService._internal();
  static AppMonitoringService get instance => _instance;

  AppMonitoringService._internal();

  static const String _prefsActiveNicheKey = 'active_niche_id';
  static const String _prefsMonitoredAppsKey = 'active_monitored_apps';
  static const String _prefsNotificationsPausedKey = 'settings_notifications_paused';

  // Estado otimizado com HashSet para performance O(1)
  bool _isModuleActive = false;
  Timer? _monitorTimer;
  Set<String> _monitoredApps = {};
  bool notificationsPaused = false;

  /// Getter para monitoredApps (compatibilidade)
  Set<String> get monitoredApps => _monitoredApps;
  
  /// Setter para monitoredApps (compatibilidade com código existente)
  set monitoredApps(dynamic apps) {
    if (apps is List<String>) {
      _monitoredApps = Set<String>.from(apps);
    } else if (apps is Set<String>) {
      _monitoredApps = apps;
    } else {
      _monitoredApps = Set<String>.from(apps as List);
    }
  }

  // Enhanced state - removido _currentForegroundApp não usado

  // Constants - removido _violationTimeoutSeconds não usado

  // Legacy state (mantido para compatibilidade)
  final Map<String, DateTime> _violationStartByApp = {};
  final Map<String, DateTime> _warnedApps = {};
  final Map<String, DateTime> _lastSeenMonitoredApp = {};
  NicheId? currentNicheId;

  bool get isActive => _isModuleActive;

  // Acessibilidade
  static const _methodChannel = MethodChannel('com.disciplinum.app/accessibility_methods');
  StreamSubscription? _accessibilitySubscription;

  /// Configura notificações como pausadas
  Future<void> setNotificationsPaused(bool value) async {
    notificationsPaused = value;
    if (value) {
      _clearViolationState();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsNotificationsPausedKey, value);
  }

  /// Inicia monitoramento com HashSet para performance O(1)
  Future<void> startMonitoring({
    required NicheId nicheId,
    required Set<String> apps,
  }) async {
    // Reset explícito para evitar contaminação
    _isModuleActive = true;
    currentNicheId = nicheId;

    // Otimização: HashSet para verificação O(1)
    _monitoredApps = Set<String>.from(apps);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsMonitoredAppsKey, apps.toList());

    // Start monitoring
    await _startForegroundService();
  }

  /// Limpa estado de violações
  void _clearViolationState() {
    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();
  }

  /// Valida saúde do sistema
  Future<bool> validateSystemHealth() async {
    return true; // Accessibility service handled nativamente
  }

  /// Inicia serviço foreground
  Future<void> _startForegroundService() async {
    try {
      await _methodChannel.invokeMethod('startAccessibilityService');
    } catch (e) {
      LoggerService.instance.e('Erro ao iniciar serviço de acessibilidade', error: e);
    }
  }

  /// Para monitoramento
  Future<void> stopMonitoring() async {
    _isModuleActive = false;
    _monitorTimer?.cancel();
    _clearViolationState();
    
    try {
      await _methodChannel.invokeMethod('stopAccessibilityService');
    } catch (e) {
      LoggerService.instance.e('Erro ao parar serviço de acessibilidade', error: e);
    }
  }

  /// Restaura sessão
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
    _monitoredApps = Set<String>.from(savedApps);
    notificationsPaused = prefs.getBool(_prefsNotificationsPausedKey) ?? false;
    _isModuleActive = true;
    
    // Start monitoring
    await _startForegroundService();
  }

  /// Obtém apps monitorados (compatibilidade com código existente)
  List<String> get monitoredAppsList => monitoredApps.toList();

  /// Limpa recursos
  void dispose() {
    _monitorTimer?.cancel();
    _accessibilitySubscription?.cancel();
  }
}
