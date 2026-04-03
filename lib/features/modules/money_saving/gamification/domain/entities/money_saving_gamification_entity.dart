import 'package:isar/isar.dart';
import 'dart:convert';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';

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
  factory MoneySavingGamificationEntity.fromModuleState(MoneySavingModuleState moduleState) {
    return MoneySavingGamificationEntity(
      userId: '', // Definido pelo repositório
      earnedInsignias: jsonEncode(moduleState.earnedInsignias),
      earnedMedalhas: jsonEncode(moduleState.earnedMedalhas),
      consecutiveDays: moduleState.consecutiveDays,
      disciplinumCount: moduleState.disciplinumCount,
      totalSavedAmount: moduleState.totalSavedAmount,
      bestStreak: moduleState.bestStreak,
      lastSavingDate: moduleState.lastSavingDate,
      startDate: moduleState.startDate,
      lastUpdated: moduleState.updatedAt,
      isActive: moduleState.isActive,
    );
  }

  /// Converte para MoneySavingModuleState
  MoneySavingModuleState toModuleState() {
    return MoneySavingModuleState(
      earnedInsignias: jsonDecode(earnedInsignias).cast<String>(),
      earnedMedalhas: jsonDecode(earnedMedalhas).cast<String>(),
      consecutiveDays: consecutiveDays,
      disciplinumCount: disciplinumCount,
      totalSavedAmount: totalSavedAmount,
      bestStreak: bestStreak,
      lastSavingDate: lastSavingDate,
      startDate: startDate,
      updatedAt: lastUpdated,
      isActive: isActive,
    );
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
