import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/repositories/procrastination_gamification_repository.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/notifiers/procrastination_gamification_notifier.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Re-export do provider do notifier (plugin architecture)
export 'package:disciplinum/features/modules/procrastination/presentation/notifiers/procrastination_gamification_notifier.dart'
    show
        procrastinationGamificationNotifierProvider,
        procrastinationGamificationStateProvider,
        ProcrastinationGamificationNotifier,
        ProcrastinationGamificationState;

/// Provider legado para controller - redireciona para notifier
@Deprecated('Use procrastinationGamificationNotifierProvider em vez deste')
final procrastinationGamificationControllerProvider = StateNotifierProvider<ProcrastinationGamificationNotifier, ProcrastinationGamificationState>((ref) {
  final repository = ProcrastinationGamificationRepository.instance;
  return ProcrastinationGamificationNotifier(repository);
});

/// Provider para o repositório de gamificação do Procrastination
final procrastinationGamificationRepositoryProvider = Provider<ProcrastinationGamificationRepository>((ref) {
  return ProcrastinationGamificationRepository.instance;
});

/// Provider para o streak do Procrastination
final procrastinationStreakProvider = Provider<int>((ref) {
  final state = ref.watch(procrastinationGamificationNotifierProvider);
  return state.currentStreak;
});

/// Provider para verificar se o módulo está ativo
final procrastinationActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(procrastinationControllerIsarProvider);
  return state.config?.isModuleActive ?? false;
});
