import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_module_state.dart';

@Entity()
class AdultContentGamificationEntity {
  @Id()
  int id = 0;
  
  String userId;
  List<String> earnedInsignias;
  List<String> earnedMedalhas;
  int consecutiveDays;
  int disciplinumCount;
  DateTime lastUpdated;
  bool isModuleActive;

  AdultContentGamificationEntity({
    required this.userId,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isModuleActive = true,
  });

  factory AdultContentGamificationEntity.fromModuleState(
    String userId,
    AdultContentModuleState state,
  ) {
    return AdultContentGamificationEntity(
      userId: userId,
      earnedInsignias: state.earnedInsignias,
      earnedMedalhas: state.earnedMedalhas,
      consecutiveDays: state.consecutiveDays,
      disciplinumCount: state.disciplinumCount,
      lastUpdated: state.updatedAt,
      isModuleActive: state.isModuleActive,
    );
  }

  AdultContentModuleState toModuleState() {
    return AdultContentModuleState(
      earnedInsignias: earnedInsignias,
      earnedMedalhas: earnedMedalhas,
      consecutiveDays: consecutiveDays,
      disciplinumCount: disciplinumCount,
      updatedAt: lastUpdated,
      isModuleActive: isModuleActive,
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
      'consecutive_days': consecutiveDays,
      'disciplinum_count': disciplinumCount,
      'last_updated': lastUpdated.toIso8601String(),
      'is_module_active': isModuleActive,
    };
  }

  factory AdultContentGamificationEntity.fromJson(Map<String, dynamic> json) {
    return AdultContentGamificationEntity(
      userId: json['user_id'],
      earnedInsignias: List<String>.from(json['earned_insignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earned_medalhas'] ?? []),
      consecutiveDays: json['consecutive_days'] ?? 0,
      disciplinumCount: json['disciplinum_count'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated']),
      isModuleActive: json['is_module_active'] ?? json['is_active'] ?? true,
    );
  }
}
