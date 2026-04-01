import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_gamification_service.dart';

/// Provider para o repositório de gamificação do Smoking
final smokingGamificationRepositoryProvider = Provider<SmokingGamificationRepository>((ref) {
  return SmokingGamificationRepository.instance;
});

/// Provider para o serviço de gamificação do Smoking
final smokingGamificationServiceProvider = Provider<SmokingGamificationService>((ref) {
  final repository = ref.watch(smokingGamificationRepositoryProvider);
  return SmokingGamificationService(repository);
});

/// Provider para o streak do Smoking (dias consecutivos)
/// Usa consecutivePositiveDays do serviço
final smokingStreakProvider = Provider<int>((ref) {
  final service = ref.watch(smokingGamificationServiceProvider);
  // Inicializa o serviço se necessário
  service.initialize();
  return service.consecutivePositiveDays;
});

/// Provider para verificar se o módulo Smoking está ativo
final smokingActiveProvider = Provider<bool>((ref) {
  final service = ref.watch(smokingGamificationServiceProvider);
  return service.isActive;
});
