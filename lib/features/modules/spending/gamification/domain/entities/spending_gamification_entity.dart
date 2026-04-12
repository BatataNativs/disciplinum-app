import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_module_state.dart';

@Entity()
class SpendingGamificationEntity {
  @Id()
  int id = 0;
  
  String userId;
  List<String> earnedInsignias;
  List<String> earnedMedalhas;
  int consecutiveMonths;
  int disciplinumCount;
  DateTime lastUpdated;
  bool isActive;

  SpendingGamificationEntity({
    required this.userId,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveMonths = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

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

  Map<String, dynamic> toModuleStateMap() {
    return toModuleState().toJson();
  }

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
