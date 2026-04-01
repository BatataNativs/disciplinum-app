import 'package:isar/isar.dart';
import 'binge_eating_module_state.dart';

part 'binge_eating_gamification_entity.g.dart';

/// Entidade Isar para persistência do estado de gamificação do Binge Eating
@Collection()
class BingeEatingGamificationEntity {
  final Id id = Isar.autoIncrement;
  
  @Index()
  final String userId;
  
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutivePositiveDays;
  final int disciplinumCount;
  final DateTime lastUpdated;
  final bool isActive;

  const BingeEatingGamificationEntity({
    required this.userId,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutivePositiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  /// Converte de ModuleState para Entity
  factory BingeEatingGamificationEntity.fromModuleState(
    String userId,
    BingeEatingModuleState state,
  ) {
    return BingeEatingGamificationEntity(
      userId: userId,
      earnedInsignias: state.earnedInsignias,
      earnedMedalhas: state.earnedMedalhas,
      consecutivePositiveDays: state.consecutivePositiveDays,
      disciplinumCount: state.disciplinumCount,
      lastUpdated: state.lastUpdated,
      isActive: state.isActive,
    );
  }

  /// Converte de Entity para ModuleState
  BingeEatingModuleState toModuleState() {
    return BingeEatingModuleState(
      earnedInsignias: earnedInsignias,
      earnedMedalhas: earnedMedalhas,
      consecutivePositiveDays: consecutivePositiveDays,
      disciplinumCount: disciplinumCount,
      lastUpdated: lastUpdated,
      isActive: isActive,
    );
  }

  /// Converte para Map (para persistência)
  Map<String, dynamic> toModuleStateMap() {
    return toModuleState().toJson();
  }

  /// Converte para JSON (para Supabase)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'earned_insignias': earnedInsignias,
      'earned_medalhas': earnedMedalhas,
      'consecutive_positive_days': consecutivePositiveDays,
      'disciplinum_count': disciplinumCount,
      'last_updated': lastUpdated.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Cria a partir de JSON (do Supabase)
  factory BingeEatingGamificationEntity.fromJson(Map<String, dynamic> json) {
    return BingeEatingGamificationEntity(
      userId: json['user_id'],
      earnedInsignias: List<String>.from(json['earned_insignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earned_medalhas'] ?? []),
      consecutivePositiveDays: json['consecutive_positive_days'] ?? 0,
      disciplinumCount: json['disciplinum_count'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated']),
      isActive: json['is_active'] ?? true,
    );
  }

  /// Cria um estado padrão para novos usuários
  factory BingeEatingGamificationEntity.defaultState(String userId) {
    return BingeEatingGamificationEntity(
      userId: userId,
      lastUpdated: DateTime.now(),
      isActive: false, // Inativo até configurar
    );
  }

  /// Reseta o progresso (mantém apenas madeira se ativo)
  BingeEatingGamificationEntity resetProgress() {
    return BingeEatingGamificationEntity(
      userId: userId,
      earnedInsignias: isActive ? ['madeira'] : [],
      earnedMedalhas: [],
      consecutivePositiveDays: 0,
      disciplinumCount: 0,
      lastUpdated: DateTime.now(),
      isActive: isActive,
    );
  }

  /// Verifica se o estado está desatualizado (mais de 24 horas)
  bool get isStale {
    return DateTime.now().difference(lastUpdated).inHours > 24;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BingeEatingGamificationEntity &&
        other.userId == userId &&
        other.earnedInsignias.toString() == earnedInsignias.toString() &&
        other.earnedMedalhas.toString() == earnedMedalhas.toString() &&
        other.consecutivePositiveDays == consecutivePositiveDays &&
        other.disciplinumCount == disciplinumCount &&
        other.lastUpdated == lastUpdated &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        earnedInsignias.hashCode ^
        earnedMedalhas.hashCode ^
        consecutivePositiveDays.hashCode ^
        disciplinumCount.hashCode ^
        lastUpdated.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'BingeEatingGamificationEntity('
        'userId: $userId, '
        'earnedInsignias: $earnedInsignias, '
        'earnedMedalhas: $earnedMedalhas, '
        'consecutivePositiveDays: $consecutivePositiveDays, '
        'disciplinumCount: $disciplinumCount, '
        'lastUpdated: $lastUpdated, '
        'isActive: $isActive)';
  }
}
