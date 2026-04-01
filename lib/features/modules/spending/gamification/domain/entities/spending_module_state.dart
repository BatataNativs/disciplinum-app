/// Estado de gamificação do módulo Spending
/// Contém progresso, conquistas e estatísticas do usuário
class SpendingModuleState {
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveMonths;
  final int disciplinumCount;
  final DateTime lastUpdated;
  final bool isActive;

  const SpendingModuleState({
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveMonths = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  /// Cria uma cópia com alguns campos alterados
  SpendingModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveMonths,
    int? disciplinumCount,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return SpendingModuleState(
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveMonths: consecutiveMonths ?? this.consecutiveMonths,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'consecutiveMonths': consecutiveMonths,
      'disciplinumCount': disciplinumCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria a partir de JSON
  factory SpendingModuleState.fromJson(Map<String, dynamic> json) {
    return SpendingModuleState(
      earnedInsignias: List<String>.from(json['earnedInsignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earnedMedalhas'] ?? []),
      consecutiveMonths: json['consecutiveMonths'] ?? 0,
      disciplinumCount: json['disciplinumCount'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? false,
    );
  }

  /// Cria um estado inicial
  factory SpendingModuleState.initial() {
    return SpendingModuleState(
      earnedInsignias: const [],
      earnedMedalhas: const [],
      consecutiveMonths: 0,
      disciplinumCount: 0,
      lastUpdated: DateTime.now(),
      isActive: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpendingModuleState &&
        other.earnedInsignias.toString() == earnedInsignias.toString() &&
        other.earnedMedalhas.toString() == earnedMedalhas.toString() &&
        other.consecutiveMonths == consecutiveMonths &&
        other.disciplinumCount == disciplinumCount &&
        other.lastUpdated == lastUpdated &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return earnedInsignias.hashCode ^
        earnedMedalhas.hashCode ^
        consecutiveMonths.hashCode ^
        disciplinumCount.hashCode ^
        lastUpdated.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'SpendingModuleState('
        'consecutiveMonths: $consecutiveMonths, '
        'disciplinumCount: $disciplinumCount, '
        'earnedInsignias: ${earnedInsignias.length}, '
        'earnedMedalhas: ${earnedMedalhas.length}, '
        'isActive: $isActive'
        ')';
  }
}
