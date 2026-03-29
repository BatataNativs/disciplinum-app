import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/services/money_saving_gamification_service.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Provider para o serviço de gamificação do Money Saving Challenge
/// Gerencia o estado e disponibiliza o serviço para a UI
final moneySavingGamificationProvider = Provider<MoneySavingGamificationService>((ref) {
  return MoneySavingGamificationService(
    ref.read(moneySavingGamificationRepositoryProvider),
  );
});

/// Provider para o estado inicializado do Money Saving
final moneySavingGamificationInitializedProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(moneySavingGamificationProvider);
  try {
    await service.initialize();
    return true;
  } catch (e) {
    return false;
  }
});

/// Provider para o estado atual da gamificação do Money Saving
final moneySavingGamificationStateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(moneySavingGamificationProvider);
  return await service.getCurrentState();
});

/// Provider para as insignias conquistadas do Money Saving
final moneySavingInsigniasProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(moneySavingGamificationProvider);
  return await service.insigniaService.getEarnedInsignias();
});

/// Provider para as medalhas conquistadas do Money Saving
final moneySavingMedalhasProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(moneySavingGamificationProvider);
  return await service.medalhaService.getEarnedMedalhas();
});

/// Provider para o streak do Money Saving
final moneySavingStreakProvider = Provider<int>((ref) {
  final currentState = ref.watch(moneySavingGamificationStateProvider);
  return currentState.maybeWhen(
    data: (state) => (state['currentStreak'] as int? ?? 0),
    orElse: () => 0,
  );
});

/// Provider para o valor total acumulado
final moneySavingTotalProvider = Provider<double>((ref) {
  final currentState = ref.watch(moneySavingGamificationStateProvider);
  return currentState.maybeWhen(
    data: (state) => (state['totalSaved'] as double? ?? 0.0),
    orElse: () => 0.0,
  );
});

/// Provider para verificar se o módulo está ativo
final moneySavingActiveProvider = Provider<bool>((ref) {
  final currentState = ref.watch(moneySavingGamificationStateProvider);
  return currentState.maybeWhen(
    data: (state) => (state['isActive'] as bool? ?? false),
    orElse: () => false,
  );
});

/// Provider para o progresso até a próxima insignia
final moneySavingProgressProvider = Provider<double>((ref) {
  final service = ref.read(moneySavingGamificationProvider);
  final progress = service.getProgressToNextInsignia();
  return (progress['progress'] as double? ?? 0.0);
});

/// Provider para estatísticas detalhadas
final moneySavingStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(moneySavingGamificationProvider);
  return service.getStatistics();
});

/// Provider para verificar se está em streak
final moneySavingInStreakProvider = Provider<bool>((ref) {
  final service = ref.read(moneySavingGamificationProvider);
  return service.isInStreak;
});

/// Provider para o contador de insignias Disciplinum
final moneySavingDisciplinumProvider = Provider<int>((ref) {
  final service = ref.read(moneySavingGamificationProvider);
  return service.disciplinumCount;
});
