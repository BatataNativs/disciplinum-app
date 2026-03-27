import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/infrastructure/monitoring/app_monitoring_service.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_service.dart';
import 'package:disciplinum/core/theme/theme_controller.dart';
import 'package:disciplinum/features/gamification/presentation/controllers/gamification_controller.dart';
import 'package:disciplinum/infrastructure/repositories/module_repository.dart';
import 'package:disciplinum/infrastructure/datasources/local_module_datasource.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/infrastructure/datasources/cloud_module_datasource.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service_wrapper.dart';
import 'package:disciplinum/core/di/adapters/reading_service_adapter.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/infrastructure/ads/ad_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_checkin_service.dart';
import 'package:disciplinum/features/modules/smoking/presentation/controllers/stop_smoking_controller.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_checkin_service.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart';
import 'package:disciplinum/core/storage/session_persistence_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_insignia_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_medalha_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_special_notifications_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_celebration_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_insignia_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_medalha_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_notification_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_celebration_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';

/// Provider para IsarService
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

/// Provider para SharedPreferences
/// Assumindo que já foi inicializado no bootstrap
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences deve ser sobrescrito no ProviderScope');
});

/// Provider para BingeEatingGamificationRepository
final bingeEatingGamificationRepositoryProvider = Provider<BingeEatingGamificationRepository>((ref) {
  return BingeEatingGamificationRepository.instance;
});

/// Provider para DietGamificationRepository
final dietGamificationRepositoryProvider = Provider<DietGamificationRepository>((ref) {
  return DietGamificationRepository.instance;
});

/// Provider para MoneySavingGamificationRepository
final moneySavingGamificationRepositoryProvider = Provider<MoneySavingGamificationRepository>((ref) {
  return MoneySavingGamificationRepository.instance;
});

/// Provider para SessionPersistenceService
final sessionPersistenceServiceProvider = Provider<SessionPersistenceService>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return SessionPersistenceService(isarService);
});

/// Provider para SmokingCheckinService
final smokingCheckinServiceProvider = Provider<SmokingCheckinService>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return SmokingCheckinService(isarService, cloudSync, prefs);
});

/// Provider para BingeEatingCheckinService
final bingeEatingCheckinServiceProvider = Provider<BingeEatingCheckinService>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return BingeEatingCheckinService(isarService, cloudSync, prefs);
});

/// Provider para BingeEatingService
final bingeEatingServiceProvider = Provider<BingeEatingService>((ref) {
  final repository = ref.watch(isarPreferencesRepositoryProvider);
  return BingeEatingService(repository);
});

/// Provider para ModuleRepository
final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  return ModuleRepository(
    localDatasource: LocalModuleDatasource(),
    cloudDatasource: CloudModuleDatasource(),
  );
});

/// Provider para IsarPreferencesRepository
final isarPreferencesRepositoryProvider = Provider<IsarPreferencesRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return IsarPreferencesRepository(isarService.database);
});

/// Provider para LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

/// Provider para LoggerService
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService.instance;
});

/// Provider para PreferencesService
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(isarPreferencesRepositoryProvider);
  return PreferencesService(prefs);
});

/// Provider para smokingServiceProvider
final smokingServiceProvider = Provider<SmokingService>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return SmokingService(prefs);
});

/// Provider para IapService
final iapServiceProvider = ChangeNotifierProvider<IapService>((ref) {
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  final prefsRepo = ref.watch(isarPreferencesRepositoryProvider);
  return IapService(cloudSync, prefsRepo)..initialize();
});

/// Provider para AuthService
final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  return AuthService(prefs, cloudSync);
});

final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController();
});

/// Provider para AppMonitoringService
final appMonitoringServiceProvider = Provider<AppMonitoringService>((ref) {
  final prefs = ref.watch(isarPreferencesRepositoryProvider);
  final sessionPersistence = ref.watch(sessionPersistenceServiceProvider);
  final iapService = ref.watch(iapServiceProvider);
  final focusService = ref.watch(focusServiceProvider);
  return AppMonitoringService(
    prefs,
    sessionPersistence,
    iapService: iapService,
    focusService: focusService,
  );
});

/// Provider para GamificationAwardEngine
final gamificationAwardEngineProvider = Provider<GamificationAwardEngine>((ref) {
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  return GamificationAwardEngine(cloudSync);
});

/// Provider para GamificationService
final gamificationServiceProvider = ChangeNotifierProvider<GamificationService>((ref) {
  final appMonitoring = ref.watch(appMonitoringServiceProvider);
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  final awardEngine = ref.watch(gamificationAwardEngineProvider);
  final iapService = ref.watch(iapServiceProvider);
  final smokingCheckin = ref.watch(smokingCheckinServiceProvider);
  final bingeEatingCheckin = ref.watch(bingeEatingCheckinServiceProvider);
  final focusService = ref.watch(focusServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return GamificationService(
    cloudSync,
    appMonitoring,
    awardEngine,
    iapService,
    smokingCheckin,
    bingeEatingCheckin,
    focusService,
    prefs,
  );
});

final gamificationControllerProvider = ChangeNotifierProvider<GamificationController>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GamificationController(
    moduleRepository: ref.watch(moduleRepositoryProvider),
    authService: authService,
  );
});

// ============= AUTH SERVICES =============

/// Provider para AdultContentService
final adultContentServiceProvider = Provider<AdultContentService>((ref) {
  final repository = ref.watch(isarPreferencesRepositoryProvider);
  return AdultContentService(repository);
});

/// Provider para DietService
final dietServiceProvider = Provider<DietService>((ref) {
  final repository = ref.watch(isarPreferencesRepositoryProvider);
  return DietService(repository);
});

/// Provider para ProcrastinationService
final procrastinationServiceProvider = Provider<ProcrastinationService>((ref) {
  final gamification = ref.watch(gamificationServiceProvider);
  final repository = ref.watch(isarPreferencesRepositoryProvider);
  return ProcrastinationService(gamification, repository);
});

/// Provider para MoneySavingChallengeService
final moneySavingChallengeServiceProvider = Provider<MoneySavingChallengeService>((ref) {
  final repository = ref.watch(isarPreferencesRepositoryProvider);
  return MoneySavingChallengeService(repository);
});

/// Provider para StopSmokingController
final stopSmokingControllerProvider = StateNotifierProvider<StopSmokingController, StopSmokingState>((ref) {
  final smokingService = ref.watch(smokingServiceProvider);
  return StopSmokingController(smokingService);
});

final focusServiceProvider = Provider<FocusService>((ref) {
  return FocusService(
    ref.watch(isarServiceProvider),
    ref.watch(cloudSyncServiceProvider),
  );
});

/// Provider para ReadingService
final readingServiceProvider = ChangeNotifierProvider<ReadingService>((ref) {
  final prefs = ref.watch(isarPreferencesRepositoryProvider);
  final gamification = ref.watch(gamificationServiceProvider);
  return ReadingService(prefs, gamification);
});

/// Provider para SpendingService
final spendingServiceProvider = Provider<SpendingService>((ref) {
  return SpendingService(ref);
});

/// Provider para ReadingServiceAdapter
final readingServiceAdapterProvider = Provider<ReadingServiceAdapter>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final readingService = ref.watch(readingServiceProvider);
  return ReadingServiceAdapter(localStorage, readingService);
});

/// Provider para o estado de Onboarding (injetado no main.dart)
final seenOnboardingProvider = Provider<bool>((ref) => throw UnimplementedError());

// ==================== GAMIFICATION PROVIDERS ====================

/// Provider para SmokingInsigniaService
final smokingInsigniaServiceProvider = Provider<SmokingInsigniaService>((ref) {
  return SmokingInsigniaService();
});

/// Provider para SmokingMedalhaService
final smokingMedalhaServiceProvider = Provider<SmokingMedalhaService>((ref) {
  return SmokingMedalhaService();
});

/// Provider para SmokingSpecialNotificationsService
final smokingSpecialNotificationsServiceProvider = Provider<SmokingSpecialNotificationsService>((ref) {
  return SmokingSpecialNotificationsService.instance;
});

/// Provider para SmokingCelebrationService
final smokingCelebrationServiceProvider = Provider<SmokingCelebrationService>((ref) {
  return SmokingCelebrationService.instance;
});

/// Provider para FocusInsigniaService
final focusInsigniaServiceProvider = Provider<FocusInsigniaService>((ref) {
  final focusService = ref.watch(focusServiceProvider);
  return FocusInsigniaService(focusService);
});

/// Provider para FocusMedalhaService
final focusMedalhaServiceProvider = Provider<FocusMedalhaService>((ref) {
  return FocusMedalhaService();
});

/// Provider para FocusNotificationService
final focusNotificationServiceProvider = Provider<FocusNotificationService>((ref) {
  return FocusNotificationService();
});

/// Provider para FocusCelebrationService
final focusCelebrationServiceProvider = Provider<FocusCelebrationService>((ref) {
  return FocusCelebrationService.instance;
});

/// Provider para FocusGamificationRepository
final focusGamificationRepositoryProvider = Provider<FocusGamificationRepository>((ref) {
  return FocusGamificationRepository.instance;
});

/// Provider para SmokingGamificationRepository
final smokingGamificationRepositoryProvider = Provider<SmokingGamificationRepository>((ref) {
  return SmokingGamificationRepository.instance;
});

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final prefs = ref.watch(isarPreferencesRepositoryProvider);
  return CloudSyncService(
    supabase: Supabase.instance.client,
    prefsRepo: prefs,
  );
});

/// Provider para AdService
final adServiceProvider = ChangeNotifierProvider<AdService>((ref) {
  return AdService();
});
