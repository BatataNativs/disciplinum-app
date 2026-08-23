import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/core/modules/sync/sync_validation_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service_local.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/controllers/procrastination_controller_local.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/infrastructure/monitoring/app_monitoring_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/infrastructure/ads/ad_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/infrastructure/backup/local_backup_service.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart' as iap;
import 'package:disciplinum/infrastructure/iap/domain/repositories/iap_entitlement_repository.dart';
import 'package:disciplinum/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:disciplinum/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:disciplinum/features/auth/domain/repositories/auth_repository.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_state.dart' as auth_state;
import 'package:disciplinum/features/auth/presentation/controllers/auth_controller.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/entities/digital_detox_gamification_entity.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/repositories/digital_detox_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_service.dart';
import 'package:disciplinum/core/theme/theme_controller.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/infrastructure/repositories/module_repository.dart';
import 'package:disciplinum/infrastructure/datasources/local_module_datasource.dart';
import 'package:disciplinum/infrastructure/datasources/cloud_module_datasource.dart';
import 'package:disciplinum/features/modules/reading/data/repositories/reading_repository.dart';
import 'package:disciplinum/features/modules/reading/gamification/data/repositories/reading_gamification_repository.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service_local.dart';
import 'package:disciplinum/features/modules/reading/presentation/controllers/reading_controller_local.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service_wrapper.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_checkin_service.dart';
import 'package:disciplinum/features/modules/smoking/presentation/controllers/stop_smoking_controller.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service_local.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service_local.dart';
import 'package:disciplinum/features/modules/focus/presentation/controllers/focus_controller.dart';
import 'package:disciplinum/core/storage/session_persistence_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service_local.dart';
import 'package:disciplinum/features/modules/adult_content/presentation/controllers/adult_content_controller_local.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/presentation/providers/adult_content_gamification_provider.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/presentation/providers/binge_eating_gamification_provider.dart';
import 'package:disciplinum/features/modules/diet/gamification/presentation/providers/diet_gamification_provider.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/presentation/providers/money_saving_gamification_provider.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/presentation/providers/procrastination_gamification_provider.dart';
import 'package:disciplinum/features/modules/smoking/gamification/presentation/providers/smoking_gamification_provider.dart';
import 'package:disciplinum/features/modules/spending/gamification/presentation/providers/spending_gamification_provider.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_insignia_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_medalha_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_special_notifications_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_celebration_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';

/// Provider para ObjectBoxService
final objectBoxServiceProvider = Provider<ObjectBoxService>((ref) {
  return ObjectBoxService.instance;
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
  final objectBoxService = ref.watch(objectBoxServiceProvider);
  return SessionPersistenceService(objectBoxService);
});

/// Provider para SmokingCheckinService
final smokingCheckinServiceProvider = Provider<SmokingCheckinService>((ref) {
  final objectBoxService = ref.watch(objectBoxServiceProvider);
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  final insigniaService = ref.watch(smokingInsigniaServiceProvider);
  // SmokingCheckinService 100% ObjectBox - zero SharedPreferences
  return SmokingCheckinService(objectBoxService, cloudSync, insigniaService);
});

/// Provider para BingeEatingServiceLocal
final bingeEatingServiceLocalProvider = Provider<BingeEatingServiceLocal>((ref) {
  return BingeEatingServiceLocal.instance;
});

/// Provider para BingeEatingService (legado)
final bingeEatingServiceProvider = Provider<BingeEatingService>((ref) {
  final repository = ref.watch(objectboxPreferencesRepositoryProvider);
  return BingeEatingService(repository);
});

/// Provider para ModuleRepository
final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  return ModuleRepository(
    localDatasource: LocalModuleDatasource(),
    cloudDatasource: CloudModuleDatasource(),
  );
});

/// Provider para ObjectBoxPreferencesRepository
final objectboxPreferencesRepositoryProvider = Provider<ObjectBoxPreferencesRepository>((ref) {
  final objectBoxService = ref.watch(objectBoxServiceProvider);
  return ObjectBoxPreferencesRepository(objectBoxService.store);
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
  final prefs = ref.watch(objectboxPreferencesRepositoryProvider);
  return PreferencesService(prefs);
});

const _appLocalePreferenceKey = 'app_locale_override';

class AppLocaleNotifier extends StateNotifier<Locale?> {
  final ObjectBoxPreferencesRepository _prefs;

  AppLocaleNotifier(this._prefs) : super(null) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final saved = await _prefs.getString(_appLocalePreferenceKey);
    state = _localeFromTag(saved);
  }

  Future<void> setSystemLocale() async {
    state = null;
    await _prefs.remove(_appLocalePreferenceKey);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(_appLocalePreferenceKey, _localeToTag(locale));
  }

  Locale? _localeFromTag(String? tag) {
    if (tag == null || tag.isEmpty) return null;

    final parts = tag.split('_');
    if (parts.length == 1) {
      return Locale(parts[0]);
    }

    return Locale(parts[0], parts[1]);
  }

  String _localeToTag(Locale locale) {
    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return locale.languageCode;
    }
    return '${locale.languageCode}_$countryCode';
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale?>((ref) {
  return AppLocaleNotifier(ref.watch(objectboxPreferencesRepositoryProvider));
});

/// Provider para smokingServiceProvider
final smokingServiceProvider = Provider<SmokingService>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return SmokingService(prefs);
});

/// Provider para IapService
final iapServiceProvider = StateNotifierProvider<iap.IapService, iap.IapState>((ref) {
  final objectBoxService = ref.watch(objectBoxServiceProvider);
  final repository = IapEntitlementRepository(objectBoxService.store);
  return iap.IapService(repository);
});

/// Provider para SupabaseAuthDatasource
final supabaseAuthDatasourceProvider = Provider<SupabaseAuthDatasource>((ref) {
  return SupabaseAuthDatasource(
    supabase: Supabase.instance.client,
    logger: ref.watch(loggerServiceProvider),
  );
});

/// Provider para AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    datasource: ref.watch(supabaseAuthDatasourceProvider),
    logger: ref.watch(loggerServiceProvider),
  );
});

/// Provider para AuthController
final authServiceProvider = StateNotifierProvider<AuthController, auth_state.AuthState>((ref) {
  return AuthController(
    repository: ref.watch(authRepositoryProvider),
    logger: ref.watch(loggerServiceProvider),
  );
});

/// Provider para obter o userId atual do usuário autenticado
final currentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authServiceProvider);
  return authState.currentUser?.id ?? 'guest_user';
});

/// Provider para ObjectBoxPreferencesRepository
final objectBoxPreferencesRepositoryProvider = Provider<ObjectBoxPreferencesRepository>((ref) {
  final objectBoxService = ref.watch(objectBoxServiceProvider);
  return ObjectBoxPreferencesRepository(objectBoxService.store);
});

/// Provider para ThemeController (StateNotifier com múltiplos temas)
final themeControllerProvider = StateNotifierProvider<ThemeController, AppTheme>((ref) {
  final preferences = ref.watch(objectBoxPreferencesRepositoryProvider);
  return ThemeController(preferences);
});

/// Provider para AppMonitoringService
final appMonitoringServiceProvider = Provider<AppMonitoringService>((ref) {
  final prefs = ref.watch(objectboxPreferencesRepositoryProvider);
  final sessionPersistence = ref.watch(sessionPersistenceServiceProvider);
  final focusService = ref.watch(focusServiceProvider);
  
  return AppMonitoringService(
    prefs,
    sessionPersistence,
    focusService: focusService,
  );
});



// ============= AUTH SERVICES =============

/// Provider para AdultContentServiceLocal
final adultContentServiceLocalProvider = Provider<AdultContentServiceLocal>((ref) {
  return AdultContentServiceLocal.instance;
});

/// Provider para AdultContentControllerLocal
final adultContentControllerLocalProvider = StateNotifierProvider<AdultContentControllerLocal, AdultContentState>((ref) {
  final service = ref.watch(adultContentServiceLocalProvider);
  return AdultContentControllerLocal(service);
});

/// Provider para AdultContentService (legado)
final adultContentServiceProvider = Provider<AdultContentService>((ref) {
  final repository = ref.watch(objectboxPreferencesRepositoryProvider);
  return AdultContentService(repository);
});


/// Provider para ProcrastinationServiceLocal
final procrastinationServiceLocalProvider = Provider<ProcrastinationServiceLocal>((ref) {
  return ProcrastinationServiceLocal.instance;
});

/// Provider para ProcrastinationControllerLocal
final procrastinationControllerLocalProvider = StateNotifierProvider<ProcrastinationControllerLocal, ProcrastinationState>((ref) {
  final service = ref.watch(procrastinationServiceLocalProvider);
  return ProcrastinationControllerLocal(service);
});

/// Provider para ProcrastinationService (serviço de listas de tarefas)
final procrastinationServiceProvider = Provider<ProcrastinationService>((ref) {
  final repository = ref.watch(objectboxPreferencesRepositoryProvider);
  return ProcrastinationService(repository);
});


final moneySavingChallengeServiceProvider = Provider<MoneySavingChallengeService>((ref) {
  final repository = ref.watch(objectboxPreferencesRepositoryProvider);
  return MoneySavingChallengeService(repository);
});

/// Provider para StopSmokingController
final stopSmokingControllerProvider = StateNotifierProvider<StopSmokingController, StopSmokingState>((ref) {
  final smokingService = ref.watch(smokingServiceProvider);
  return StopSmokingController(smokingService);
});

final focusServiceProvider = Provider<FocusService>((ref) {
  return FocusService(
    ref.watch(objectBoxServiceProvider),
    ref.watch(cloudSyncServiceProvider),
  );
});

/// Provider para FocusServiceLocal
final focusServiceLocalProvider = Provider<FocusServiceLocal>((ref) {
  return FocusServiceLocal.instance;
});

/// Provider para FocusController
final focusControllerLocalProvider = StateNotifierProvider<FocusController, FocusState>((ref) {
  final service = ref.watch(focusServiceLocalProvider);
  return FocusController(service);
});

/// Provider para ReadingServiceLocal
final readingServiceLocalProvider = Provider<ReadingServiceLocal>((ref) {
  return ReadingServiceLocal.instance;
});

/// Provider para ReadingControllerLocal
final readingControllerLocalProvider = StateNotifierProvider<ReadingControllerLocal, ReadingState>((ref) {
  final service = ref.watch(readingServiceLocalProvider);
  return ReadingControllerLocal(service);
});


/// Provider para ReadingService (alternativo)
final readingServiceProvider = Provider<ReadingService>((ref) {
  final repository = ref.watch(readingRepositoryProvider);
  final gamificationRepository = ref.watch(readingGamificationRepositoryProvider);
  final cloudSync = ref.watch(cloudSyncServiceProvider);
  return ReadingService(repository, gamificationRepository, null, cloudSync);
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

/// Provider para FocusGamificationRepository
final focusGamificationRepositoryProvider = Provider<FocusGamificationRepository>((ref) {
  return FocusGamificationRepository.instance;
});

/// Provider para SmokingGamificationRepository
final smokingGamificationRepositoryProvider = Provider<SmokingGamificationRepository>((ref) {
  return SmokingGamificationRepository.instance;
});

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final prefs = ref.watch(objectboxPreferencesRepositoryProvider);
  return CloudSyncService(
    supabase: Supabase.instance.client,
    prefsRepo: prefs,
  );
});

/// Provider para LocalBackupService
final localBackupServiceProvider = Provider<LocalBackupService>((ref) {
  return LocalBackupService(ObjectBoxService.instance.store);
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

/// Provider para verificar se o módulo Focus está ativo
final focusActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(focusControllerLocalProvider);
  return state.config?.isModuleActive ?? false;
});

/// Provider para verificar se o módulo Reading está ativo
final readingActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(readingControllerLocalProvider);
  return state.config?.isModuleActive ?? false;
});

/// Provider combinado para obter módulos ativos
/// Sistema completo de módulos - verifica status de cada módulo individualmente
final activeModulesProvider = FutureProvider<List<NicheId>>((ref) async {
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
  // Digital Detox - usar provider dedicado
  try {
    final digitalDetoxActive = await ref.watch(digitalDetoxActiveProvider.future);
    if (digitalDetoxActive) activeModules.add(NicheId.digitalDetox);
  } catch (_) {}

  return activeModules;
});

/// Provider combinado para obter medalhas pendentes de todos os módulos
/// Sistema completo de medalhas - agrega medalhas de todos os módulos ativos
final pendingMedalsProvider = Provider<Future<List<String>>>((ref) async {
  final pendingMedals = <String>[];
  
  // Adult Content - via notifier
  try {
    final adultContentState = ref.watch(adultContentGamificationNotifierProvider);
    pendingMedals.addAll(adultContentState.earnedMedalhas);
  } catch (_) {}
  
  // Procrastination - via notifier
  try {
    final procrastinationState = ref.watch(procrastinationGamificationNotifierProvider);
    pendingMedals.addAll(procrastinationState.earnedMedalhas);
  } catch (_) {}
  
  // Spending - via notifier
  try {
    final spendingState = ref.watch(spendingGamificationNotifierProvider);
    pendingMedals.addAll(spendingState.earnedMedalhas);
  } catch (_) {}
  
  // Smoking - via notifier
  try {
    final smokingState = ref.watch(smokingGamificationNotifierProvider);
    pendingMedals.addAll(smokingState.earnedMedalhas);
  } catch (_) {}
  
  // Money Saving - via notifier
  try {
    final moneyState = ref.watch(moneySavingGamificationStateProvider);
    final state = moneyState.valueOrNull;
    if (state != null) {
      pendingMedals.addAll(state.earnedMedalhas);
    }
  } catch (_) {}
  
  // Digital Detox - via service de gamificação local
  try {
    final userId = ref.watch(currentUserIdProvider);
    // Usar o service de gamificação diretamente
    final store = ObjectBoxService.instance.store;
    final gamificationRepo = DigitalDetoxGamificationRepository(store.box<DigitalDetoxGamificationEntity>());
    final gamification = gamificationRepo.getByUserId(userId);
    if (gamification != null) {
      pendingMedals.addAll(gamification.earnedMedalhasList);
    }
  } catch (_) {}
  
  return pendingMedals;
});


/// Controla se a sincronização inicial já foi realizada
/// 
/// Agora com persistência entre sessões usando SyncValidationService.
/// A sincronização só ocorre em:
/// 1. Nova build (debug/profile/release)
/// 2. Nova instalação do app
/// 3. Novo login (usuário diferente)
/// 4. Re-login (logout + login mesmo usuário)
class InitialSyncState extends StateNotifier<bool> {
  final SyncValidationService _validationService = SyncValidationService();
  
  InitialSyncState() : super(false);
  
  /// Verifica se deve sincronizar baseado nas regras de negócio
  Future<SyncCheckResult> checkShouldSync(String? currentUserId, {bool isLoginEvent = false}) async {
    return await _validationService.shouldSync(currentUserId, isLoginEvent: isLoginEvent);
  }
  
  /// Marca a sincronização como concluída (persiste build, usuário, etc)
  Future<void> markSynced(String? userId) async {
    await _validationService.markSyncCompleted(userId);
    state = true;
  }
  
  /// Reseta o estado (para testes ou logout)
  Future<void> reset() async {
    await _validationService.resetSyncState();
    state = false;
  }
  
  /// Reseta apenas o estado em memória (sem limpar persistência)
  void resetSessionOnly() => state = false;
  
  /// Marca a sessão atual como sincronizada (sem persistir - já está persistido)
  void markSessionSynced() => state = true;
  
  bool get hasSynced => state;
}

/// Provider para verificar se a sincronização inicial já foi feita
/// 
/// Agora persiste entre sessões do app e só sincroniza quando necessário:
/// - Nova build (debug/profile/release)
/// - Nova instalação
/// - Novo usuário logado
final initialSyncCompletedProvider = StateNotifierProvider<InitialSyncState, bool>((ref) {
  return InitialSyncState();
});

/// Provider para acessar o SyncValidationService
final syncValidationServiceProvider = Provider<SyncValidationService>((ref) {
  return SyncValidationService();
});






