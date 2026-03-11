class UserModuleStatus {
  final String userId;
  final int nicheId;
  final bool isActive;
  final int consecutiveDays;
  final int? focusPeriodsRespected; // NOVO: Períodos de foco respeitados
  final DateTime? lastUpdated;
  final String? maxMedal;
  final List<String> earnedInsignias;

  UserModuleStatus({
    required this.userId,
    required this.nicheId,
    required this.isActive,
    this.consecutiveDays = 0,
    this.focusPeriodsRespected, // NOVO
    this.lastUpdated,
    this.maxMedal,
    this.earnedInsignias = const [],
  });

  factory UserModuleStatus.fromJson(Map<String, dynamic> json) {
    return UserModuleStatus(
      userId: json['user_id'] as String,
      nicheId: json['niche_id'] as int,
      isActive: json['is_active'] as bool? ?? false,
      consecutiveDays: json['consecutive_days'] as int? ?? 0,
      focusPeriodsRespected: json['focus_periods_respected'] as int?, // NOVO
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
      maxMedal: json['max_medal'] as String?,
      earnedInsignias: (json['earned_insignias'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'niche_id': nicheId,
      'is_active': isActive,
      'consecutive_days': consecutiveDays,
      if (focusPeriodsRespected != null) 'focus_periods_respected': focusPeriodsRespected, // NOVO
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
      if (maxMedal != null) 'max_medal': maxMedal,
      'earned_insignias': earnedInsignias,
    };
  }
}
