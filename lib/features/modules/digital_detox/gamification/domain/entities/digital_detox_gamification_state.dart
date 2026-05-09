/// Estado de gamificaÃ§Ã£o do mÃ³dulo Jejum Digital
/// ContÃ©m todas as informaÃ§Ãµes de progresso, streaks e conquistas
class DigitalDetoxGamificationState {
  final bool isModuleActive;
  final int currentStreak;
  final int longestStreak;
  final int totalDisciplinedDays;
  final int todayScreenTimeMinutes;
  final int todayLimitMinutes;
  final bool wasDisciplinedToday;
  final bool isNearLimit;
  final int remainingMinutes;
  final Map<String, int> appUsage;
  final List<DigitalDetoxFastingBreakInfo> availableFastingBreaks;
  final bool hasUsedFastingBreakToday;
  final bool isLoading;
  final String? error;
  
  // Contrato PadrÃ£o de GamificaÃ§Ã£o
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int disciplinumCount;

  const DigitalDetoxGamificationState({
    this.isModuleActive = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalDisciplinedDays = 0,
    this.todayScreenTimeMinutes = 0,
    this.todayLimitMinutes = 60,
    this.wasDisciplinedToday = false,
    this.isNearLimit = false,
    this.remainingMinutes = 60,
    this.appUsage = const {},
    this.availableFastingBreaks = const [],
    this.hasUsedFastingBreakToday = false,
    this.isLoading = false,
    this.error,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.disciplinumCount = 0,
  });

  DigitalDetoxGamificationState copyWith({
    bool? isModuleActive,
    int? currentStreak,
    int? longestStreak,
    int? totalDisciplinedDays,
    int? todayScreenTimeMinutes,
    int? todayLimitMinutes,
    bool? wasDisciplinedToday,
    bool? isNearLimit,
    int? remainingMinutes,
    Map<String, int>? appUsage,
    List<DigitalDetoxFastingBreakInfo>? availableFastingBreaks,
    bool? hasUsedFastingBreakToday,
    bool? isLoading,
    String? error,
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? disciplinumCount,
  }) {
    return DigitalDetoxGamificationState(
      isModuleActive: isModuleActive ?? this.isModuleActive,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalDisciplinedDays: totalDisciplinedDays ?? this.totalDisciplinedDays,
      todayScreenTimeMinutes: todayScreenTimeMinutes ?? this.todayScreenTimeMinutes,
      todayLimitMinutes: todayLimitMinutes ?? this.todayLimitMinutes,
      wasDisciplinedToday: wasDisciplinedToday ?? this.wasDisciplinedToday,
      isNearLimit: isNearLimit ?? this.isNearLimit,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      appUsage: appUsage ?? this.appUsage,
      availableFastingBreaks: availableFastingBreaks ?? this.availableFastingBreaks,
      hasUsedFastingBreakToday: hasUsedFastingBreakToday ?? this.hasUsedFastingBreakToday,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
    );
  }

  /// Porcentagem de progresso do limite diÃ¡rio (0-100)
  double get todayProgressPercentage {
    if (todayLimitMinutes <= 0) return 0;
    final percentage = (todayScreenTimeMinutes / todayLimitMinutes) * 100;
    return percentage.clamp(0, 100);
  }

  /// Verifica se estÃ¡ dentro do limite
  bool get isWithinLimit => todayScreenTimeMinutes < todayLimitMinutes;

  /// Formata o tempo usado hoje
  String get formattedTodayUsage => _formatDuration(todayScreenTimeMinutes);

  /// Formata o limite diÃ¡rio
  String get formattedDailyLimit => _formatDuration(todayLimitMinutes);

  /// Formata minutos restantes
  String get formattedRemaining => _formatDuration(remainingMinutes);

  /// Retorna mensagem de status
  String get statusMessage {
    if (!isModuleActive) return 'MÃ³dulo inativo';
    if (wasDisciplinedToday) return 'Dia disciplinado! ðŸŽ‰';
    if (isNearLimit) return 'PrÃ³ximo do limite! âš ï¸';
    if (!isWithinLimit) return 'Limite atingido';
    return 'Dentro do limite âœ…';
  }

  static String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}min';
    }
  }
}

/// InformaÃ§Ã£o sobre uma Quebra de Jejum disponÃ­vel
class DigitalDetoxFastingBreakInfo {
  final int id;
  final DateTime earnedAt;
  final DateTime? expiresAt;
  final int daysDisciplinedCount;
  final bool isExpired;

  const DigitalDetoxFastingBreakInfo({
    required this.id,
    required this.earnedAt,
    this.expiresAt,
    required this.daysDisciplinedCount,
    this.isExpired = false,
  });
}

/// Conquistas disponÃ­veis no mÃ³dulo Jejum Digital
enum DigitalDetoxAchievement {
  firstDay('Primeiro Dia', 'Complete seu primeiro dia disciplinado', 1),
  weekWarrior('Guerreiro da Semana', '7 dias disciplinados consecutivos', 7),
  monthMaster('Mestre do MÃªs', '30 dias disciplinados', 30),
  perfectWeek('Semana Perfeita', '7 dias disciplinados na mesma semana', 7),
  socialFree('Livre das Redes', '24h sem usar redes sociais', 1),
  streakSaver('Salvador de Streaks', 'Use uma Quebra de Jejum', 1),
  timeMaster('Mestre do Tempo', 'Fique 50% abaixo do limite por 7 dias', 7),
  earlyBird('Cedo e Disciplinado', 'NÃ£o use apps antes das 8h por 5 dias', 5);

  final String name;
  final String description;
  final int requiredDays;

  const DigitalDetoxAchievement(this.name, this.description, this.requiredDays);
}
