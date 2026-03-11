/// Engine responsável por cálculos precisos de Streaks (Dias Consecutivos),
/// isolando a matemática de dias, fusos horários e recaídas do GamificationService.
class StreakCalculator {
  static final StreakCalculator instance = StreakCalculator._internal();
  StreakCalculator._internal();

  /// Calcula o streak atual puramente baseado em recaídas e tempo decorrido.
  /// Ideal para módulos de abstenção (Procrastinação, Fumar, Compulsão).
  int calculateAbstinenceStreak({
    required DateTime activationDate,
    DateTime? lastRelapseDate,
  }) {
    final now = DateTime.now();
    final effectiveStart = lastRelapseDate ?? activationDate;

    // Zera horas para evitar que um dia conte a menos por causa de horas.
    final startDay =
        DateTime(effectiveStart.year, effectiveStart.month, effectiveStart.day);
    final today = DateTime(now.year, now.month, now.day);

    int streak = today.difference(startDay).inDays;
    return streak < 0 ? 0 : streak;
  }

  /// Calcula o streak construtivo, baseado na constância diária de ações.
  /// Quebra o streak se passar mais de 1 dia sem ação.
  int calculateActionStreak({
    required DateTime activationDate,
    DateTime? lastActionDate,
  }) {
    if (lastActionDate == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final actionDay =
        DateTime(lastActionDate.year, lastActionDate.month, lastActionDate.day);

    final daysSinceLastAction = today.difference(actionDay).inDays;

    // Se ficou mais de 1 dia (ontem) sem fazer, quebrou o streak
    if (daysSinceLastAction > 1) {
      return 0; // Streak quebrado
    }

    // Se fez hoje ou ontem, conta desde o início da fase atual
    final startDay =
        DateTime(activationDate.year, activationDate.month, activationDate.day);
    return actionDay.difference(startDay).inDays +
        1; // +1 porque o dia da ação conta
  }

  /// Verifica se houve transição de dia (Midnight Check) para atualização de recompensas
  bool hasPassedMidnight(DateTime lastCheck) {
    final now = DateTime.now();
    return lastCheck.day != now.day ||
        lastCheck.month != now.month ||
        lastCheck.year != now.year;
  }
}
