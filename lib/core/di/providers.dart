import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service_isar.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/controllers/procrastination_controller_isar.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/infrastructure/monitoring/app_monitoring_service.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/infrastructure/ads/ad_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart' as iap;
import 'package:disciplinum/infrastructure/iap/domain/repositories/iap_entitlement_repository.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart' as auth;
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_service.dart';
import 'package:disciplinum/core/theme/theme_controller.dart';
import 'package:disciplinum/infrastructure/repositories/module_repository.dart';
import 'package:disciplinum/infrastructure/datasources/local_module_datasource.dart';
import 'package:disciplinum/infrastructure/datasources/cloud_module_datasource.dart';
import 'package:disciplinum/features/modules/reading/data/repositories/reading_repository.dart';
import 'package:disciplinum/features/modules/reading/gamification/data/repositories/reading_gamification_repository.dart';



import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service_isar.dart';
import 'package:disciplinum/features/modules/reading/presentation/controllers/reading_controller_isar.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service_wrapper.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_checkin_service.dart';
import 'package:disciplinum/features/modules/smoking/presentation/controllers/stop_smoking_controller.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service_isar.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service_isar.dart';
import 'package:disciplinum/features/modules/focus/presentation/controllers/focus_controller_isar.dart';
import 'package:disciplinum/core/storage/session_persistence_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service_isar.dart';
import 'package:disciplinum/features/modules/adult_content/presentation/controllers/adult_content_controller_isar.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/presentation/providers/adult_content_gamification_provider.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/presentation/providers/binge_eating_gamification_provider.dart';
import 'package:disciplinum/features/modules/diet/gamification/presentation/providers/diet_gamification_provider.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/presentation/providers/money_saving_gamification_provider.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/services/money_saving_gamification_service.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/presentation/providers/procrastination_gamification_provider.dart';
import 'package:disciplinum/features/modules/smoking/gamification/presentation/providers/smoking_gamification_provider.dart';
import 'package:disciplinum/features/modules/spending/gamification/presentation/providers/spending_gamification_provider.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service_isar.dart';
import 'package:disciplinum/features/modules/diet/presentation/controllers/diet_controller_isar.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_insignia_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_medalha_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_special_notifications_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_gamification_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_celebration_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_insignia_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_medalha_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_notification_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_celebration_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';

/// Provider para IsarService
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
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
  // SmokingCheckinService ainda usa SharedPreferences e precisa de migração futura
  // Por enquanto, desabilitado para evitar erros de compilação
  throw UnimplementedError('SmokingCheckinService temporariamente desabilitado - migração pendente');
});

/// Provider para BingeEatingServiceIsar
final bingeEatingServiceIsarProvider = Provider<BingeEatingServiceIsar>((ref) {
  return BingeEatingServiceIsar.instance;
});

/// Provider para BingeEatingService (legado)
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
final iapServiceProvider = StateNotifierProvider<iap.IapService, iap.IapState>((ref) {
  final isar = ref.watch(isarServiceProvider);
  final repository = IapEntitlementRepository(isar.database);
  return iap.IapService(repository);
});

/// Provider para AuthService
final authServiceProvider = StateNotifierProvider<auth.AuthService, auth.AuthState>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  return auth.AuthService(prefs, cloudSync);
});

/// Provider para obter o userId atual do usuário autenticado
final currentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authServiceProvider);
  return authState.currentUser?.id ?? 'guest_user';
});

final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController();
});

/// Provider para AppMonitoringService
final appMonitoringServiceProvider = Provider<AppMonitoringService>((ref) {
  final prefs = ref.watch(isarPreferencesRepositoryProvider);
  final sessionPersistence = ref.watch(sessionPersistenceServiceProvider);
  final focusService = ref.watch(focusServiceProvider);
  
  return AppMonitoringService(
    prefs,
    sessionPersistence,
    focusService: focusService,
  );
});



// ============= AUTH SERVICES =============

/// Provider para AdultContentServiceIsar
final adultContentServiceIsarProvider = Provider<AdultContentServiceIsar>((ref) {
  return AdultContentServiceIsar.instance;
});

/// Provider para AdultContentControllerIsar
final adultContentControllerIsarProvider = StateNotifierProvider<AdultContentControllerIsar, AdultContentState>((ref) {
  final service = ref.watch(adultContentServiceIsarProvider);
  return AdultContentControllerIsar(service);
});

/// Provider para AdultContentService (legado)
final adultContentServiceProvider = Provider<AdultContentService>((ref) {
  final repository = ref.watch(isarPreferencesRepositoryProvider);
  return AdultContentService(repository);
});

/// Provider para DietServiceIsar
final dietServiceIsarProvider = Provider<DietServiceIsar>((ref) {
  return DietServiceIsar.instance;
});

/// Provider para DietControllerIsar
final dietControllerIsarProvider = StateNotifierProvider<DietControllerIsar, DietState>((ref) {
  final service = ref.watch(dietServiceIsarProvider);
  return DietControllerIsar(service);
});

/// Provider para DietService (legado)
final dietServiceProvider = Provider<DietService>((ref) {
  final repository = ref.watch(isarPreferencesRepositoryProvider);
  return DietService(repository);
});

/// Provider para ProcrastinationServiceIsar
final procrastinationServiceIsarProvider = Provider<ProcrastinationServiceIsar>((ref) {
  return ProcrastinationServiceIsar.instance;
});

/// Provider para ProcrastinationControllerIsar
final procrastinationControllerIsarProvider = StateNotifierProvider<ProcrastinationControllerIsar, ProcrastinationState>((ref) {
  final service = ref.watch(procrastinationServiceIsarProvider);
  return ProcrastinationControllerIsar(service);
});

/// Provider para ProcrastinationService (serviço de listas de tarefas)
final procrastinationServiceProvider = Provider<ProcrastinationService>((ref) {
  final repository = ref.watch(isarPreferencesRepositoryProvider);
  return ProcrastinationService(repository);
});


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

/// Provider para FocusServiceIsar
final focusServiceIsarProvider = Provider<FocusServiceIsar>((ref) {
  return FocusServiceIsar.instance;
});

/// Provider para FocusControllerIsar
final focusControllerIsarProvider = StateNotifierProvider<FocusControllerIsar, FocusState>((ref) {
  final service = ref.watch(focusServiceIsarProvider);
  return FocusControllerIsar(service);
});

/// Provider para ReadingServiceIsar
final readingServiceIsarProvider = Provider<ReadingServiceIsar>((ref) {
  return ReadingServiceIsar.instance;
});

/// Provider para ReadingControllerIsar
final readingControllerIsarProvider = StateNotifierProvider<ReadingControllerIsar, ReadingState>((ref) {
  final service = ref.watch(readingServiceIsarProvider);
  return ReadingControllerIsar(service);
});


/// Provider para ReadingService (alternativo)
final readingServiceProvider = Provider<ReadingService>((ref) {
  final repository = ref.watch(readingRepositoryProvider);
  final gamificationRepository = ref.watch(readingGamificationRepositoryProvider);
  return ReadingService(repository, gamificationRepository, null);
});


final spendingServiceProvider = Provider<SpendingService>((ref) {
  return SpendingService(ref);
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

/// Provider para SmokingGamificationService
final smokingGamificationServiceProvider = Provider<SmokingGamificationService>((ref) {
  final repository = ref.watch(smokingGamificationRepositoryProvider);
  return SmokingGamificationService(repository);
});

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final prefs = ref.watch(isarPreferencesRepositoryProvider);
  return CloudSyncService(
    supabase: Supabase.instance.client,
    prefsRepo: prefs,
  );
});

/// Provider para AdService
final adServiceProvider = StateNotifierProvider<AdService, AdState>((ref) {
  return AdService();
});

/// Provider para ReadingRepository
final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  return ReadingRepository();
});

/// Provider para ReadingGamificationRepository
final readingGamificationRepositoryProvider = Provider<ReadingGamificationRepository>((ref) {
  return ReadingGamificationRepository.instance;
});

/// Provider para MoneySavingGamificationRepository
final moneySavingOperationRepositoryProvider = Provider<MoneySavingGamificationRepository>((ref) {
  return MoneySavingGamificationRepository.instance;
});

/// Provider para MoneySavingGamificationService
final moneySavingGamificationServiceProvider = StateNotifierProvider<MoneySavingGamificationService, MoneySavingModuleState?>((ref) {
  final repository = ref.watch(moneySavingOperationRepositoryProvider);
  return MoneySavingGamificationService(repository);
});

/// Provider para verificar se o módulo Focus está ativo
final focusActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(focusControllerIsarProvider);
  return state.config?.isEnabled ?? false;
});

/// Provider para verificar se o módulo Reading está ativo
final readingActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(readingControllerIsarProvider);
  // Reading é considerado ativo se notificações estão habilitadas ou há streak
  return state.config?.enableNotifications == true || (state.config?.currentStreak ?? 0) > 0;
});

/// Provider combinado para obter lista de módulos ativos (gamificação fragmentada)
final activeModulesProvider = Provider<List<NicheId>>((ref) {
  final activeModules = <NicheId>[];
  
  // Verificar cada módulo usando seus providers locais
  if (ref.watch(smokingActiveProvider)) activeModules.add(NicheId.smoking);
  if (ref.watch(adultContentActiveProvider)) activeModules.add(NicheId.adultContent);
  if (ref.watch(bingeEatingActiveProvider)) activeModules.add(NicheId.bingeEating);
  if (ref.watch(dietActiveProvider)) activeModules.add(NicheId.diet);
  if (ref.watch(focusActiveProvider)) activeModules.add(NicheId.focus);
  if (ref.watch(moneySavingActiveProvider)) activeModules.add(NicheId.moneySavingChallenge);
  if (ref.watch(procrastinationActiveProvider)) activeModules.add(NicheId.procrastination);
  if (ref.watch(readingActiveProvider)) activeModules.add(NicheId.reading);
  if (ref.watch(spendingActiveProvider)) activeModules.add(NicheId.spending);
  
  return activeModules;
});

/// Provider combinado para obter medalhas pendentes de todos os módulos
/// Sistema completo de medalhas - agrega medalhas de todos os módulos ativos
final pendingMedalsProvider = Provider<Future<List<String>>>((ref) async {
  final pendingMedals = <String>[];
  
  // Adult Content - via controller
  try {
    final adultContentController = ref.watch(adultContentGamificationControllerProvider);
    pendingMedals.addAll(adultContentController.earnedMedalhas);
  } catch (_) {}
  
  // Procrastination - via controller
  try {
    final procrastinationController = ref.watch(procrastinationGamificationControllerProvider);
    pendingMedals.addAll(procrastinationController.earnedMedalhas);
  } catch (_) {}
  
  // Spending - via controller
  try {
    final spendingController = ref.watch(spendingGamificationControllerProvider);
    pendingMedals.addAll(spendingController.earnedMedalhas);
  } catch (_) {}
  
  // Smoking - via gamification service
  try {
    final smokingService = ref.watch(smokingGamificationServiceProvider);
    final medalhas = await smokingService.medalhaService.getEarnedMedalhas();
    pendingMedals.addAll(medalhas);
  } catch (_) {}
  
  // Money Saving - via gamification service
  try {
    final moneyState = ref.watch(moneySavingGamificationStateProvider);
    final data = moneyState.valueOrNull ?? {};
    final medalhas = (data['earnedMedalhas'] as List<dynamic>?)?.cast<String>() ?? [];
    pendingMedals.addAll(medalhas);
  } catch (_) {}
  
  return pendingMedals;
});






