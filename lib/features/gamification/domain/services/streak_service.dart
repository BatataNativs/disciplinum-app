import 'package:disciplinum/features/gamification/domain/entities/module_state.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Service especializado em gerenciar streaks (sequências)
/// Separado do GamificationService para seguir Single Responsibility Principle
class StreakService {
  /// Calcula streak baseado no histórico de check-ins
  static int calculateStreak({
    required DateTime? lastCheckIn,
    required DateTime? lastRelapse,
    required int currentStreak,
    DateTime? today, // Parâmetro opcional para testes
  }) {
    if (lastCheckIn == null) return 0;
    
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final lastCheckInDate = DateTime(
      lastCheckIn.year,
      lastCheckIn.month,
      lastCheckIn.day,
    );
    
    // Se já fez check-in hoje, manter streak atual
    if (lastCheckInDate.isAtSameMomentAs(todayDate)) {
      return currentStreak;
    }
    
    // Calcular dias desde último check-in (sem grace period)
    final daysSinceLastCheckIn = todayDate.difference(lastCheckInDate).inDays;
    
    // Se passou mais de 1 dia, streak quebra (sem tolerância)
    if (daysSinceLastCheckIn > 1) {
      LoggerService.instance.d('Streak broken: $daysSinceLastCheckIn days since last check-in (no grace period)');
      return 0;
    }
    
    // Se está dentro do período permitido (1 dia), incrementar streak
    return currentStreak;
  }

  /// Verifica se streak deve ser incrementado
  static bool shouldIncrementStreak({
    required DateTime? lastCheckIn,
    required DateTime today,
  }) {
    if (lastCheckIn == null) return true;
    
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastCheckInDate = DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day);
    
    // Se já fez check-in hoje, não incrementar
    if (lastCheckInDate.isAtSameMomentAs(todayDate)) {
      return false;
    }
    
    // Se passou exatamente 1 dia, pode incrementar
    final daysSinceLastCheckIn = todayDate.difference(lastCheckInDate).inDays;
    return daysSinceLastCheckIn == 1;
  }

  /// Processa recaída e reseta streak se necessário
  static int processRelapse({
    required DateTime? lastRelapse,
    required int currentStreak,
    required DateTime? lastCheckIn,
    DateTime? today, // Parâmetro opcional para testes
  }) {
    if (lastRelapse == null) return 0;
    
    final relapseDate = DateTime(
      lastRelapse.year,
      lastRelapse.month,
      lastRelapse.day,
    );
    
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    
    // Se a recaída foi hoje, resetar streak
    if (relapseDate.isAtSameMomentAs(todayDate)) {
      LoggerService.instance.i('Streak reset due to relapse today');
      return 0;
    }
    
    // Se a recaída foi ontem e não fez check-in hoje, resetar streak
    if (lastCheckIn == null) {
      final yesterday = todayDate.subtract(const Duration(days: 1));
      if (relapseDate.isAtSameMomentAs(yesterday)) {
        LoggerService.instance.i('Streak reset due to relapse yesterday with no check-in today');
        return 0;
      }
    }
    
    // Se a recaída foi antes do último check-in, resetar streak
    if (lastCheckIn != null && lastRelapse.isAfter(lastCheckIn)) {
      LoggerService.instance.i('Streak reset due to relapse after last check-in');
      return 0;
    }
    
    return currentStreak;
  }

  /// Calcula próximo milestone de streak
  static int getNextMilestone(int currentStreak) {
    const milestones = [1, 3, 7, 14, 21, 30, 50, 66, 100, 365, 500, 1000];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    
    // Se passou todos os milestones, próximo é a cada 100 dias
    return ((currentStreak ~/ 100) + 1) * 100;
  }

  /// Verifica se atingiu milestone
  static bool reachedMilestone(int currentStreak) {
    const milestones = [1, 3, 7, 14, 21, 30, 50, 66, 100, 365, 500, 1000];
    return milestones.contains(currentStreak) || (currentStreak > 100 && currentStreak % 100 == 0);
  }

  /// Verifica se está dentro do período permitido (1 dia)
  static bool isInGracePeriod({
    required DateTime? lastCheckIn,
    required int streakLength,
    DateTime? today, // Parâmetro opcional para testes
  }) {
    if (lastCheckIn == null || streakLength == 0) return false;
    
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final lastCheckInDate = DateTime(
      lastCheckIn.year,
      lastCheckIn.month,
      lastCheckIn.day,
    );
    
    final daysSinceLastCheckIn = todayDate.difference(lastCheckInDate).inDays;
    
    // Sem grace period - apenas 1 dia permitido
    return daysSinceLastCheckIn <= 1;
  }

  /// Calcula streak freeze disponível
  static int getStreakFreezeCount(int streakLength) {
    // Concede streak freeze a cada 30 dias de streak
    return (streakLength ~/ 30);
  }

  /// Usa streak freeze para manter streak
  static bool useStreakFreeze({
    required int availableFreezes,
    required int currentStreak,
  }) {
    if (availableFreezes <= 0 || currentStreak == 0) return false;
    
    LoggerService.instance.i('Streak freeze used to maintain $currentStreak day streak');
    return true;
  }

  /// Gera mensagem motivacional baseada no streak
  static String getStreakMessage(int streakLength) {
    if (streakLength == 0) return 'Comece sua jornada hoje! 💪';
    if (streakLength == 1) return '1 dia disciplinado. Parabéns!';
    if (streakLength == 3) return '3 dias consecutivos! Continue assim!';
    if (streakLength == 7) return '7 dias consecutivos! Consistência é a chave!';
    if (streakLength == 14) return '14 dias consecutivos! Você está no caminho certo!';
    if (streakLength == 21) return '21 dias consecutivos! Hábito consolidado!';
    if (streakLength == 30) return '30 dias consecutivos! Você está muito focado!';
    if (streakLength == 50) return '50 dias consecutivos! Muito focado!';
    if (streakLength == 100) return '100 dias consecutivos! Você é extremamente disciplinado!!! Parabéns!';
    if (streakLength == 365) return '365 dias consecutivos! Um ano de dedicação! Incrível!';
    
    return '$streakLength dias consecutivos! Nada pode te parar!';
  }

  
  /// Atualiza estado do módulo com nova lógica de streak
  static ModuleState updateStreakState({
    required ModuleState currentState,
    required bool didCheckInToday,
    required bool hadRelapseToday,
    DateTime? today, // Parâmetro opcional para testes
  }) {
    int newStreak = currentState.consecutiveDays;
    DateTime? newLastCheckIn = currentState.lastCheckIn;
    DateTime? newLastRelapse = currentState.lastRelapse;
    int newTotalCheckIns = currentState.totalCheckIns;
    int newTotalRelapses = currentState.totalRelapses;

    if (hadRelapseToday) {
      // Processar recaída
      newStreak = processRelapse(
        lastRelapse: today ?? DateTime.now(),
        currentStreak: newStreak,
        lastCheckIn: newLastCheckIn,
        today: today,
      );
      newLastRelapse = today ?? DateTime.now();
      newTotalRelapses++;
      
      LoggerService.instance.w('Relapse processed for module ${currentState.nicheId}');
    } else if (didCheckInToday) {
      // Processar check-in
      if (shouldIncrementStreak(
        lastCheckIn: newLastCheckIn,
        today: today ?? DateTime.now(),
      )) {
        newStreak++;
        LoggerService.instance.i('Streak incremented to $newStreak for module ${currentState.nicheId}');
      }
      
      newLastCheckIn = today ?? DateTime.now();
      newTotalCheckIns++;
      
      LoggerService.instance.i('Check-in processed for module ${currentState.nicheId}');
    } else {
      // Verificar se streak quebra por inatividade
      newStreak = calculateStreak(
        lastCheckIn: newLastCheckIn,
        lastRelapse: newLastRelapse,
        currentStreak: newStreak,
        today: today,
      );
    }

    return currentState.copyWith(
      consecutiveDays: newStreak,
      lastCheckIn: newLastCheckIn,
      lastRelapse: newLastRelapse,
      totalCheckIns: newTotalCheckIns,
      totalRelapses: newTotalRelapses,
      lastUpdated: DateTime.now(),
    );
  }
}
