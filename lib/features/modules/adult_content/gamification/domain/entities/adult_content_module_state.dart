/// Estado de gamificação do módulo Adult Content
class AdultContentModuleState {
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final int disciplinumCount;
  final DateTime lastUpdated;
  final bool isActive;

  const AdultContentModuleState({
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  AdultContentModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return AdultContentModuleState(
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'consecutiveDays': consecutiveDays,
      'disciplinumCount': disciplinumCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory AdultContentModuleState.initial() {
    return AdultContentModuleState(
      lastUpdated: DateTime.now(),
    );
  }

  factory AdultContentModuleState.fromJson(Map<String, dynamic> json) {
    return AdultContentModuleState(
      earnedInsignias: List<String>.from(json['earnedInsignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earnedMedalhas'] ?? []),
      consecutiveDays: json['consecutiveDays'] ?? 0,
      disciplinumCount: json['disciplinumCount'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdultContentModuleState &&
        other.earnedInsignias.toString() == earnedInsignias.toString() &&
        other.earnedMedalhas.toString() == earnedMedalhas.toString() &&
        other.consecutiveDays == consecutiveDays &&
        other.disciplinumCount == disciplinumCount &&
        other.lastUpdated == lastUpdated &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return earnedInsignias.hashCode ^
        earnedMedalhas.hashCode ^
        consecutiveDays.hashCode ^
        disciplinumCount.hashCode ^
        lastUpdated.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'AdultContentModuleState('
        'earnedInsignias: $earnedInsignias, '
        'earnedMedalhas: $earnedMedalhas, '
        'consecutiveDays: $consecutiveDays, '
        'disciplinumCount: $disciplinumCount, '
        'lastUpdated: $lastUpdated, '
        'isActive: $isActive)';
  }
}
