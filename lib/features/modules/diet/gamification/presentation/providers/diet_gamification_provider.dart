import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/presentation/notifiers/diet_gamification_notifier.dart';

/// Re-export do provider do notifier (plugin architecture)
export 'package:disciplinum/features/modules/diet/presentation/notifiers/diet_gamification_notifier.dart'
    show
        dietGamificationNotifierProvider,
        dietGamificationStateProvider,
        DietGamificationNotifier,
        DietGamificationState;

/// Provider legado para compatibilidade durante transição
@Deprecated('Use dietGamificationNotifierProvider em vez deste')
final dietGamificationProvider = Provider((ref) {
  return ref.read(dietGamificationNotifierProvider.notifier);
});

/// Provider para o repositório de gamificação do Diet
final dietGamificationRepositoryProvider = Provider<DietGamificationRepository>((ref) {
  return DietGamificationRepository.instance;
});

/// Provider para o streak do Diet
final dietStreakProvider = Provider<int>((ref) {
  final state = ref.watch(dietGamificationNotifierProvider);
  return state.currentStreak;
});

/// Provider para verificar se o módulo está ativo
final dietActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(dietGamificationNotifierProvider);
  return state.isModuleActive;
});

/// Provider para insígnias conquistadas
final dietInsigniasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(dietGamificationNotifierProvider);
  return state.earnedInsignias;
});

/// Provider para medalhas conquistadas
final dietMedalhasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(dietGamificationNotifierProvider);
  return state.earnedMedalhas;
});

/// Provider para contagem de Disciplinum
final dietDisciplinumCountProvider = Provider<int>((ref) {
  final state = ref.watch(dietGamificationNotifierProvider);
  return state.disciplinumCount;
});
