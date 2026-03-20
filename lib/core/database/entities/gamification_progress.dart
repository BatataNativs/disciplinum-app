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

  /// Verifica se é um novo dia (para reset diário)
  bool get isNewDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );
    return today.isAfter(lastActivity);
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

  /// Atualiza a medalha atual
  GamificationProgress updateMedal(String newMedal) {
    return copyWith(
      currentMedal: newMedal,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'GamificationProgress('
        'id: $id, '
        'userId: $userId, '
        'nicheId: $nicheId, '
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
