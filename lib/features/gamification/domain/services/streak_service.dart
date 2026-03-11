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
  }) {
    if (lastCheckIn == null) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheckInDate = DateTime(
      lastCheckIn.year,
      lastCheckIn.month,
      lastCheckIn.day,
    );
    
    // Se já fez check-in hoje, manter streak atual
    if (lastCheckInDate.isAtSameMomentAs(today)) {
      return currentStreak;
    }
    
    // Se passou mais de 1 dia sem check-in, streak quebra
    final daysSinceLastCheckIn = today.difference(lastCheckInDate).inDays;
    if (daysSinceLastCheckIn > 1) {
      LoggerService.instance.d('Streak broken: $daysSinceLastCheckIn days since last check-in');
      return 0;
    }
    
    // Se ontem fez check-in e hoje ainda não, manter streak
    return currentStreak;
  }

  /// Verifica se streak deve ser incrementado
  static bool shouldIncrementStreak({
    required DateTime? lastCheckIn,
    required DateTime? lastRelapse,
  }) {
    if (lastCheckIn == null) return true;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheckInDate = DateTime(
      lastCheckIn.year,
      lastCheckIn.month,
      lastCheckIn.day,
    );
    
    // Se já fez check-in hoje, não incrementar
    if (lastCheckInDate.isAtSameMomentAs(today)) {
      return false;
    }
    
    // Se ontem fez check-in, pode incrementar
    final yesterday = today.subtract(const Duration(days: 1));
    return lastCheckInDate.isAtSameMomentAs(yesterday);
  }

  /// Processa recaída e reseta streak se necessário
  static int processRelapse({
    required DateTime? lastRelapse,
    required int currentStreak,
    required DateTime? lastCheckIn,
  }) {
    if (lastRelapse == null) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final relapseDate = DateTime(
      lastRelapse.year,
      lastRelapse.month,
      lastRelapse.day,
    );
    
    // Se recaída foi hoje, resetar streak
    if (relapseDate.isAtSameMomentAs(today)) {
      LoggerService.instance.i('Streak reset due to relapse today');
      return 0;
    }
    
    // Se recaída foi ontem e não fez check-in hoje, resetar
    if (lastCheckIn == null) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (relapseDate.isAtSameMomentAs(yesterday)) {
        LoggerService.instance.i('Streak reset due to yesterday relapse without check-in');
        return 0;
      }
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

  /// Calcula dias para perder streak (grace period)
  static int getGracePeriodDays(int streakLength) {
    if (streakLength < 7) return 1; // 1 dia de grace period
    if (streakLength < 30) return 2; // 2 dias de grace period
    if (streakLength < 100) return 3; // 3 dias de grace period
    return 5; // 5 dias de grace period para streaks longas
  }

  /// Verifica se está em grace period
  static bool isInGracePeriod({
    required DateTime? lastCheckIn,
    required int streakLength,
  }) {
    if (lastCheckIn == null || streakLength == 0) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheckInDate = DateTime(
      lastCheckIn.year,
      lastCheckIn.month,
      lastCheckIn.day,
    );
    
    final daysSinceLastCheckIn = today.difference(lastCheckInDate).inDays;
    final gracePeriod = getGracePeriodDays(streakLength);
    
    return daysSinceLastCheckIn <= gracePeriod;
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
    if (streakLength == 1) return 'Primeiro dia! Continue assim! 🌟';
    if (streakLength == 3) return '3 dias! Você está criando um hábito! 🔥';
    if (streakLength == 7) return '1 semana! Consistência é a chave! 🗝️';
    if (streakLength == 14) return '2 semanas! Você está incrível! 🚀';
    if (streakLength == 21) return '21 dias! Hábito consolidado! 🎯';
    if (streakLength == 30) return '1 mês! Transformação real! 🏆';
    if (streakLength == 66) return '66 dias! Você é disciplinado! 👑';
    if (streakLength == 100) return '100 dias! Lendário! 🏅';
    if (streakLength == 365) return '1 ano! Isso é dedicação! 🌟';
    
    return '$streakLength dias! Nada pode te parar! 💎';
  }

  /// Calcula fator de multiplicação de XP baseado no streak
  static double getXpMultiplier(int streakLength) {
    if (streakLength < 7) return 1.0;
    if (streakLength < 14) return 1.1;
    if (streakLength < 21) return 1.2;
    if (streakLength < 30) return 1.3;
    if (streakLength < 66) return 1.5;
    if (streakLength < 100) return 1.7;
    if (streakLength < 365) return 2.0;
    
    return 2.5; // 1+ ano de streak
  }

  /// Atualiza estado do módulo com nova lógica de streak
  static ModuleState updateStreakState({
    required ModuleState currentState,
    required bool didCheckInToday,
    required bool hadRelapseToday,
  }) {
    int newStreak = currentState.consecutiveDays;
    DateTime? newLastCheckIn = currentState.lastCheckIn;
    DateTime? newLastRelapse = currentState.lastRelapse;
    int newTotalCheckIns = currentState.totalCheckIns;
    int newTotalRelapses = currentState.totalRelapses;

    if (hadRelapseToday) {
      // Processar recaída
      newStreak = processRelapse(
        lastRelapse: DateTime.now(),
        currentStreak: newStreak,
        lastCheckIn: newLastCheckIn,
      );
      newLastRelapse = DateTime.now();
      newTotalRelapses++;
      
      LoggerService.instance.w('Relapse processed for module ${currentState.nicheId}');
    } else if (didCheckInToday) {
      // Processar check-in
      if (shouldIncrementStreak(
        lastCheckIn: newLastCheckIn,
        lastRelapse: newLastRelapse,
      )) {
        newStreak++;
        LoggerService.instance.i('Streak incremented to $newStreak for module ${currentState.nicheId}');
      }
      
      newLastCheckIn = DateTime.now();
      newTotalCheckIns++;
      
      LoggerService.instance.i('Check-in processed for module ${currentState.nicheId}');
    } else {
      // Verificar se streak quebra por inatividade
      newStreak = calculateStreak(
        lastCheckIn: newLastCheckIn,
        lastRelapse: newLastRelapse,
        currentStreak: newStreak,
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
