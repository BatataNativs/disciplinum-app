import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';

class PrivacyService {
  static const String _analyticsEnabledKey = 'analytics_enabled';
  static bool _initialized = false;
  static late ObjectBoxPreferencesRepository _prefs;

  /// Inicializa o tracking baseado na preferência salva.
  /// (Default: true, pois no onboarding inicial assumimos consentimento implícito, 
  /// mas o usuário pode revogar na tela de ConsentDialog ou Configurações)
  static Future<void> initAtStartup() async {
    if (kIsWeb) return;
    if (_initialized) return;

    _prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);

    // Garante Firebase init
    await Firebase.initializeApp();

    // Configura Crashlytics para erros fatais
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    final analyticsEnabled = await _prefs.getBool(_analyticsEnabledKey) ?? true;

    if (analyticsEnabled) {
      await _enableTracking();
    } else {
      await disableTracking();
    }

    _initialized = true;
  }

  static Future<void> _enableTracking() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    LoggerService.instance.system('Tracking ENABLED');
  }

  // Desativa a coleta de dados de analytics e crashlytics
  static Future<void> disableTracking() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    LoggerService.instance.system('Tracking DISABLED');
  }

  /// Altera a preferência de Analytics em tempo de execução
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    if (!_initialized) {
      // Caso seja chamado antes de inicializar (embora improvável)
      _prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
    }
    
    await _prefs.setBool(_analyticsEnabledKey, enabled);
    
    if (enabled) {
      await _enableTracking();
    } else {
      await disableTracking();
    }
  }

  /// Consulta o estado atual da preferência de Analytics
  static Future<bool> isAnalyticsEnabled() async {
    if (!_initialized) {
      _prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
    }
    return await _prefs.getBool(_analyticsEnabledKey) ?? true;
  }
}
