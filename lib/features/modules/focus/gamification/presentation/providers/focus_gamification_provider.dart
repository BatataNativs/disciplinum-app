import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';
import 'package:disciplinum/features/modules/focus/presentation/notifiers/focus_gamification_notifier.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Re-export do provider do notifier (plugin architecture)
/// Este é o provider principal para acessar o estado da gamificação do Focus
export 'package:disciplinum/features/modules/focus/presentation/notifiers/focus_gamification_notifier.dart'
    show
        focusGamificationNotifierProvider,
        focusGamificationStateProvider,
        FocusGamificationNotifier,
        FocusGamificationState;

/// Provider para o repositório de gamificação do Focus
final focusGamificationRepositoryProvider = Provider<FocusGamificationRepository>((ref) {
  return FocusGamificationRepository.instance;
});

/// Provider para o streak do Focus (dias consecutivos)
final focusStreakProvider = Provider<int>((ref) {
  final state = ref.watch(focusGamificationNotifierProvider);
  return state.currentStreak;
});

/// Provider para verificar se o módulo Focus está ativo
final focusActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(focusControllerIsarProvider);
  return state.config?.isModuleActive ?? false;
});

/// Provider para minutos totais de foco
final focusTotalMinutesProvider = Provider<int>((ref) {
  final state = ref.watch(focusGamificationNotifierProvider);
  return state.totalFocusMinutes;
});

/// Provider para verificar se tem insígnia
final focusHasInsigniaProvider = Provider.family<bool, String>((ref, insigniaId) {
  final state = ref.watch(focusGamificationNotifierProvider);
  return state.earnedInsignias.contains(insigniaId);
});

/// Provider para verificar se tem medalha
final focusHasMedalhaProvider = Provider.family<bool, String>((ref, medalhaId) {
  final state = ref.watch(focusGamificationNotifierProvider);
  return state.earnedMedalhas.contains(medalhaId);
});
