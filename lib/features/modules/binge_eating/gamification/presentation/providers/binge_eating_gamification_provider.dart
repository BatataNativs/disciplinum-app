import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/services/binge_eating_gamification_service.dart';

/// Provider para o serviço de gamificação do Binge Eating
/// Gerencia o estado e disponibiliza o serviço para a UI
final bingeEatingGamificationProvider = Provider<BingeEatingGamificationService>((ref) {
  return BingeEatingGamificationService(
    ref.read(bingeEatingGamificationRepositoryProvider),
  );
});

/// Provider para o estado inicializado do Binge Eating
final bingeEatingGamificationInitializedProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(bingeEatingGamificationProvider);
  try {
    await service.initialize();
    return true;
  } catch (e) {
    return false;
  }
});

/// Provider para o estado atual da gamificação do Binge Eating
final bingeEatingGamificationStateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(bingeEatingGamificationProvider);
  return await service.getCurrentState();
});

/// Provider para as insignias conquistadas do Binge Eating
final bingeEatingInsigniasProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(bingeEatingGamificationProvider);
  return await service.insigniaService.getEarnedInsignias();
});

/// Provider para as medalhas conquistadas do Binge Eating
final bingeEatingMedalhasProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(bingeEatingGamificationProvider);
  return await service.medalhaService.getEarnedMedalhas();
});

/// Provider para o streak do Binge Eating
final bingeEatingStreakProvider = Provider<int>((ref) {
  final service = ref.read(bingeEatingGamificationProvider);
  return service.consecutivePositiveDays;
});

/// Provider para verificar se o módulo está ativo
final bingeEatingActiveProvider = Provider<bool>((ref) {
  final service = ref.read(bingeEatingGamificationProvider);
  return service.isActive;
});

/// Provider para o progresso até a próxima insignia
final bingeEatingProgressProvider = Provider<double>((ref) {
  final service = ref.read(bingeEatingGamificationProvider);
  return service.getProgressToNextInsignia();
});

/// Provider para estatísticas detalhadas
final bingeEatingStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(bingeEatingGamificationProvider);
  return service.getStatistics();
});

/// Provider para verificar se está em streak
final bingeEatingInStreakProvider = Provider<bool>((ref) {
  final service = ref.read(bingeEatingGamificationProvider);
  return service.isInStreak;
});
