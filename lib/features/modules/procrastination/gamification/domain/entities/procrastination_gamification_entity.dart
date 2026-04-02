import 'package:isar/isar.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_module_state.dart';

part 'procrastination_gamification_entity.g.dart';

/// Entidade Isar para persistência do estado de gamificação do Procrastination
@Collection()
class ProcrastinationGamificationEntity {
  final Id id = Isar.autoIncrement;
  
  @Index()
  final String userId;
  
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final int disciplinumCount;
  final DateTime lastUpdated;
  final bool isActive;

  const ProcrastinationGamificationEntity({
    required this.userId,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  /// Converte de ModuleState para Entity
  factory ProcrastinationGamificationEntity.fromModuleState(
    String userId,
    ProcrastinationModuleState state,
  ) {
    return ProcrastinationGamificationEntity(
      userId: userId,
      earnedInsignias: state.earnedInsignias,
      earnedMedalhas: state.earnedMedalhas,
      consecutiveDays: state.consecutiveProductiveDays,
      disciplinumCount: state.disciplinumCount,
      lastUpdated: state.updatedAt,
      isActive: state.isActive,
    );
  }

  /// Converte de Entity para ModuleState
  ProcrastinationModuleState toModuleState() {
    return ProcrastinationModuleState(
      earnedInsignias: earnedInsignias,
      earnedMedalhas: earnedMedalhas,
      consecutiveProductiveDays: consecutiveDays,
      disciplinumCount: disciplinumCount,
      updatedAt: lastUpdated,
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
      'consecutive_days': consecutiveDays,
      'disciplinum_count': disciplinumCount,
      'last_updated': lastUpdated.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Cria a partir de JSON (do Supabase)
  factory ProcrastinationGamificationEntity.fromJson(Map<String, dynamic> json) {
    return ProcrastinationGamificationEntity(
      userId: json['user_id'],
      earnedInsignias: List<String>.from(json['earned_insignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earned_medalhas'] ?? []),
      consecutiveDays: json['consecutive_days'] ?? 0,
      disciplinumCount: json['disciplinum_count'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated']),
      isActive: json['is_active'] ?? true,
    );
  }
}
