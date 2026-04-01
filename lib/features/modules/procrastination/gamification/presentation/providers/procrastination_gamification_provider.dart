import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/repositories/procrastination_gamification_repository.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/presentation/controllers/procrastination_gamification_controller.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Provider para o repositório de gamificação do Procrastination
final procrastinationGamificationRepositoryProvider = Provider<ProcrastinationGamificationRepository>((ref) {
  return ProcrastinationGamificationRepository.instance;
});

/// Provider para o controller de gamificação do Procrastination
final procrastinationGamificationControllerProvider = ChangeNotifierProvider<ProcrastinationGamificationController>((ref) {
  final repository = ref.watch(procrastinationGamificationRepositoryProvider);
  final authService = ref.read(authServiceProvider.notifier);
  return ProcrastinationGamificationController(
    repository: repository,
    authService: authService,
  );
});

/// Provider para o streak do Procrastination (dias consecutivos)
final procrastinationStreakProvider = Provider<int>((ref) {
  final controller = ref.watch(procrastinationGamificationControllerProvider);
  return controller.currentStreak;
});

/// Provider para verificar se o módulo Procrastination está ativo
final procrastinationActiveProvider = Provider<bool>((ref) {
  final controller = ref.watch(procrastinationGamificationControllerProvider);
  return controller.isActive;
});
