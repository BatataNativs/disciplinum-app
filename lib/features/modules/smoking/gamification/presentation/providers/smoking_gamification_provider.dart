import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/presentation/notifiers/smoking_gamification_notifier.dart';

/// Re-export do provider do notifier (plugin architecture)
export 'package:disciplinum/features/modules/smoking/presentation/notifiers/smoking_gamification_notifier.dart'
    show
        smokingGamificationNotifierProvider,
        smokingGamificationStateProvider,
        SmokingGamificationNotifier,
        SmokingGamificationState;

/// Provider para o repositório de gamificação do Smoking
final smokingGamificationRepositoryProvider = Provider<SmokingGamificationRepository>((ref) {
  return SmokingGamificationRepository.instance;
});

/// Provider para o streak do Smoking (dias consecutivos)
final smokingStreakProvider = Provider<int>((ref) {
  final state = ref.watch(smokingGamificationNotifierProvider);
  return state.currentStreak;
});

/// Provider para verificar se o módulo Smoking está ativo
/// Retorna true se: está explicitamente ativo OU ainda está carregando
/// Isso evita que a home screen mostre "Sem módulos ativos" durante o carregamento
final smokingActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(smokingGamificationNotifierProvider);
  // Se ainda está carregando, assume que pode estar ativo (não esconde o módulo)
  if (state.isLoading) return true;
  return state.isModuleActive;
});

/// Provider para contagem de disciplinum
final smokingDisciplinumCountProvider = Provider<int>((ref) {
  final state = ref.watch(smokingGamificationNotifierProvider);
  return state.disciplinumCount;
});

/// Provider para insígnias ganhas
final smokingEarnedInsigniasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(smokingGamificationNotifierProvider);
  return state.earnedInsignias;
});

/// Provider para medalhas ganhas
final smokingEarnedMedalhasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(smokingGamificationNotifierProvider);
  return state.earnedMedalhas;
});
