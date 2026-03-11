/// Entidade que representa hábitos de produtividade e procrastinação
class ProductivityHabit {
  final String userId;
  final DateTime? startDate;
  final List<Task> tasks;
  final Map<String, dynamic> preferences;
  final int currentStreak;
  final DateTime? lastCompletedTask;
  final int totalTasksCompleted;
  final int tasksCompletedToday;
  final double averageCompletionRate;
  final List<ProcrastinationPattern> patterns;

  const ProductivityHabit({
    required this.userId,
    this.startDate,
    this.tasks = const [],
    this.preferences = const {},
    this.currentStreak = 0,
    this.lastCompletedTask,
    this.totalTasksCompleted = 0,
    this.tasksCompletedToday = 0,
    this.averageCompletionRate = 0.0,
    this.patterns = const [],
  });

  /// Verifica se está em processo de controle
  bool get hasStartedControl => startDate != null;

  /// Calcula dias sem procrastinação
  int get daysSinceLastTask {
    if (lastCompletedTask == null) return currentStreak;
    
    final now = DateTime.now();
    final difference = now.difference(lastCompletedTask!);
    return difference.inDays;
  }

  /// Verifica se completou tarefa hoje
  bool completedTaskToday() {
    if (lastCompletedTask == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      lastCompletedTask!.year,
      lastCompletedTask!.month,
      lastCompletedTask!.day,
    );
    
    return taskDate.isAtSameMomentAs(today);
  }

  /// Calcula taxa de produtividade
  double get productivityRate {
    if (tasks.isEmpty) return 0.0;
    
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  /// Obtém mensagem motivacional
  String getMotivationalMessage() {
    if (!hasStartedControl) {
      return 'Comece sua jornada para superar a procrastinação! 🌟';
    }

    final days = currentStreak;
    
    if (days == 0) return 'Primeiro dia conquistado! Você está no caminho certo! 💪';
    if (days == 1) return '1 dia produtivo! Sua disciplina é incrível! 🔥';
    if (days == 3) return '3 dias! Você está criando o hábito da ação! 🌱';
    if (days == 7) return '1 semana! Seu foco está melhorando! 🏆';
    if (days == 14) return '2 semanas! Você está transformando sua produtividade! 💎';
    if (days == 21) return '21 dias! Hábitos produtivos se consolidando! 🎯';
    if (days == 30) return '1 mês! Transformação real em andamento! 🚀';
    if (days == 90) return '3 meses! Você é um exemplo de disciplina! 👑';
    if (days == 180) return '6 meses! Meia ano de alta produtividade! 🌟';
    if (days == 365) return '1 ano! Isso é dedicação e foco! 🏅';
    
    return '$days dias! Sua jornada é inspiradora! Continue assim! 🦋';
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

  /// Analisa padrões de procrastinação
  Map<String, int> analyzePatterns() {
    final patternCounts = <String, int>{};
    
    for (final pattern in patterns) {
      patternCounts[pattern.trigger] = (patternCounts[pattern.trigger] ?? 0) + 1;
    }
    
    return patternCounts;
  }

  /// Obtém padrão mais comum
  String? getMostCommonPattern() {
    final patternCounts = analyzePatterns();
    if (patternCounts.isEmpty) return null;
    
    return patternCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Calcula progresso semanal
  double getWeeklyProgress() {
    if (!hasStartedControl) return 0.0;
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    final weeklyTasks = tasks.where((task) =>
        task.createdAt.isAfter(weekStart) && task.createdAt.isBefore(weekEnd)
    ).toList();
    
    if (weeklyTasks.isEmpty) return 0.0;
    
    final completedWeeklyTasks = weeklyTasks.where((task) => task.isCompleted).length;
    return completedWeeklyTasks / weeklyTasks.length;
  }

  /// Obtém tarefas pendentes
  List<Task> getPendingTasks() {
    return tasks.where((task) => !task.isCompleted).toList();
  }

  /// Obtém tarefas concluídas hoje
  List<Task> getCompletedTasksToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return tasks.where((task) =>
        task.isCompleted &&
        task.completedAt != null &&
        DateTime(task.completedAt!.year, task.completedAt!.month, task.completedAt!.day)
            .isAtSameMomentAs(today)
    ).toList();
  }

  /// Cria cópia com valores atualizados
  ProductivityHabit copyWith({
    String? userId,
    DateTime? startDate,
    List<Task>? tasks,
    Map<String, dynamic>? preferences,
    int? currentStreak,
    DateTime? lastCompletedTask,
    int? totalTasksCompleted,
    int? tasksCompletedToday,
    double? averageCompletionRate,
    List<ProcrastinationPattern>? patterns,
  }) {
    return ProductivityHabit(
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      tasks: tasks ?? this.tasks,
      preferences: preferences ?? this.preferences,
      currentStreak: currentStreak ?? this.currentStreak,
      lastCompletedTask: lastCompletedTask ?? this.lastCompletedTask,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      tasksCompletedToday: tasksCompletedToday ?? this.tasksCompletedToday,
      averageCompletionRate: averageCompletionRate ?? this.averageCompletionRate,
      patterns: patterns ?? this.patterns,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductivityHabit &&
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
    return 'ProductivityHabit('
        'userId: $userId, '
        'hasStartedControl: $hasStartedControl, '
        'currentStreak: $currentStreak, '
        'totalTasksCompleted: $totalTasksCompleted'
        ')';
  }
}

/// Representa uma tarefa de produtividade
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? deadline;
  final int priority; // 1-5
  final List<String> tags;
  final int estimatedMinutes;
  final int? actualMinutes;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.completedAt,
    this.deadline,
    this.priority = 3,
    this.tags = const [],
    this.estimatedMinutes = 30,
    this.actualMinutes,
    this.isCompleted = false,
    this.metadata = const {},
  });

  /// Verifica se está atrasada
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Verifica se é urgente (vence em 24h)
  bool get isUrgent {
    if (deadline == null || isCompleted) return false;
    final now = DateTime.now();
    final urgencyThreshold = now.add(const Duration(days: 1));
    return deadline!.isBefore(urgencyThreshold);
  }

  /// Calcula eficiência (tempo estimado vs tempo real)
  double get efficiency {
    if (actualMinutes == null || estimatedMinutes == 0) return 1.0;
    return estimatedMinutes / actualMinutes!;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'tags': tags,
      'estimated_minutes': estimatedMinutes,
      'actual_minutes': actualMinutes,
      'is_completed': isCompleted,
      'metadata': metadata,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'] as String) 
          : null,
      priority: json['priority'] as int? ?? 3,
      tags: List<String>.from(json['tags'] as List? ?? []),
      estimatedMinutes: json['estimated_minutes'] as int? ?? 30,
      actualMinutes: json['actual_minutes'] as int?,
      isCompleted: json['is_completed'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}

/// Representa um padrão de procrastinação
class ProcrastinationPattern {
  final String trigger;
  final DateTime timestamp;
  final String context;
  final int delayMinutes;
  final String? taskAvoided;

  const ProcrastinationPattern({
    required this.trigger,
    required this.timestamp,
    required this.context,
    required this.delayMinutes,
    this.taskAvoided,
  });

  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'delay_minutes': delayMinutes,
      'task_avoided': taskAvoided,
    };
  }

  factory ProcrastinationPattern.fromJson(Map<String, dynamic> json) {
    return ProcrastinationPattern(
      trigger: json['trigger'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      context: json['context'] as String,
      delayMinutes: json['delay_minutes'] as int,
      taskAvoided: json['task_avoided'] as String?,
    );
  }
}
