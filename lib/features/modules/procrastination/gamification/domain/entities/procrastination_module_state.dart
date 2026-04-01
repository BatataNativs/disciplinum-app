/// Estado de gamificação do módulo Procrastination
/// Contém progresso, conquistas e estatísticas do usuário
class ProcrastinationModuleState {
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final int disciplinumCount;
  final DateTime lastUpdated;
  final bool isActive;

  const ProcrastinationModuleState({
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  /// Cria uma cópia com alguns campos alterados
  ProcrastinationModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return ProcrastinationModuleState(
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
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
      'consecutiveDays': consecutiveDays,
      'disciplinumCount': disciplinumCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria a partir de JSON
  factory ProcrastinationModuleState.fromJson(Map<String, dynamic> json) {
    return ProcrastinationModuleState(
      earnedInsignias: List<String>.from(json['earnedInsignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earnedMedalhas'] ?? []),
      consecutiveDays: json['consecutiveDays'] ?? 0,
      disciplinumCount: json['disciplinumCount'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? false,
    );
  }

  /// Cria um estado inicial
  factory ProcrastinationModuleState.initial() {
    return ProcrastinationModuleState(
      earnedInsignias: const [],
      earnedMedalhas: const [],
      consecutiveDays: 0,
      disciplinumCount: 0,
      lastUpdated: DateTime.now(),
      isActive: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProcrastinationModuleState &&
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
    return 'ProcrastinationModuleState('
        'consecutiveDays: $consecutiveDays, '
        'disciplinumCount: $disciplinumCount, '
        'earnedInsignias: ${earnedInsignias.length}, '
        'earnedMedalhas: ${earnedMedalhas.length}, '
        'isActive: $isActive'
        ')';
  }
}
