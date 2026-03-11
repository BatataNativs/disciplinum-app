/// Entidade que representa o hábito de economizar dinheiro
class SavingHabit {
  final String userId;
  final DateTime? startDate;
  final List<SavingGoal> goals;
  final List<TransactionRecord> transactions;
  final Map<String, dynamic> preferences;
  final int currentStreak;
  final DateTime? lastDeposit;
  final double totalSaved;
  final int depositsThisMonth;
  final double averageDepositAmount;

  const SavingHabit({
    required this.userId,
    this.startDate,
    this.goals = const [],
    this.transactions = const [],
    this.preferences = const {},
    this.currentStreak = 0,
    this.lastDeposit,
    this.totalSaved = 0.0,
    this.depositsThisMonth = 0,
    this.averageDepositAmount = 0.0,
  });

  /// Verifica se está em processo de economia
  bool get hasStartedSaving => startDate != null;

  /// Calcula dias desde último depósito
  int get daysSinceLastDeposit {
    if (lastDeposit == null) return currentStreak;
    
    final now = DateTime.now();
    final difference = now.difference(lastDeposit!);
    return difference.inDays;
  }

  /// Verifica se fez depósito hoje
  bool depositedToday() {
    if (lastDeposit == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final depositDate = DateTime(
      lastDeposit!.year,
      lastDeposit!.month,
      lastDeposit!.day,
    );
    
    return depositDate.isAtSameMomentAs(today);
  }

  /// Calcula taxa de economia mensal
  double get monthlySavingRate {
    if (!hasStartedSaving) return 0.0;
    
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    final monthlyDeposits = transactions.where((transaction) =>
        transaction.type == TransactionType.deposit &&
        transaction.timestamp.isAfter(thisMonth) && 
        transaction.timestamp.isBefore(nextMonth)
    ).fold(0.0, (sum, transaction) => sum + transaction.amount);
    
    // Supondo meta mensal de R$ 100
    const monthlyGoal = 100.0;
    return (monthlyDeposits / monthlyGoal).clamp(0.0, 1.0);
  }

  /// Obtém mensagem motivacional
  String getMotivationalMessage() {
    if (!hasStartedSaving) {
      return 'Comece seu desafio de economia! Cada centavo conta! 🌟';
    }

    final days = currentStreak;
    
    if (days == 0) return 'Primeiro dia conquistado! Você está no caminho certo! 💪';
    if (days == 1) return '1 dia economizando! Sua disciplina é incrível! 🔥';
    if (days == 3) return '3 dias! Você está criando o hábito de poupar! 🌱';
    if (days == 7) return '1 semana! Seu cofrinho está crescendo! 🏆';
    if (days == 14) return '2 semanas! Você está transformando seu futuro! 💎';
    if (days == 21) return '21 dias! Hábito de economia consolidado! 🎯';
    if (days == 30) return '1 mês! Transformação financeira em andamento! 🚀';
    if (days == 90) return '3 meses! Você é um exemplo de disciplina financeira! 👑';
    if (days == 180) return '6 meses! Meia ano de prosperidade! 🌟';
    if (days == 365) return '1 ano! Isso é dedicação e sabedoria! 🏅';
    
    return '$days dias! Sua jornada financeira é inspiradora! Continue assim! 🦋';
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

  /// Calcula progresso das metas
  Map<String, double> getGoalsProgress() {
    final progress = <String, double>{};
    
    for (final goal in goals) {
      final savedForGoal = transactions
          .where((transaction) =>
              transaction.type == TransactionType.deposit &&
              transaction.timestamp.isAfter(goal.createdAt))
          .fold(0.0, (sum, transaction) => sum + transaction.amount);
      
      progress[goal.id] = (savedForGoal / goal.targetAmount).clamp(0.0, 1.0);
    }
    
    return progress;
  }

  /// Obtém metas concluídas
  List<SavingGoal> getCompletedGoals() {
    final progress = getGoalsProgress();
    return goals.where((goal) => 
        progress[goal.id] != null && progress[goal.id]! >= 1.0
    ).toList();
  }

  /// Calcula economia por categoria
  Map<String, double> getSavingsByCategory() {
    final categorySavings = <String, double>{};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.deposit) {
        final category = transaction.category ?? 'Geral';
        categorySavings[category] = (categorySavings[category] ?? 0.0) + transaction.amount;
      }
    }
    
    return categorySavings;
  }

  /// Obtém depósitos deste mês
  List<TransactionRecord> getDepositsThisMonth() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    return transactions.where((transaction) =>
        transaction.type == TransactionType.deposit &&
        transaction.timestamp.isAfter(thisMonth) && 
        transaction.timestamp.isBefore(nextMonth)
    ).toList();
  }

  /// Verifica se atingiu alguma meta hoje
  bool reachedGoalToday() {
    final todayGoals = goals.where((goal) {
      final progress = getGoalsProgress()[goal.id] ?? 0.0;
      return progress >= 1.0;
    });
    
    return todayGoals.isNotEmpty;
  }

  /// Cria cópia com valores atualizados
  SavingHabit copyWith({
    String? userId,
    DateTime? startDate,
    List<SavingGoal>? goals,
    List<TransactionRecord>? transactions,
    Map<String, dynamic>? preferences,
    int? currentStreak,
    DateTime? lastDeposit,
    double? totalSaved,
    int? depositsThisMonth,
    double? averageDepositAmount,
  }) {
    return SavingHabit(
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      goals: goals ?? this.goals,
      transactions: transactions ?? this.transactions,
      preferences: preferences ?? this.preferences,
      currentStreak: currentStreak ?? this.currentStreak,
      lastDeposit: lastDeposit ?? this.lastDeposit,
      totalSaved: totalSaved ?? this.totalSaved,
      depositsThisMonth: depositsThisMonth ?? this.depositsThisMonth,
      averageDepositAmount: averageDepositAmount ?? this.averageDepositAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingHabit &&
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
    return 'SavingHabit('
        'userId: $userId, '
        'hasStartedSaving: $hasStartedSaving, '
        'currentStreak: $currentStreak, '
        'totalSaved: $totalSaved'
        ')';
  }
}

/// Representa uma meta de economia
class SavingGoal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final DateTime createdAt;
  final DateTime? deadline;
  final String category;
  final String? icon;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  const SavingGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.createdAt,
    this.deadline,
    this.category = 'Geral',
    this.icon,
    this.isCompleted = false,
    this.metadata = const {},
  });

  /// Verifica se está atrasada
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Verifica se é urgente (vence em 7 dias)
  bool get isUrgent {
    if (deadline == null || isCompleted) return false;
    final now = DateTime.now();
    final urgencyThreshold = now.add(const Duration(days: 7));
    return deadline!.isBefore(urgencyThreshold);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'created_at': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'category': category,
      'icon': icon,
      'is_completed': isCompleted,
      'metadata': metadata,
    };
  }

  factory SavingGoal.fromJson(Map<String, dynamic> json) {
    return SavingGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetAmount: json['target_amount'] as double,
      createdAt: DateTime.parse(json['created_at'] as String),
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'] as String) 
          : null,
      category: json['category'] as String? ?? 'Geral',
      icon: json['icon'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}

/// Representa um registro de transação financeira
class TransactionRecord {
  final String id;
  final DateTime timestamp;
  final double amount;
  final TransactionType type;
  final String? category;
  final String? description;
  final String? goalId; // Se associado a uma meta específica
  final Map<String, dynamic> metadata;

  const TransactionRecord({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.type,
    this.category,
    this.description,
    this.goalId,
    this.metadata = const {},
  });

  /// Verifica se é depósito
  bool get isDeposit => type == TransactionType.deposit;

  /// Verifica se é saque
  bool get isWithdrawal => type == TransactionType.withdrawal;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'type': type.toString(),
      'category': category,
      'description': description,
      'goal_id': goalId,
      'metadata': metadata,
    };
  }

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      amount: json['amount'] as double,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.deposit,
      ),
      category: json['category'] as String?,
      description: json['description'] as String?,
      goalId: json['goal_id'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}

/// Tipos de transação
enum TransactionType {
  deposit,
  withdrawal,
}

/// Helper para TransactionType
extension TransactionTypeExtension on TransactionType {
  String get name {
    switch (this) {
      case TransactionType.deposit:
        return 'deposit';
      case TransactionType.withdrawal:
        return 'withdrawal';
    }
  }
}
