import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/repositories/spending_gamification_repository.dart';
import 'package:disciplinum/features/modules/spending/gamification/presentation/controllers/spending_gamification_controller.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Provider para o repositório de gamificação do Spending
final spendingGamificationRepositoryProvider = Provider<SpendingGamificationRepository>((ref) {
  return SpendingGamificationRepository.instance;
});

/// Provider para o controller de gamificação do Spending
final spendingGamificationControllerProvider = ChangeNotifierProvider<SpendingGamificationController>((ref) {
  final repository = ref.watch(spendingGamificationRepositoryProvider);
  final authService = ref.read(authServiceProvider.notifier);
  return SpendingGamificationController(
    repository: repository,
    authService: authService,
  );
});

/// Provider para o streak do Spending (meses consecutivos)
final spendingStreakProvider = Provider<int>((ref) {
  final controller = ref.watch(spendingGamificationControllerProvider);
  return controller.currentStreak;
});

/// Provider para verificar se o módulo Spending está ativo
final spendingActiveProvider = Provider<bool>((ref) {
  final controller = ref.watch(spendingGamificationControllerProvider);
  return controller.isActive;
});
