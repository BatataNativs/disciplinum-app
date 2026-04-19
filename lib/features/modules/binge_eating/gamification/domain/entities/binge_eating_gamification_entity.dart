import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_module_state.dart';

@Entity()
class BingeEatingGamificationEntity {
  @Id()
  int id = 0;
  
  String userId;
  List<String> earnedInsignias;
  List<String> earnedMedalhas;
  int consecutivePositiveDays;
  int disciplinumCount;
  DateTime lastUpdated;
  bool isModuleActive;

  BingeEatingGamificationEntity({
    required this.userId,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutivePositiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isModuleActive = true,
  });

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
      lastUpdated: state.updatedAt,
      isModuleActive: state.isModuleActive,
    );
  }

  BingeEatingModuleState toModuleState() {
    return BingeEatingModuleState(
      earnedInsignias: earnedInsignias,
      earnedMedalhas: earnedMedalhas,
      consecutivePositiveDays: consecutivePositiveDays,
      disciplinumCount: disciplinumCount,
      updatedAt: lastUpdated,
      isModuleActive: isModuleActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'earned_insignias': earnedInsignias,
      'earned_medalhas': earnedMedalhas,
      'consecutive_positive_days': consecutivePositiveDays,
      'disciplinum_count': disciplinumCount,
      'last_updated': lastUpdated.toIso8601String(),
      'is_module_active': isModuleActive,
    };
  }

  factory BingeEatingGamificationEntity.fromJson(Map<String, dynamic> json) {
    return BingeEatingGamificationEntity(
      userId: json['user_id'],
      earnedInsignias: List<String>.from(json['earned_insignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earned_medalhas'] ?? []),
      consecutivePositiveDays: json['consecutive_positive_days'] ?? 0,
      disciplinumCount: json['disciplinum_count'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated']),
      isModuleActive: json['is_module_active'] ?? json['is_active'] ?? true,
    );
  }

  factory BingeEatingGamificationEntity.defaultState(String userId) {
    return BingeEatingGamificationEntity(
      userId: userId,
      lastUpdated: DateTime.now(),
      isModuleActive: false,
    );
  }

  BingeEatingGamificationEntity resetProgress() {
    return BingeEatingGamificationEntity(
      userId: userId,
      earnedInsignias: isModuleActive ? ['madeira'] : [],
      earnedMedalhas: [],
      consecutivePositiveDays: 0,
      disciplinumCount: 0,
      lastUpdated: DateTime.now(),
      isModuleActive: isModuleActive,
    );
  }

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
        other.isModuleActive == isModuleActive;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        earnedInsignias.hashCode ^
        earnedMedalhas.hashCode ^
        consecutivePositiveDays.hashCode ^
        disciplinumCount.hashCode ^
        lastUpdated.hashCode ^
        isModuleActive.hashCode;
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
        'isModuleActive: $isModuleActive)';
  }
}
