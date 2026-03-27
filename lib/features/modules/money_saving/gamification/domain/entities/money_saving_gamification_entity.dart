import 'package:isar/isar.dart';
import 'dart:convert';

part 'money_saving_gamification_entity.g.dart';

/// Entidade Isar para gamificação do módulo Money Saving Challenge
/// Armazena estado completo de gamificação com persistência local
@collection
class MoneySavingGamificationEntity {
  /// ID único do registro
  Id id = Isar.autoIncrement;

  /// ID do usuário dono deste estado
  @Index()
  String userId = '';

  /// Lista de insígnias conquistadas (JSON)
  String earnedInsignias = '[]';

  /// Lista de medalhas conquistadas (JSON)
  String earnedMedalhas = '[]';

  /// Dias consecutivos economizando
  int consecutiveDays = 0;

  /// Contador de insígnias Disciplinum conquistadas
  int disciplinumCount = 0;

  /// Valor total acumulado
  double totalSavedAmount = 0.0;

  /// Maior sequência já alcançada
  int bestStreak = 0;

  /// Data da última economia
  DateTime? lastSavingDate;

  /// Data de início do desafio
  DateTime? startDate;

  /// Data da última atualização
  DateTime lastUpdated = DateTime.now();

  /// Indica se o módulo está ativo
  bool isActive = false;

  /// Data de criação do registro
  DateTime createdAt = DateTime.now();

  MoneySavingGamificationEntity({
    required this.userId,
    this.earnedInsignias = '[]',
    this.earnedMedalhas = '[]',
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    this.totalSavedAmount = 0.0,
    this.bestStreak = 0,
    this.lastSavingDate,
    this.startDate,
    required this.lastUpdated,
    this.isActive = false,
  }) : createdAt = DateTime.now();

  /// Converte de MoneySavingModuleState para Isar entity
  factory MoneySavingGamificationEntity.fromModuleState(
    String userId, 
    Map<String, dynamic> moduleState
  ) {
    return MoneySavingGamificationEntity(
      userId: userId,
      earnedInsignias: jsonEncode(moduleState['earnedInsignias'] ?? []),
      earnedMedalhas: jsonEncode(moduleState['earnedMedalhas'] ?? []),
      consecutiveDays: moduleState['consecutiveDays'] ?? 0,
      disciplinumCount: moduleState['disciplinumCount'] ?? 0,
      totalSavedAmount: (moduleState['totalSavedAmount'] ?? 0.0).toDouble(),
      bestStreak: moduleState['bestStreak'] ?? 0,
      lastSavingDate: moduleState['lastSavingDate'] != null 
          ? DateTime.parse(moduleState['lastSavingDate'])
          : null,
      startDate: moduleState['startDate'] != null 
          ? DateTime.parse(moduleState['startDate'])
          : null,
      lastUpdated: DateTime.parse(moduleState['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isActive: moduleState['isActive'] ?? false,
    );
  }

  /// Converte para Map (compatível com MoneySavingModuleState)
  Map<String, dynamic> toModuleStateMap() {
    return {
      'earnedInsignias': jsonDecode(earnedInsignias),
      'earnedMedalhas': jsonDecode(earnedMedalhas),
      'consecutiveDays': consecutiveDays,
      'disciplinumCount': disciplinumCount,
      'totalSavedAmount': totalSavedAmount,
      'bestStreak': bestStreak,
      'lastSavingDate': lastSavingDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria uma cópia com alguns campos alterados
  MoneySavingGamificationEntity copyWith({
    String? earnedInsignias,
    String? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    double? totalSavedAmount,
    int? bestStreak,
    DateTime? lastSavingDate,
    DateTime? startDate,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return MoneySavingGamificationEntity(
      userId: userId,
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      totalSavedAmount: totalSavedAmount ?? this.totalSavedAmount,
      bestStreak: bestStreak ?? this.bestStreak,
      lastSavingDate: lastSavingDate ?? this.lastSavingDate,
      startDate: startDate ?? this.startDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'MoneySavingGamificationEntity('
        'userId: $userId, '
        'consecutiveDays: $consecutiveDays, '
        'disciplinumCount: $disciplinumCount, '
        'totalSavedAmount: $totalSavedAmount, '
        'bestStreak: $bestStreak, '
        'earnedInsignias: $earnedInsignias, '
        'earnedMedalhas: $earnedMedalhas, '
        'isActive: $isActive'
        ')';
  }
}
