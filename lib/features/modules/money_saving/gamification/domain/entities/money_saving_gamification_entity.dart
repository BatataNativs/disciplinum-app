import 'package:objectbox/objectbox.dart';
import 'dart:convert';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';

@Entity()
class MoneySavingGamificationEntity {
  @Id()
  int id = 0;

  String userId = '';
  String earnedInsignias = '[]';
  String earnedMedalhas = '[]';
  int consecutiveDays = 0;
  int disciplinumCount = 0;
  double totalSavedAmount = 0.0;
  int bestStreak = 0;
  DateTime? lastSavingDate;
  DateTime? startDate;
  DateTime lastUpdated = DateTime.now();
  bool isActive = false;
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
