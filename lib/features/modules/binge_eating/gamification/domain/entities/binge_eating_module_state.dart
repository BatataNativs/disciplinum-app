/// Estado de gamificação do módulo Binge Eating
class BingeEatingModuleState {
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutivePositiveDays;
  final int disciplinumCount;
  final DateTime lastUpdated;
  final bool isActive;

  const BingeEatingModuleState({
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutivePositiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  BingeEatingModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutivePositiveDays,
    int? disciplinumCount,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return BingeEatingModuleState(
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutivePositiveDays: consecutivePositiveDays ?? this.consecutivePositiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'consecutivePositiveDays': consecutivePositiveDays,
      'disciplinumCount': disciplinumCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory BingeEatingModuleState.fromJson(Map<String, dynamic> json) {
    return BingeEatingModuleState(
      earnedInsignias: List<String>.from(json['earnedInsignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earnedMedalhas'] ?? []),
      consecutivePositiveDays: json['consecutivePositiveDays'] ?? 0,
      disciplinumCount: json['disciplinumCount'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BingeEatingModuleState &&
        other.earnedInsignias.toString() == earnedInsignias.toString() &&
        other.earnedMedalhas.toString() == earnedMedalhas.toString() &&
        other.consecutivePositiveDays == consecutivePositiveDays &&
        other.disciplinumCount == disciplinumCount &&
        other.lastUpdated == lastUpdated &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return earnedInsignias.hashCode ^
        earnedMedalhas.hashCode ^
        consecutivePositiveDays.hashCode ^
        disciplinumCount.hashCode ^
        lastUpdated.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'BingeEatingModuleState('
        'earnedInsignias: $earnedInsignias, '
        'earnedMedalhas: $earnedMedalhas, '
        'consecutivePositiveDays: $consecutivePositiveDays, '
        'disciplinumCount: $disciplinumCount, '
        'lastUpdated: $lastUpdated, '
        'isActive: $isActive)';
  }
}
