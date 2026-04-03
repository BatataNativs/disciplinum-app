import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_module_state.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Service especializado em gerenciar streaks de dias livres do Adult Content
/// Duplicado da gamificação central para independência total do módulo
class AdultContentStreakService {
  /// Calcula streak baseado no histórico de dias livres
  static int calculateStreak({
    required DateTime? lastFreeDay,
    required DateTime? lastRelapse,
    required int currentStreak,
    DateTime? today, // Parâmetro opcional para testes
  }) {
    if (lastFreeDay == null) return 0;
    
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final lastFreeDate = DateTime(
      lastFreeDay.year,
      lastFreeDay.month,
      lastFreeDay.day,
    );
    
    // Se já teve dia livre hoje, manter streak atual
    if (lastFreeDate.isAtSameMomentAs(todayDate)) {
      return currentStreak;
    }
    
    // Calcular dias desde último dia livre
    final daysSinceLastFree = todayDate.difference(lastFreeDate).inDays;
    
    // Se passou mais de 1 dia, streak quebrou
    if (daysSinceLastFree > 1) {
      return 0;
    }
    
    return currentStreak;
  }

  /// Processa recaída e retorna novo streak
  static int processRelapse({
    required DateTime? lastRelapse,
    required int currentStreak,
    DateTime? lastFreeDay,
    DateTime? today,
  }) {
    LoggerService.instance.w('Adult Content relapse processed - streak reset from $currentStreak to 0');
    return 0; // Reset streak em caso de recaída
  }

  /// Verifica se deve incrementar streak
  static bool shouldIncrementStreak({
    required DateTime? lastFreeDay,
    required DateTime today,
  }) {
    if (lastFreeDay == null) return true;
    
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastFreeDate = DateTime(
      lastFreeDay.year,
      lastFreeDay.month,
      lastFreeDay.day,
    );
    
    // Incrementar se não for o mesmo dia
    return !lastFreeDate.isAtSameMomentAs(todayDate);
  }

  /// Verifica se streak foi quebrado
  static bool isStreakBroken({
    required DateTime? lastFreeDay,
    DateTime? today,
  }) {
    if (lastFreeDay == null) return true;
    
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final lastFreeDate = DateTime(
      lastFreeDay.year,
      lastFreeDay.month,
      lastFreeDay.day,
    );
    
    final daysSinceLastFree = todayDate.difference(lastFreeDate).inDays;
    return daysSinceLastFree > 1;
  }

  /// Atualiza estado do módulo com nova lógica de streak
  static AdultContentModuleState updateStreakState({
    required AdultContentModuleState currentState,
    required bool hadFreeDay,
    required bool hadRelapseToday,
    DateTime? today, // Parâmetro opcional para testes
  }) {
    int newStreak = currentState.consecutiveDays;
    DateTime? newLastFreeDay;
    int newDisciplinumCount = currentState.disciplinumCount;

    if (hadRelapseToday) {
      // Processar recaída
      newStreak = processRelapse(
        lastRelapse: today ?? DateTime.now(),
        currentStreak: newStreak,
        lastFreeDay: newLastFreeDay,
        today: today,
      );
      newLastFreeDay = null; // Reset em caso de recaída
      
      LoggerService.instance.w('Adult Content relapse processed - streak reset to 0');
    } else if (hadFreeDay) {
      // Processar dia livre
      if (shouldIncrementStreak(
        lastFreeDay: newLastFreeDay,
        today: today ?? DateTime.now(),
      )) {
        newStreak++;
        LoggerService.instance.i('Adult Content streak incremented to $newStreak');
      }
      
      newLastFreeDay = today ?? DateTime.now();
      newDisciplinumCount++;
      
      LoggerService.instance.i('Adult Content free day processed');
    } else {
      // Verificar se streak quebra por inatividade
      if (isStreakBroken(lastFreeDay: newLastFreeDay, today: today)) {
        newStreak = 0;
        LoggerService.instance.w('Adult Content streak broken due to inactivity');
      }
    }

    // Retornar estado atualizado
    return currentState.copyWith(
      consecutiveDays: newStreak,
      disciplinumCount: newDisciplinumCount,
    );
  }

  /// Cria estado inicial do módulo
  static AdultContentModuleState createInitialState({
    required DateTime updatedAt,
    int consecutiveDays = 0,
    DateTime? lastFreeDay,
    int disciplinumCount = 0,
    bool isActive = false,
  }) {
    return AdultContentModuleState(
      updatedAt: updatedAt,
      consecutiveDays: consecutiveDays,
      disciplinumCount: disciplinumCount,
      isActive: isActive,
    );
  }

  /// Obtém próximo milestone de streak
  static int getNextStreakMilestone(int currentStreak) {
    const milestones = [1, 3, 7, 14, 21, 30, 50, 100, 365];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    
    // Se passou todos os milestones, próximo é a cada 100 dias
    return ((currentStreak ~/ 100) + 1) * 100;
  }

  /// Verifica se alcançou milestone
  static bool reachedStreakMilestone(int currentStreak) {
    const milestones = [1, 3, 7, 14, 21, 30, 50, 100, 365];
    return milestones.contains(currentStreak);
  }

  /// Obtém mensagem motivacional baseada no streak
  static String getStreakMessage(int streak) {
    if (streak == 0) return 'Comece sua jornada de disciplina hoje! 💪';
    if (streak == 1) return '1 dia livre! Parabéns!';
    if (streak == 3) return '3 dias livres! Continue assim!';
    if (streak == 7) return '7 dias livres! Sua força de vontade é impressionante!';
    if (streak == 14) return '14 dias livres! Você está construindo uma vida melhor!';
    if (streak == 21) return '21 dias livres! Hábito de disciplina consolidado!';
    if (streak == 30) return '30 dias livres! Você é um mestre da disciplina!';
    if (streak == 50) return '50 dias livres! Sua força de vontade é inspiradora!';
    if (streak == 100) return '100 dias livres! Você é uma lenda da disciplina!!! Parabéns!';
    if (streak == 365) return '365 dias livres! Um ano de dedicação! Incrível!';
    
    return '$streak dias livres! Nada pode te parar!';
  }
}
