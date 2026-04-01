import 'package:equatable/equatable.dart';

/// Estado de gamificação do módulo Dieta
/// Contém progresso, conquistas e estatísticas do usuário
class DietModuleState extends Equatable {
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final int disciplinumCount;
  final DateTime lastUpdated;
  final bool isActive;

  const DietModuleState({
    required this.earnedInsignias,
    required this.earnedMedalhas,
    required this.consecutiveDays,
    required this.disciplinumCount,
    required this.lastUpdated,
    required this.isActive,
  });

  /// Cria uma cópia com alguns campos alterados
  DietModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return DietModuleState(
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
  factory DietModuleState.fromJson(Map<String, dynamic> json) {
    return DietModuleState(
      earnedInsignias: List<String>.from(json['earnedInsignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earnedMedalhas'] ?? []),
      consecutiveDays: json['consecutiveDays'] ?? 0,
      disciplinumCount: json['disciplinumCount'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? false,
    );
  }

  /// Cria um estado inicial
  factory DietModuleState.initial() {
    return DietModuleState(
      earnedInsignias: const [],
      earnedMedalhas: const [],
      consecutiveDays: 0,
      disciplinumCount: 0,
      lastUpdated: DateTime.now(),
      isActive: false,
    );
  }

  @override
  List<Object?> get props => [
        earnedInsignias,
        earnedMedalhas,
        consecutiveDays,
        disciplinumCount,
        lastUpdated,
        isActive,
      ];

  @override
  String toString() {
    return 'DietModuleState('
        'consecutiveDays: $consecutiveDays, '
        'disciplinumCount: $disciplinumCount, '
        'earnedInsignias: ${earnedInsignias.length}, '
        'earnedMedalhas: ${earnedMedalhas.length}, '
        'isActive: $isActive'
        ')';
  }
}
