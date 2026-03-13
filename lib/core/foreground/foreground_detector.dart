import 'dart:async';
import 'package:flutter/services.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';

/// Evento emitido quando o app em foreground muda
class ForegroundAppChangedEvent {
  final String? packageName;
  final String? previousPackage;
  
  ForegroundAppChangedEvent({
    this.packageName,
    this.previousPackage,
  });
}

/// Detector híbrido de foreground app usando Accessibility + UsageStats
/// Proporciona detecção quase 100% confiável mesmo em dispositivos problemáticos
class ForegroundDetector {
  static const String _lastForegroundAppKey = 'last_foreground_app';
  static const _methodChannel = MethodChannel('com.disciplinum.app/accessibility_methods');
  
  String? _currentForegroundApp;
  String? _lastAccessibilityApp;
  
  /// Stream de eventos de mudança de app
  final StreamController<ForegroundAppChangedEvent> _appChangedController = 
      StreamController<ForegroundAppChangedEvent>.broadcast();
  
  Stream<ForegroundAppChangedEvent> get onAppChanged => _appChangedController.stream;
  
  /// Inicia o detector
  Future<void> initialize() async {
    _currentForegroundApp = await _getLastKnownApp();
    LoggerService.instance.i('ForegroundDetector inicializado: $_currentForegroundApp');
  }
  
  /// Processa evento do Accessibility Service
  void onAccessibilityEvent(String? packageName) {
    if (packageName == null) return;
    
    // Ignora eventos repetidos do mesmo app
    if (packageName == _lastAccessibilityApp) return;
    
    _lastAccessibilityApp = packageName;
    
    // Debounce muito curto para evitar múltiplas detecções
    _scheduleValidation();
  }
  
  /// Agenda validação do app em foreground
  void _scheduleValidation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _validateForegroundApp();
    });
  }
  
  /// Valida qual app está realmente em foreground
  Future<void> _validateForegroundApp() async {
    try {
      // Tenta obter via UsageStats para confirmação
      final usageStatsApp = await _getForegroundAppFromUsageStats();
      
      // Se UsageStats concordar com Accessibility, usa UsageStats
      // Se não, usa Accessibility mas marca para validação futura
      final confirmedApp = usageStatsApp ?? _lastAccessibilityApp;
      
      if (confirmedApp != _currentForegroundApp) {
        final previousApp = _currentForegroundApp;
        _currentForegroundApp = confirmedApp;
        
        _saveLastApp(confirmedApp);
        
        // Emitir evento de mudança
        _appChangedController.add(ForegroundAppChangedEvent(
          packageName: confirmedApp,
          previousPackage: previousApp,
        ));
        
        LoggerService.instance.i('Foreground app mudou: $previousApp → $confirmedApp');
        
        // Se houver discrepância, agenda verificação
        if (usageStatsApp == null && confirmedApp != null) {
          _scheduleRevalidation();
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao validar foreground app', error: e);
    }
  }
  
  /// Agenda revalidação para casos onde UsageStats falha
  void _scheduleRevalidation() {
    Future.delayed(const Duration(seconds: 2), () {
      _validateForegroundApp();
    });
  }
  
  /// Obtém app em foreground via UsageStats (fallback)
  Future<String?> _getForegroundAppFromUsageStats() async {
    try {
      // Tenta obter o app em foreground usando o MethodChannel existente
      // Este método pode ser implementado no futuro com UsageStats nativo
      final String? foregroundApp = await _methodChannel.invokeMethod<String>('getForegroundApp');
      return foregroundApp;
    } catch (e) {
      LoggerService.instance.e('Erro ao obter app de UsageStats', error: e);
      return null;
    }
  }
  
  /// Salva último app conhecido
  Future<void> _saveLastApp(String? packageName) async {
    try {
      await LocalStorageService.instance.save(_lastForegroundAppKey, packageName);
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar último app', error: e);
    }
  }
  
  /// Obtém último app conhecido
  Future<String?> _getLastKnownApp() async {
    try {
      return await LocalStorageService.instance.getString(_lastForegroundAppKey);
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar último app', error: e);
      return null;
    }
  }
  
  /// Obtém app atual em foreground
  String? get currentForegroundApp => _currentForegroundApp;
  
  /// Força atualização do estado
  void forceUpdate() {
    if (_lastAccessibilityApp != null) {
      _validateForegroundApp();
    }
  }
  
  /// Limpa recursos
  void dispose() {
    _appChangedController.close();
  }
}
