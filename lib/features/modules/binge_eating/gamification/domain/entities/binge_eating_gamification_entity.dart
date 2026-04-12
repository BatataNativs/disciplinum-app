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
  bool isActive;

  BingeEatingGamificationEntity({
    required this.userId,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutivePositiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
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
      isActive: state.isActive,
    );
  }

  BingeEatingModuleState toModuleState() {
    return BingeEatingModuleState(
      earnedInsignias: earnedInsignias,
      earnedMedalhas: earnedMedalhas,
      consecutivePositiveDays: consecutivePositiveDays,
      disciplinumCount: disciplinumCount,
      updatedAt: lastUpdated,
      isActive: isActive,
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
      'is_active': isActive,
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
      isActive: json['is_active'] ?? true,
    );
  }

  factory BingeEatingGamificationEntity.defaultState(String userId) {
    return BingeEatingGamificationEntity(
      userId: userId,
      lastUpdated: DateTime.now(),
      isActive: false,
    );
  }

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
