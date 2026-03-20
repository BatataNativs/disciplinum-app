import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/infrastructure/user_privacy/privacy_service.dart';
import 'package:disciplinum/config/app_config.dart';
import 'package:disciplinum/app/startup_data.dart';

// Import para notificações
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart'
    as ns;

/// Responsável por inicializar todos os serviços do aplicativo
/// Substitui a lógica espalhada no main.dart
class AppBootstrap {
  static bool _isInitialized = false;

  /// Inicializa todos os serviços em paralelo para performance
  static Future<AppStartupData> initialize() async {
    if (_isInitialized) {
      throw StateError('AppBootstrap already initialized');
    }

    try {
      // Inicialização paralela para melhor performance
      await Future.wait([
        _initStorage(),
        _initSupabase(),
        _initNotifications(),
        _initAds(),
        _initServices(),
        _initTheme(),
      ]);

      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

      _isInitialized = true;

      return AppStartupData(
        prefs: prefs,
        seenOnboarding: seenOnboarding,
      );
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error during app bootstrap', error: e);
      }
      rethrow;
    }
  }

  /// Inicializa o serviço de storage
  static Future<void> _initStorage() async {
    try {
      await LocalStorageService.init();
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error initializing storage', error: e);
      }
      // Storage é crítico, relançar erro
      rethrow;
    }
  }

  /// Inicializa o Supabase
  static Future<void> _initSupabase() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error initializing Supabase', error: e);
      }
      // Supabase é crítico para cloud sync, mas app pode funcionar offline
      // Não relançar erro, apenas logar
    }
  }

  /// Inicializa o serviço de notificações
  static Future<void> _initNotifications() async {
    try {
      await ns.initNotifications();
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error initializing notifications', error: e);
      }
      // Notificações não são críticas para funcionamento básico
    }
  }

  /// Inicializa os anúncios
  static Future<void> _initAds() async {
    try {
      if (kIsWeb) return;

      final testDeviceId = AppConfig.admobTestDeviceId;
      final testDevices =
          testDeviceId.isNotEmpty ? <String>[testDeviceId] : <String>[];

      if (testDevices.isNotEmpty) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: testDevices),
        );
      }

      MobileAds.instance.initialize();
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error initializing ads', error: e);
      }
      // Anúncios não são críticos para funcionamento
    }
  }

  /// Inicializa os serviços principais
  static Future<void> _initServices() async {
    try {
      // ✅ Inicializar Isar primeiro (dependência para SessionPersistenceService)
      await IsarService.instance.initialize();
      
      // SessionPersistenceService agora é injetado via Riverpod
      
      // Inicializar serviços em ordem de dependência
      await PrivacyService.initAtStartup();

      // GamificationService usa Provider, então inicializar depois
      // Ele será criado via Provider no runApp
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error initializing services', error: e);
      }
      rethrow;
    }
  }

  /// Inicializa o tema
  static Future<void> _initTheme() async {
    try {
      // ThemeController não tem método initialize, vamos criar uma instância
      // O tema será carregado quando necessário
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error initializing theme', error: e);
      }
      // Theme não é crítico, usa tema padrão em caso de erro
    }
  }

  /// Verifica se o app foi inicializado
  static bool get isInitialized => _isInitialized;

  /// Reseta o estado (para testes)
  static void reset() {
    _isInitialized = false;
  }
}
