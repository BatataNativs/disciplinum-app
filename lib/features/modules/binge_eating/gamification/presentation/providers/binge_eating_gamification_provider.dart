import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/notifiers/binge_eating_gamification_notifier.dart';

/// Re-export do provider do notifier (plugin architecture)
export 'package:disciplinum/features/modules/binge_eating/presentation/notifiers/binge_eating_gamification_notifier.dart'
    show
        bingeEatingGamificationNotifierProvider,
        bingeEatingGamificationStateProvider,
        BingeEatingGamificationNotifier,
        BingeEatingGamificationState;

/// Provider para o repositório de gamificação do Binge Eating
final bingeEatingGamificationRepositoryProvider = Provider<BingeEatingGamificationRepository>((ref) {
  return BingeEatingGamificationRepository.instance;
});

/// Provider para o streak do Binge Eating
final bingeEatingStreakProvider = Provider<int>((ref) {
  final state = ref.watch(bingeEatingGamificationNotifierProvider);
  return state.currentStreak;
});

/// Provider para verificar se o módulo está ativo
final bingeEatingActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(bingeEatingGamificationNotifierProvider);
  return state.isModuleActive;
});

/// Provider para insígnias conquistadas
final bingeEatingInsigniasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(bingeEatingGamificationNotifierProvider);
  return state.earnedInsignias;
});

/// Provider para medalhas conquistadas
final bingeEatingMedalhasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(bingeEatingGamificationNotifierProvider);
  return state.earnedMedalhas;
});
