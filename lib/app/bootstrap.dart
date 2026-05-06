import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/infrastructure/user_privacy/privacy_service.dart';
import 'package:disciplinum/config/app_config.dart';
import 'package:disciplinum/app/startup_data.dart';
import 'package:disciplinum/core/network/network_health_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/background/background_achievement_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

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
      // Inicialização paralela dos serviços independentes
      await Future.wait([
        _initSupabase(),
        _initAds(),
        _initTheme(),
      ]);

      // Inicializar serviços que dependem de outros (sequencial)
      await _initServices();  // Inicializa Isar
      
      // Inicializar serviços que dependem do ObjectBox
      await _initNotifications();
      await _initStorage();

      // Usar LocalStorageService em vez de SharedPreferences diretos
      final prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
      final seenOnboarding = await prefs.getBool('seen_onboarding') ?? false;

      _isInitialized = true;

      return AppStartupData(
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
      
      // Registrar callbacks para check-ins dos módulos
      _registerCheckInCallbacks();

      // Inicializar serviço de background para notificações de conquistas
      await _initBackgroundAchievementService();
      
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error initializing notifications', error: e);
      }
      // Notificações não são críticas para funcionamento básico
    }
  }

  /// Inicializa o serviço de background para conquistas
  static Future<void> _initBackgroundAchievementService() async {
    try {
      LoggerService.instance.i('🚀 Inicializando serviço de background...');
      
      // Inicializar o serviço
      await BackgroundAchievementService.instance.initialize();
      
      // Agendar verificações periódicas
      await BackgroundAchievementService.instance.scheduleAchievementChecks();
      await BackgroundAchievementService.instance.scheduleStreakChecks();
      
      LoggerService.instance.i('✅ Serviço de background inicializado');
    } catch (e) {
      if (kDebugMode) {
        LoggerService.instance.e('Error initializing background service', error: e);
      }
      // Background não é crítico, apenas logar erro
    }
  }
  
  /// Registra callbacks para check-ins das notificações
  static void _registerCheckInCallbacks() {
    // Check-in Smoking - Quando usuário responde "Sim" (não fumou)
    ns.NotificationService.onCheckInSim = (payload) async {
      LoggerService.instance.i('✅ Check-in Smoking via notificação');
      
      // Emite evento para que o SmokingCheckinService processe o check-in
      EventEmitHelper.emitModuleCheckIn(
        nicheId: NicheId.smoking.index,
        isPositive: true,
        checkInDate: DateTime.now(),
      );
    };
    
    // Relapse Smoking - Quando usuário responde "Não" (fumou)
    ns.NotificationService.onRelapseDetected = (payload) async {
      LoggerService.instance.i('❌ Relapse Smoking detectado via notificação');
      
      // Emite evento de relapse
      EventEmitHelper.emitSmokingRelapse(
        nicheId: NicheId.smoking.index,
        reason: 'Resposta negativa no check-in via notificação',
        previousStreak: 0, // Será atualizado pelo listener
      );
    };
    
    LoggerService.instance.i('✅ Callbacks de check-in registrados');
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
      // ✅ Inicializar ObjectBox primeiro (dependência para SessionPersistenceService)
      await ObjectBoxService.instance.initialize();
      
      // SessionPersistenceService agora é injetado via Riverpod
      
      // Inicializar serviços em ordem de dependência
      await PrivacyService.initAtStartup();

      // Inicializar monitoramento de rede
      NetworkHealthService().startHealthCheck();

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
