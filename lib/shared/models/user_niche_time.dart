class UserNicheTime {
  final String userId;
  final int nicheId;
  final int hour;
  final int minute;
  final String? phrase;

  UserNicheTime({
    required this.userId,
    required this.nicheId,
    required this.hour,
    required this.minute,
    this.phrase,
  });

  factory UserNicheTime.fromJson(Map<String, dynamic> json) {
    return UserNicheTime(
      userId: json['user_id'] as String,
      nicheId: json['niche_id'] as int,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      phrase: json['phrase'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'niche_id': nicheId,
      'hour': hour,
      'minute': minute,
      'phrase': phrase,
    };
  }
}
