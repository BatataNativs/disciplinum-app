import 'package:equatable/equatable.dart';

class UserAchievement extends Equatable {
  final String id;
  final String userId;
  final int nicheId;
  final String achievementType; // 'medal', 'insignia', 'milestone'
  final String achievementId;
  final String title;
  final String description;
  final DateTime earnedAt;
  final Map<String, dynamic>? metadata;
  final bool isDisplayed;

  const UserAchievement({
    required this.id,
    required this.userId,
    required this.nicheId,
    required this.achievementType,
    required this.achievementId,
    required this.title,
    required this.description,
    required this.earnedAt,
    this.metadata,
    this.isDisplayed = true,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nicheId: json['niche_id'] as int,
      achievementType: json['achievement_type'] as String,
      achievementId: json['achievement_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isDisplayed: json['is_displayed'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'niche_id': nicheId,
      'achievement_type': achievementType,
      'achievement_id': achievementId,
      'title': title,
      'description': description,
      'earned_at': earnedAt.toIso8601String(),
      'metadata': metadata,
      'is_displayed': isDisplayed,
    };
  }

  UserAchievement copyWith({
    String? id,
    String? userId,
    int? nicheId,
    String? achievementType,
    String? achievementId,
    String? title,
    String? description,
    DateTime? earnedAt,
    Map<String, dynamic>? metadata,
    bool? isDisplayed,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nicheId: nicheId ?? this.nicheId,
      achievementType: achievementType ?? this.achievementType,
      achievementId: achievementId ?? this.achievementId,
      title: title ?? this.title,
      description: description ?? this.description,
      earnedAt: earnedAt ?? this.earnedAt,
      metadata: metadata ?? this.metadata,
      isDisplayed: isDisplayed ?? this.isDisplayed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        nicheId,
        achievementType,
        achievementId,
        title,
        description,
        earnedAt,
        metadata,
        isDisplayed,
      ];
}
