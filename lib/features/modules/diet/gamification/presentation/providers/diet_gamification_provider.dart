import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/services/diet_gamification_service.dart';

/// Provider para o serviço de gamificação do Diet
/// Gerencia o estado e disponibiliza o serviço para a UI
final dietGamificationProvider = Provider<DietGamificationService>((ref) {
  return DietGamificationService(
    ref.read(dietGamificationRepositoryProvider),
  );
});

/// Provider para o estado inicializado do Diet
final dietGamificationInitializedProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(dietGamificationProvider);
  try {
    await service.initialize();
    return true;
  } catch (e) {
    return false;
  }
});

/// Provider para o estado atual da gamificação do Diet
final dietGamificationStateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(dietGamificationProvider);
  return await service.getCurrentState();
});

/// Provider para as insignias conquistadas do Diet
final dietInsigniasProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(dietGamificationProvider);
  return await service.insigniaService.getEarnedInsignias();
});

/// Provider para as medalhas conquistadas do Diet
final dietMedalhasProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(dietGamificationProvider);
  return await service.medalhaService.getEarnedMedalhas();
});

/// Provider para o streak do Diet
final dietStreakProvider = Provider<int>((ref) {
  final service = ref.read(dietGamificationProvider);
  return service.consecutiveDays;
});

/// Provider para verificar se o módulo está ativo
final dietActiveProvider = Provider<bool>((ref) {
  final service = ref.read(dietGamificationProvider);
  return service.isActive;
});

/// Provider para o progresso até a próxima insignia
final dietProgressProvider = Provider<double>((ref) {
  final service = ref.read(dietGamificationProvider);
  return service.getProgressToNextInsignia();
});

/// Provider para estatísticas detalhadas
final dietStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(dietGamificationProvider);
  return service.getStatistics();
});

/// Provider para verificar se está em streak
final dietInStreakProvider = Provider<bool>((ref) {
  final service = ref.read(dietGamificationProvider);
  return service.isInStreak;
});
