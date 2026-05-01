import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/repositories/spending_gamification_repository.dart';
import 'package:disciplinum/features/modules/spending/presentation/notifiers/spending_gamification_notifier.dart';

/// Re-export do provider do notifier (plugin architecture)
export 'package:disciplinum/features/modules/spending/presentation/notifiers/spending_gamification_notifier.dart'
    show
        spendingGamificationNotifierProvider,
        spendingGamificationStateProvider,
        SpendingGamificationNotifier,
        SpendingGamificationState;

/// Provider legado para controller - redireciona para notifier
@Deprecated('Use spendingGamificationNotifierProvider em vez deste')
final spendingGamificationControllerProvider = StateNotifierProvider<SpendingGamificationNotifier, SpendingGamificationState>((ref) {
  final repository = SpendingGamificationRepository.instance;
  return SpendingGamificationNotifier(repository);
});

/// Provider para o repositório de gamificação do Spending
final spendingGamificationRepositoryProvider = Provider<SpendingGamificationRepository>((ref) {
  return SpendingGamificationRepository.instance;
});

/// Provider para o streak do Spending
final spendingStreakProvider = Provider<int>((ref) {
  final state = ref.watch(spendingGamificationNotifierProvider);
  return state.currentStreak;
});

/// Provider para verificar se o módulo está ativo
final spendingActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(spendingGamificationNotifierProvider);
  return state.isModuleActive;
});

/// Provider para insígnias conquistadas
final spendingInsigniasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(spendingGamificationNotifierProvider);
  return state.earnedInsignias;
});

/// Provider para medalhas conquistadas
final spendingMedalhasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(spendingGamificationNotifierProvider);
  return state.earnedMedalhas;
});

/// Provider para contagem de Disciplinum
final spendingDisciplinumCountProvider = Provider<int>((ref) {
  final state = ref.watch(spendingGamificationNotifierProvider);
  return state.earnedInsignias.where((i) => i == 'disciplinum').length;
});
