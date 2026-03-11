/// Entidade que representa o hábito alimentar de um usuário
class BingeHabit {
  final String userId;
  final DateTime? startDate;
  final List<BingeEpisode> episodes;
  final Map<String, dynamic> triggers;
  final Map<String, dynamic> preferences;
  final int currentStreak;
  final DateTime? lastEpisode;
  final int totalEpisodes;
  final int episodesThisMonth;
  final double averageSeverity;

  const BingeHabit({
    required this.userId,
    this.startDate,
    this.episodes = const [],
    this.triggers = const {},
    this.preferences = const {},
    this.currentStreak = 0,
    this.lastEpisode,
    this.totalEpisodes = 0,
    this.episodesThisMonth = 0,
    this.averageSeverity = 0.0,
  });

  /// Verifica se está em processo de controle
  bool get hasStartedControl => startDate != null;

  /// Calcula dias sem episódios
  int get daysSinceLastEpisode {
    if (lastEpisode == null) return currentStreak;
    
    final now = DateTime.now();
    final difference = now.difference(lastEpisode!);
    return difference.inDays;
  }

  /// Verifica se teve episódio hoje
  bool hadEpisodeToday() {
    if (lastEpisode == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final episodeDate = DateTime(
      lastEpisode!.year,
      lastEpisode!.month,
      lastEpisode!.day,
    );
    
    return episodeDate.isAtSameMomentAs(today);
  }

  /// Calcula taxa de recuperação
  double get recoveryRate {
    if (totalEpisodes == 0) return 1.0;
    
    final daysSinceStart = hasStartedControl 
        ? DateTime.now().difference(startDate!).inDays 
        : 0;
    
    if (daysSinceStart == 0) return 0.0;
    
    return (daysSinceStart - totalEpisodes) / daysSinceStart;
  }

  /// Obtém mensagem motivacional
  String getMotivationalMessage() {
    if (!hasStartedControl) {
      return 'Comece sua jornada para uma relação saudável com a comida! 🌟';
    }

    final days = currentStreak;
    
    if (days == 0) return 'Primeiro dia conquistado! Você está no caminho certo! 💪';
    if (days == 1) return '1 dia sem episódios! Sua força de vontade é incrível! 🔥';
    if (days == 3) return '3 dias! Você está criando consciência alimentar! 🌱';
    if (days == 7) return '1 semana! Seu corpo e mente estão agradecendo! 🏆';
    if (days == 14) return '2 semanas! Você está transformando seus hábitos! 💎';
    if (days == 21) return '21 dias! Padrões saudáveis se consolidando! 🎯';
    if (days == 30) return '1 mês! Transformação real em andamento! 🚀';
    if (days == 90) return '3 meses! Você é um exemplo de autocontrole! 👑';
    if (days == 180) return '6 meses! Meia ano de equilíbrio! 🌟';
    if (days == 365) return '1 ano! Isso é dedicação e amor próprio! 🏅';
    
    return '$days dias! Sua jornada é inspiradora! Você consegue! 🦋';
  }

  /// Obtém próximo marco
  int getNextMilestone() {
    final days = currentStreak;
    
    const milestones = [1, 3, 7, 14, 21, 30, 60, 90, 180, 365, 500, 1000];
    
    for (final milestone in milestones) {
      if (days < milestone) {
        return milestone;
      }
    }
    
    return ((days ~/ 500) + 1) * 500;
  }

  /// Verifica se atingiu marco
  bool reachedMilestone() {
    final days = currentStreak;
    const milestones = [1, 3, 7, 14, 21, 30, 60, 90, 180, 365, 500, 1000];
    return milestones.contains(days) || (days > 1000 && days % 500 == 0);
  }

  /// Analisa padrões de gatilhos
  Map<String, int> analyzeTriggers() {
    final triggerCounts = <String, int>{};
    
    for (final episode in episodes) {
      for (final trigger in episode.triggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
    }
    
    return triggerCounts;
  }

  /// Obtém gatilho mais comum
  String? getMostCommonTrigger() {
    final triggerCounts = analyzeTriggers();
    if (triggerCounts.isEmpty) return null;
    
    return triggerCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Calcula progresso mensal
  double getMonthlyProgress() {
    if (!hasStartedControl) return 0.0;
    
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    final monthlyEpisodes = episodes.where((episode) =>
        episode.timestamp.isAfter(thisMonth) && episode.timestamp.isBefore(nextMonth)
    ).length;
    
    final daysInMonth = nextMonth.difference(thisMonth).inDays;
    final goodDays = daysInMonth - monthlyEpisodes;
    
    return goodDays / daysInMonth;
  }

  /// Cria cópia com valores atualizados
  BingeHabit copyWith({
    String? userId,
    DateTime? startDate,
    List<BingeEpisode>? episodes,
    Map<String, dynamic>? triggers,
    Map<String, dynamic>? preferences,
    int? currentStreak,
    DateTime? lastEpisode,
    int? totalEpisodes,
    int? episodesThisMonth,
    double? averageSeverity,
  }) {
    return BingeHabit(
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      episodes: episodes ?? this.episodes,
      triggers: triggers ?? this.triggers,
      preferences: preferences ?? this.preferences,
      currentStreak: currentStreak ?? this.currentStreak,
      lastEpisode: lastEpisode ?? this.lastEpisode,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      episodesThisMonth: episodesThisMonth ?? this.episodesThisMonth,
      averageSeverity: averageSeverity ?? this.averageSeverity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BingeHabit &&
        other.userId == userId &&
        other.startDate == startDate &&
        other.currentStreak == currentStreak;
  }

  @override
  int get hashCode {
    return Object.hash(userId, startDate, currentStreak);
  }

  @override
  String toString() {
    return 'BingeHabit('
        'userId: $userId, '
        'hasStartedControl: $hasStartedControl, '
        'currentStreak: $currentStreak, '
        'totalEpisodes: $totalEpisodes'
        ')';
  }
}

/// Representa um episódio de compulsão alimentar
class BingeEpisode {
  final DateTime timestamp;
  final List<String> triggers;
  final List<String> foods;
  final double severity; // 0.0 a 1.0
  final int durationMinutes;
  final String? notes;
  final Map<String, dynamic> context;

  const BingeEpisode({
    required this.timestamp,
    required this.triggers,
    required this.foods,
    required this.severity,
    required this.durationMinutes,
    this.notes,
    this.context = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'triggers': triggers,
      'foods': foods,
      'severity': severity,
      'duration_minutes': durationMinutes,
      'notes': notes,
      'context': context,
    };
  }

  factory BingeEpisode.fromJson(Map<String, dynamic> json) {
    return BingeEpisode(
      timestamp: DateTime.parse(json['timestamp'] as String),
      triggers: List<String>.from(json['triggers'] as List),
      foods: List<String>.from(json['foods'] as List),
      severity: json['severity'] as double,
      durationMinutes: json['duration_minutes'] as int,
      notes: json['notes'] as String?,
      context: Map<String, dynamic>.from(json['context'] as Map? ?? {}),
    );
  }
}
