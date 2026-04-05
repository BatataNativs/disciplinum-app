import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/notifiers/money_saving_gamification_notifier.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Re-export do provider do notifier (plugin architecture)
export 'package:disciplinum/features/modules/money_saving/presentation/notifiers/money_saving_gamification_notifier.dart'
    show
        moneySavingGamificationNotifierProvider,
        MoneySavingGamificationNotifier,
        MoneySavingGamificationState;

/// Provider para acesso ao notifier com userId atual
final moneySavingGamificationStateProvider = Provider<AsyncValue<MoneySavingGamificationState>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final state = ref.watch(moneySavingGamificationNotifierProvider(userId));
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});

/// Provider legado para compatibilidade durante transição
@Deprecated('Use moneySavingGamificationNotifierProvider em vez deste')
final moneySavingGamificationProvider = Provider((ref) {
  final userId = ref.read(currentUserIdProvider);
  return ref.read(moneySavingGamificationNotifierProvider(userId).notifier);
});

/// Provider para o repositório de gamificação do Money Saving
final moneySavingGamificationRepositoryProvider = Provider<MoneySavingGamificationRepository>((ref) {
  return MoneySavingGamificationRepository.instance;
});

/// Provider para o streak do Money Saving
final moneySavingStreakProvider = Provider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final state = ref.watch(moneySavingGamificationNotifierProvider(userId));
  return state.consecutiveDays;
});

/// Provider para verificar se o módulo está ativo
final moneySavingActiveProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final state = ref.watch(moneySavingGamificationNotifierProvider(userId));
  return state.isActive;
});

/// Provider para valor total acumulado
final moneySavingTotalProvider = Provider<double>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final state = ref.watch(moneySavingGamificationNotifierProvider(userId));
  return state.totalSavedAmount;
});

/// Provider para insígnias conquistadas
final moneySavingInsigniasProvider = Provider<List<String>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final state = ref.watch(moneySavingGamificationNotifierProvider(userId));
  return state.earnedInsignias;
});

/// Provider para medalhas conquistadas
final moneySavingMedalhasProvider = Provider<List<String>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final state = ref.watch(moneySavingGamificationNotifierProvider(userId));
  return state.earnedMedalhas;
});

/// Provider para contagem de disciplinum
final moneySavingDisciplinumProvider = Provider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final state = ref.watch(moneySavingGamificationNotifierProvider(userId));
  return state.disciplinumCount;
});
