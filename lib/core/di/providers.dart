import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/core/di/adapters/reading_service_adapter.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/infrastructure/ads/ad_service.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/core/theme/theme_controller.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/database/repositories/simple_user_module_repository.dart';

// ============= CORE SERVICES =============

/// Provider para SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider para LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

/// Provider para LoggerService
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService.instance;
});

/// Provider para ReadingServiceAdapter
final readingServiceAdapterProvider = Provider<ReadingServiceAdapter>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final gamification = ref.watch(gamificationServiceProvider);
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) {
      final readingService = ReadingService(prefs, gamification);
      return ReadingServiceAdapter(localStorage, readingService);
    },
    loading: () => throw StateError('SharedPreferences not ready'),
    error: (error, stack) => throw error,
  );
});

/// Provider para GamificationService
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService.instance;
});

/// Provider para AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider para ThemeController
final themeControllerProvider = Provider<ThemeController>((ref) {
  return ThemeController();
});

/// Provider para AdService
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

/// Provider para IapService
final iapServiceProvider = Provider<IapService>((ref) {
  return IapService();
});

/// Provider para IsarService
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

/// Provider para SimpleUserModuleRepository
final simpleUserModuleRepositoryProvider = Provider<SimpleUserModuleRepository>((ref) {
  return SimpleUserModuleRepository.instance;
});

// ============= AUTH SERVICES =============

/// Provider para ProcrastinationService
final procrastinationServiceProvider = Provider<ProcrastinationService>((ref) {
  final gamification = ref.watch(gamificationServiceProvider);
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => ProcrastinationService(gamification, prefs),
    loading: () => throw StateError('SharedPreferences not ready'),
    error: (error, stack) => throw error,
  );
});

/// Provider para SpendingService
final spendingServiceProvider = Provider<SpendingService>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => SpendingService(prefs),
    loading: () => throw StateError('SharedPreferences not ready'),
    error: (error, stack) => throw error,
  );
});

/// Provider para MoneySavingChallengeService
final moneySavingChallengeServiceProvider = Provider<MoneySavingChallengeService>((ref) {
  return MoneySavingChallengeService();
});
