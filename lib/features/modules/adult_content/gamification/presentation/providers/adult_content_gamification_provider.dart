import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/repositories/adult_content_gamification_repository.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/presentation/controllers/adult_content_gamification_controller.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Provider para o repositório de gamificação do Adult Content
final adultContentGamificationRepositoryProvider = Provider<AdultContentGamificationRepository>((ref) {
  return AdultContentGamificationRepository.instance;
});

/// Provider para o controller de gamificação do Adult Content
final adultContentGamificationControllerProvider = ChangeNotifierProvider<AdultContentGamificationController>((ref) {
  final repository = ref.watch(adultContentGamificationRepositoryProvider);
  final authService = ref.read(authServiceProvider.notifier);
  return AdultContentGamificationController(
    repository: repository,
    authService: authService,
  );
});

/// Provider para o streak do Adult Content (dias consecutivos)
final adultContentStreakProvider = Provider<int>((ref) {
  final controller = ref.watch(adultContentGamificationControllerProvider);
  return controller.currentStreak;
});

/// Provider para verificar se o módulo Adult Content está ativo
final adultContentActiveProvider = Provider<bool>((ref) {
  final controller = ref.watch(adultContentGamificationControllerProvider);
  return controller.isActive;
});
