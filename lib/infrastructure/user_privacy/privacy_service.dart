import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class PrivacyService {
  static bool _initialized = false;

  /// Inicializa e ATIVA tracking (consentimento implícito via Welcome Screen).
  static Future<void> initAtStartup() async {
    if (kIsWeb) return;
    if (_initialized) return;

    // Garante Firebase init
    await Firebase.initializeApp();

    // Configura Crashlytics para erros fatais
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Como o usuário aceitou os termos ao entrar, ativamos o tracking padrão.
    // Se no futuro você criar um botão "Desativar Analytics" nas configurações,
    // você voltaria a usar SharedPreferences aqui para checar essa preferência.
    await _enableTracking();

    _initialized = true;
  }

  static Future<void> _enableTracking() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    LoggerService.instance.system('Tracking ENABLED (Implicit Consent)');
  }

  // Método utilitário caso queira implementar Opt-out futuro
  static Future<void> disableTracking() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    LoggerService.instance.system('Tracking DISABLED');
  }
}
