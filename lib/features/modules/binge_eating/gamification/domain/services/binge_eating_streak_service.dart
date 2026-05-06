import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_module_state.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Service especializado em gerenciar streaks de dias positivos do Binge Eating
/// Duplicado da gamificação central para independência total do módulo
class BingeEatingStreakService {
  /// Calcula streak baseado no histórico de dias positivos
  static int calculateStreak({
    required DateTime? lastPositiveDay,
    required DateTime? lastRelapse,
    required int currentStreak,
    DateTime? today, // Parâmetro opcional para testes
  }) {
    if (lastPositiveDay == null) return 0;
    
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final lastPositiveDate = DateTime(
      lastPositiveDay.year,
      lastPositiveDay.month,
      lastPositiveDay.day,
    );
    
    // Se já teve dia positivo hoje, manter streak atual
    if (lastPositiveDate.isAtSameMomentAs(todayDate)) {
      return currentStreak;
    }
    
    // Calcular dias desde último dia positivo
    final daysSinceLastPositive = todayDate.difference(lastPositiveDate).inDays;
    
    // Se passou mais de 1 dia, streak quebrou
    if (daysSinceLastPositive > 1) {
      return 0;
    }
    
    return currentStreak;
  }

  /// Processa recaída e retorna novo streak
  static int processRelapse({
    required DateTime? lastRelapse,
    required int currentStreak,
    DateTime? lastPositiveDay,
    DateTime? today,
  }) {
    LoggerService.instance.w('Binge Eating relapse processed - streak reset from $currentStreak to 0');
    return 0; // Reset streak em caso de recaída
  }

  /// Verifica se deve incrementar streak
  static bool shouldIncrementStreak({
    required DateTime? lastPositiveDay,
    required DateTime today,
  }) {
    if (lastPositiveDay == null) return true;
    
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastPositiveDate = DateTime(
      lastPositiveDay.year,
      lastPositiveDay.month,
      lastPositiveDay.day,
    );
    
    // Incrementar se não for o mesmo dia
    return !lastPositiveDate.isAtSameMomentAs(todayDate);
  }

  /// Verifica se streak foi quebrado
  static bool isStreakBroken({
    required DateTime? lastPositiveDay,
    DateTime? today,
  }) {
    if (lastPositiveDay == null) return true;
    
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final lastPositiveDate = DateTime(
      lastPositiveDay.year,
      lastPositiveDay.month,
      lastPositiveDay.day,
    );
    
    final daysSinceLastPositive = todayDate.difference(lastPositiveDate).inDays;
    return daysSinceLastPositive > 1;
  }

  /// Atualiza estado do módulo com nova lógica de streak
  /// NOTA: O disciplinumCount é calculado dinamicamente a partir das insígnias conquistadas
  static BingeEatingModuleState updateStreakState({
    required BingeEatingModuleState currentState,
    required bool hadPositiveDay,
    required bool hadRelapseToday,
    DateTime? today, // Parâmetro opcional para testes
  }) {
    int newStreak = currentState.consecutivePositiveDays;

    if (hadRelapseToday) {
      // Processar recaída
      newStreak = processRelapse(
        lastRelapse: today ?? DateTime.now(),
        currentStreak: newStreak,
        lastPositiveDay: null,
        today: today,
      );

      LoggerService.instance.w('Binge Eating relapse processed - streak reset to 0');
    } else if (hadPositiveDay) {
      // Processar dia positivo
      newStreak++;
      LoggerService.instance.i('Binge Eating streak incremented to $newStreak');

      LoggerService.instance.i('Binge Eating positive day processed');
    } else {
      // Verificar se streak quebra por inatividade
      // NOTA: Para verificar inatividade corretamente, precisaríamos do lastPositiveDay
      // que não está armazenado no estado atual. A lógica de streak broken deve ser
      // verificada externamente antes de chamar este método.
      LoggerService.instance.d('Binge Eating - no activity today');
    }

    // Retornar estado atualizado
    // disciplinumCount é calculado dinamicamente a partir das insígnias 'disciplinum' conquistadas
    final newDisciplinumCount = currentState.earnedInsignias.where((i) => i == 'disciplinum').length;

    return currentState.copyWith(
      consecutivePositiveDays: newStreak,
      disciplinumCount: newDisciplinumCount,
    );
  }

  /// Cria estado inicial do módulo
  static BingeEatingModuleState createInitialState({
    int consecutivePositiveDays = 0,
    DateTime? lastPositiveDay,
    int disciplinumCount = 0,
    bool isModuleActive = false,
  }) {
    return BingeEatingModuleState(
      consecutivePositiveDays: consecutivePositiveDays,
      disciplinumCount: disciplinumCount,
      isModuleActive: isModuleActive,
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
    if (streak == 0) return 'Comece sua jornada de controle hoje! 💪';
    if (streak == 1) return '1 dia sem compulsão! Parabéns!';
    if (streak == 3) return '3 dias de controle! Continue assim!';
    if (streak == 7) return '7 dias de controle! Sua força de vontade é impressionante!';
    if (streak == 14) return '14 dias de controle! Você está construindo uma vida saudável!';
    if (streak == 21) return '21 dias de controle! Hábito saudável consolidado!';
    if (streak == 30) return '30 dias de controle! Você é um mestre da disciplina!';
    if (streak == 50) return '50 dias de controle! Sua força de vontade é inspiradora!';
    if (streak == 100) return '100 dias de controle! Você é uma lenda da disciplina!!! Parabéns!';
    if (streak == 365) return '365 dias de controle! Um ano de dedicação! Incrível!';
    
    return '$streak dias de controle! Nada pode te parar!';
  }
}
