import 'package:equatable/equatable.dart';

enum GamificationEventType {
  streakUpdated,
  achievementUnlocked,
  milestoneReached,
  levelUp,
  sessionCompleted,
  goalAchieved,
  relapseDetected,
  checkInCompleted,
}

class GamificationEvent extends Equatable {
  final String id;
  final String userId;
  final int nicheId;
  final GamificationEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final String? sessionId;

  const GamificationEvent({
    required this.id,
    required this.userId,
    required this.nicheId,
    required this.type,
    required this.timestamp,
    this.data,
    this.sessionId,
  });

  factory GamificationEvent.fromJson(Map<String, dynamic> json) {
    return GamificationEvent(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nicheId: json['niche_id'] as int,
      type: GamificationEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GamificationEventType.streakUpdated,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
      sessionId: json['session_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'niche_id': nicheId,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'session_id': sessionId,
    };
  }

  GamificationEvent copyWith({
    String? id,
    String? userId,
    int? nicheId,
    GamificationEventType? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    String? sessionId,
  }) {
    return GamificationEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nicheId: nicheId ?? this.nicheId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        nicheId,
        type,
        timestamp,
        data,
        sessionId,
      ];
}
