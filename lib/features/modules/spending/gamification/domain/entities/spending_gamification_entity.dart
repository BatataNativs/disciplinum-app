import 'package:isar/isar.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_module_state.dart';

part 'spending_gamification_entity.g.dart';

/// Entidade Isar para persistência do estado de gamificação do Spending
@Collection()
class SpendingGamificationEntity {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  final String userId;
  
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveMonths;
  final int disciplinumCount;
  final DateTime lastUpdated;
  final bool isActive;

  SpendingGamificationEntity({
    required this.userId,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveMonths = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  /// Converte de ModuleState para Entity
  factory SpendingGamificationEntity.fromModuleState(
    String userId,
    SpendingModuleState state,
  ) {
    return SpendingGamificationEntity(
      userId: userId,
      earnedInsignias: state.earnedInsignias,
      earnedMedalhas: state.earnedMedalhas,
      consecutiveMonths: state.consecutiveMonths,
      disciplinumCount: state.disciplinumCount,
      lastUpdated: state.updatedAt,
      isActive: state.isActive,
    );
  }

  /// Converte de Entity para ModuleState
  SpendingModuleState toModuleState() {
    return SpendingModuleState(
      earnedInsignias: earnedInsignias,
      earnedMedalhas: earnedMedalhas,
      consecutiveMonths: consecutiveMonths,
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
      'consecutive_months': consecutiveMonths,
      'disciplinum_count': disciplinumCount,
      'last_updated': lastUpdated.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Cria a partir de JSON (do Supabase)
  factory SpendingGamificationEntity.fromJson(Map<String, dynamic> json) {
    return SpendingGamificationEntity(
      userId: json['user_id'],
      earnedInsignias: List<String>.from(json['earned_insignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earned_medalhas'] ?? []),
      consecutiveMonths: json['consecutive_months'] ?? 0,
      disciplinumCount: json['disciplinum_count'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated']),
      isActive: json['is_active'] ?? true,
    );
  }
}
