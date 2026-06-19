import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/entities/digital_detox_gamification_entity.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/repositories/digital_detox_gamification_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/repositories/digital_detox_fasting_break_domain_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/presentation/providers/digital_detox_gamification_notifier.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/entities/digital_detox_fasting_break_info.dart';

// Repository providers
final digitalDetoxGamificationRepositoryProvider = Provider<DigitalDetoxGamificationRepository>((ref) {
  final store = ObjectBoxService.instance.store;
  return DigitalDetoxGamificationRepository(store.box<DigitalDetoxGamificationEntity>());
});

final digitalDetoxFastingBreakRepositoryProvider = Provider<DigitalDetoxFastingBreakRepository>((ref) {
  final store = ObjectBoxService.instance.store;
  return DigitalDetoxFastingBreakRepository(store.box<DigitalDetoxFastingBreakInfo>());
});

// Providers principais do Digital Detox (padrão Reading)
final digitalDetoxGamificationNotifierProvider = StateNotifierProvider.family<DigitalDetoxGamificationNotifier, DigitalDetoxGamificationState, String>((ref, userId) {
  return DigitalDetoxGamificationNotifier(
    ref.read(digitalDetoxGamificationRepositoryProvider), 
    ref.read(digitalDetoxFastingBreakRepositoryProvider)
  );
});

final digitalDetoxGamificationStateProvider = Provider.family<DigitalDetoxGamificationState, String>((ref, userId) {
  return ref.watch(digitalDetoxGamificationNotifierProvider(userId));
});

// Providers específicos para UI
final digitalDetoxStreakProvider = Provider.family<int, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.gamification?.currentStreak ?? 0;
});

final digitalDetoxLongestStreakProvider = Provider.family<int, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.gamification?.longestStreak ?? 0;
});

final digitalDetoxTotalDisciplinedDaysProvider = Provider.family<int, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.gamification?.totalDisciplinedDays ?? 0;
});

final digitalDetoxSevenDayCycleProvider = Provider.family<int, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.gamification?.sevenDayCycle ?? 0;
});

final digitalDetoxCurrent30DayCycleProvider = Provider.family<int, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.gamification?.daysInCurrent30DayCycle ?? 0;
});

final digitalDetoxActiveProvider = Provider.family<bool, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.gamification?.isModuleActive ?? false;
});

final digitalDetoxEarnedInsigniasProvider = Provider.family<List<String>, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.gamification?.earnedInsigniasList ?? [];
});

final digitalDetoxEarnedMedalhasProvider = Provider.family<List<String>, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.gamification?.earnedMedalhasList ?? [];
});

final digitalDetoxAvailableFastingBreaksProvider = Provider.family<List<DigitalDetoxFastingBreakInfo>, String>((ref, userId) {
  final state = ref.watch(digitalDetoxGamificationStateProvider(userId));
  return state.availableBreaks.cast<DigitalDetoxFastingBreakInfo>();
});
