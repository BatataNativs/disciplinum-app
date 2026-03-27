import 'package:isar/isar.dart';
import 'dart:convert';

part 'diet_gamification_entity.g.dart';

/// Entidade Isar para gamificação do módulo Dieta
/// Armazena estado completo de gamificação com persistência local
@collection
class DietGamificationEntity {
  /// ID único do registro
  Id id = Isar.autoIncrement;

  /// ID do usuário dono deste estado
  @Index()
  String userId = '';

  /// Lista de insígnias conquistadas (JSON)
  String earnedInsignias = '[]';

  /// Lista de medalhas conquistadas (JSON)
  String earnedMedalhas = '[]';

  /// Dias consecutivos de acompanhamento
  int consecutiveDays = 0;

  /// Contador de insígnias Disciplinum conquistadas
  int disciplinumCount = 0;

  /// Data da última atualização
  DateTime lastUpdated = DateTime.now();

  /// Indica se o módulo está ativo
  bool isActive = false;

  /// Data de criação do registro
  DateTime createdAt = DateTime.now();

  DietGamificationEntity({
    required this.userId,
    this.earnedInsignias = '[]',
    this.earnedMedalhas = '[]',
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = false,
  }) : createdAt = DateTime.now();

  /// Converte de DietModuleState para Isar entity
  factory DietGamificationEntity.fromModuleState(
    String userId, 
    Map<String, dynamic> moduleState
  ) {
    return DietGamificationEntity(
      userId: userId,
      earnedInsignias: jsonEncode(moduleState['earnedInsignias'] ?? []),
      earnedMedalhas: jsonEncode(moduleState['earnedMedalhas'] ?? []),
      consecutiveDays: moduleState['consecutiveDays'] ?? 0,
      disciplinumCount: moduleState['disciplinumCount'] ?? 0,
      lastUpdated: DateTime.parse(moduleState['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isActive: moduleState['isActive'] ?? false,
    );
  }

  /// Converte para Map (compatível com DietModuleState)
  Map<String, dynamic> toModuleStateMap() {
    return {
      'earnedInsignias': jsonDecode(earnedInsignias),
      'earnedMedalhas': jsonDecode(earnedMedalhas),
      'consecutiveDays': consecutiveDays,
      'disciplinumCount': disciplinumCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria uma cópia com alguns campos alterados
  DietGamificationEntity copyWith({
    String? earnedInsignias,
    String? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return DietGamificationEntity(
      userId: userId,
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'DietGamificationEntity('
        'userId: $userId, '
        'consecutiveDays: $consecutiveDays, '
        'disciplinumCount: $disciplinumCount, '
        'earnedInsignias: $earnedInsignias, '
        'earnedMedalhas: $earnedMedalhas, '
        'isActive: $isActive'
        ')';
  }
}
