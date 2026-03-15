import 'package:isar/isar.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

part 'gamification_progress.g.dart';

/// Entidade para armazenar progresso de gamificação no Isar
@collection
class GamificationProgress {
  /// ID único do registro
  Id id = Isar.autoIncrement;

  /// ID do usuário
  final String userId;

  /// ID do nicho/módulo
  final int nicheId;

  /// Pontos totais acumulados
  final int totalPoints;

  /// Pontos do dia atual
  final int dailyPoints;

  /// Data do último reset diário
  final DateTime lastDailyReset;

  /// Nível atual
  final int currentLevel;

  /// Experiência do nível atual
  final int currentLevelXP;

  /// Experiência necessária para o próximo nível
  final int nextLevelXP;

  /// Sequência atual de dias ativos
  final int currentStreak;

  /// Maior sequência já alcançada
  final int bestStreak;

  /// Data da última atividade
  final DateTime lastActivityDate;

  /// Conquistas desbloqueadas (JSON array)
  final String? unlockedAchievements;

  /// Medalha atual
  final String? currentMedal;

  /// Data de criação do registro
  final DateTime createdAt;

  /// Data da última atualização
  final DateTime updatedAt;

  /// Dados adicionais em formato JSON
  final String? additionalData;

  GamificationProgress({
    required this.userId,
    required this.nicheId,
    required this.totalPoints,
    required this.dailyPoints,
    required this.lastDailyReset,
    required this.currentLevel,
    required this.currentLevelXP,
    required this.nextLevelXP,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActivityDate,
    this.unlockedAchievements,
    this.currentMedal,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  /// Cria um GamificationProgress a partir do zero
  factory GamificationProgress.create({
    required String userId,
    required int nicheId,
  }) {
    final now = DateTime.now();
    return GamificationProgress(
      userId: userId,
      nicheId: nicheId,
      totalPoints: 0,
      dailyPoints: 0,
      lastDailyReset: now,
      currentLevel: 1,
      currentLevelXP: 0,
      nextLevelXP: 100,
      currentStreak: 0,
      bestStreak: 0,
      lastActivityDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Converte para NicheId enum
  @enumerated
  NicheId get niche => NicheId.values.firstWhere(
        (id) => id.id == nicheId,
        orElse: () => NicheId.reading,
      );

  /// Calcula o progresso para o próximo nível (0.0 a 1.0)
  double get levelProgress {
    if (nextLevelXP <= 0) return 0.0;
    return (currentLevelXP / nextLevelXP).clamp(0.0, 1.0);
  }

  /// Calcula o progresso em porcentagem (0 a 100)
  double get levelProgressPercentage => levelProgress * 100;

  /// Verifica se é um novo dia (para reset diário)
  bool get isNewDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReset = DateTime(
      lastDailyReset.year,
      lastDailyReset.month,
      lastDailyReset.day,
    );
    return today.isAfter(lastReset);
  }

  /// Verifica se a sequência foi quebrada
  bool get isStreakBroken {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final lastActivity = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );
    final yesterdayDate = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );
    
    return lastActivity.isBefore(yesterdayDate);
  }

  /// Cria uma cópia com valores atualizados
  GamificationProgress copyWith({
    String? userId,
    int? nicheId,
    int? totalPoints,
    int? dailyPoints,
    DateTime? lastDailyReset,
    int? currentLevel,
    int? currentLevelXP,
    int? nextLevelXP,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastActivityDate,
    String? unlockedAchievements,
    String? currentMedal,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? additionalData,
  }) {
    return GamificationProgress(
      userId: userId ?? this.userId,
      nicheId: nicheId ?? this.nicheId,
      totalPoints: totalPoints ?? this.totalPoints,
      dailyPoints: dailyPoints ?? this.dailyPoints,
      lastDailyReset: lastDailyReset ?? this.lastDailyReset,
      currentLevel: currentLevel ?? this.currentLevel,
      currentLevelXP: currentLevelXP ?? this.currentLevelXP,
      nextLevelXP: nextLevelXP ?? this.nextLevelXP,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      currentMedal: currentMedal ?? this.currentMedal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Adiciona pontos ao progresso
  GamificationProgress addPoints(int points) {
    final now = DateTime.now();
    final newTotalPoints = totalPoints + points;
    final newDailyPoints = isNewDay ? points : dailyPoints + points;
    
    // Implementar lógica de level up
    final newLevelXP = currentLevelXP + points;
    int newLevel = currentLevel;
    int newNextLevelXP = nextLevelXP;
    
    // Verificar se atingiu próximo nível
    if (newLevelXP >= nextLevelXP) {
      newLevel++;
      newNextLevelXP = _calculateXPForNextLevel(newLevel);
    }
    
    // Verificar medalhas
    String? newMedal = currentMedal;
    if (newLevel >= 10 && currentMedal == null) {
      newMedal = 'bronze';
    } else if (newLevel >= 25 && currentMedal == 'bronze') {
      newMedal = 'silver';
    } else if (newLevel >= 50 && currentMedal == 'silver') {
      newMedal = 'gold';
    } else if (newLevel >= 100 && currentMedal == 'gold') {
      newMedal = 'diamond';
    }
    
    return copyWith(
      totalPoints: newTotalPoints,
      dailyPoints: newDailyPoints,
      lastDailyReset: isNewDay ? now : lastDailyReset,
      currentLevel: newLevel,
      currentLevelXP: newLevelXP,
      nextLevelXP: newNextLevelXP,
      currentMedal: newMedal,
      lastActivityDate: now,
      updatedAt: now,
    );
  }

  /// Calcula XP necessário para o próximo nível
  int _calculateXPForNextLevel(int level) {
    // Fórmula: XP = 100 * (level ^ 1.5)
    return (100 * (level * 1.5)).round();
  }

  /// Verifica se pode fazer level up
  bool canLevelUp(int pointsToAdd) {
    final newXP = currentLevelXP + pointsToAdd;
    return newXP >= nextLevelXP;
  }

  /// Obtém progresso para o próximo nível
  double getProgressToNextLevel() {
    return currentLevelXP / nextLevelXP;
  }

  /// Atualiza a sequência de dias
  GamificationProgress updateStreak() {
    final now = DateTime.now();
    final newStreak = isStreakBroken ? 1 : currentStreak + 1;
    final newBestStreak = newStreak > bestStreak ? newStreak : bestStreak;
    
    return copyWith(
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      lastActivityDate: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'GamificationProgress('
        'id: $id, '
        'userId: $userId, '
        'nicheId: $nicheId, '
        'totalPoints: $totalPoints, '
        'dailyPoints: $dailyPoints, '
        'lastDailyReset: $lastDailyReset, '
        'currentLevel: $currentLevel, '
        'currentLevelXP: $currentLevelXP, '
        'nextLevelXP: $nextLevelXP, '
        'currentStreak: $currentStreak, '
        'bestStreak: $bestStreak, '
        'lastActivityDate: $lastActivityDate, '
        'unlockedAchievements: $unlockedAchievements, '
        'currentMedal: $currentMedal, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GamificationProgress &&
        other.userId == userId &&
        other.nicheId == nicheId &&
        other.totalPoints == totalPoints &&
        other.dailyPoints == dailyPoints &&
        other.lastDailyReset == lastDailyReset &&
        other.currentLevel == currentLevel &&
        other.currentLevelXP == currentLevelXP &&
        other.nextLevelXP == nextLevelXP &&
        other.currentStreak == currentStreak &&
        other.bestStreak == bestStreak &&
        other.lastActivityDate == lastActivityDate &&
        other.unlockedAchievements == unlockedAchievements &&
        other.currentMedal == currentMedal &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.additionalData == additionalData;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        nicheId.hashCode ^
        totalPoints.hashCode ^
        dailyPoints.hashCode ^
        lastDailyReset.hashCode ^
        currentLevel.hashCode ^
        currentLevelXP.hashCode ^
        nextLevelXP.hashCode ^
        currentStreak.hashCode ^
        bestStreak.hashCode ^
        lastActivityDate.hashCode ^
        unlockedAchievements.hashCode ^
        currentMedal.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        additionalData.hashCode;
  }
}
