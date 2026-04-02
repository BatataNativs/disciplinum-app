import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';

/// Estado do módulo Money Saving implementando [ModuleStateContract]
///
/// Implementa o contrato base para o módulo de economia.
class MoneySavingModuleState implements ModuleStateContract {
  @override
  final String moduleId = 'money_saving';

  @override
  final int schemaVersion = 1;

  @override
  final DateTime createdAt;

  @override
  DateTime updatedAt;

  // Campos específicos do módulo Money Saving
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final int disciplinumCount;
  final double totalSavedAmount;
  final int bestStreak;
  final DateTime? lastSavingDate;
  final DateTime? startDate;
  final bool isActive;
  final String currentStageId;

  MoneySavingModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    this.totalSavedAmount = 0.0,
    this.bestStreak = 0,
    this.lastSavingDate,
    this.startDate,
    this.isActive = false,
    this.currentStageId = 'bronze',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria cópia com valores atualizados
  MoneySavingModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    double? totalSavedAmount,
    int? bestStreak,
    DateTime? lastSavingDate,
    DateTime? startDate,
    bool? isActive,
    String? currentStageId,
  }) {
    return MoneySavingModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      totalSavedAmount: totalSavedAmount ?? this.totalSavedAmount,
      bestStreak: bestStreak ?? this.bestStreak,
      lastSavingDate: lastSavingDate ?? this.lastSavingDate,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      currentStageId: currentStageId ?? this.currentStageId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final builder = ModuleStateJsonBuilder(
      moduleId: moduleId,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    )
      ..setField('earned_insignias', earnedInsignias)
      ..setField('earned_medalhas', earnedMedalhas)
      ..setField('consecutive_days', consecutiveDays)
      ..setField('disciplinum_count', disciplinumCount)
      ..setField('total_saved_amount', totalSavedAmount)
      ..setField('best_streak', bestStreak)
      ..setField('last_saving_date', lastSavingDate?.toIso8601String())
      ..setField('start_date', startDate?.toIso8601String())
      ..setField('is_active', isActive)
      ..setStage(currentStage)
      ..setProgressMetric(progressMetrics[0])
      ..setProgressMetric(progressMetrics[1])
      ..setProgressMetric(progressMetrics[2]);

    return builder.build();
  }

  @override
  Map<String, dynamic> toMap() => toJson();

  @override
  List<ProgressMetricContract> get progressMetrics => [
        BaseProgressMetric(
          fieldName: 'consecutive_days',
          currentValue: consecutiveDays,
          goalValue: 30,
        ),
        BaseProgressMetric(
          fieldName: 'disciplinum_count',
          currentValue: disciplinumCount,
          goalValue: 5,
        ),
        BaseProgressMetric(
          fieldName: 'total_saved_amount',
          currentValue: totalSavedAmount,
          goalValue: 1000.0,
        ),
      ];

  @override
  StageContract get currentStage {
    final stages = BaseStage.defaultStages;
    return stages.firstWhere(
      (s) => s.stageId == currentStageId,
      orElse: () => BaseStage.bronze,
    );
  }

  /// Factory para criar a partir de JSON (ex: do Supabase)
  factory MoneySavingModuleState.fromJson(Map<String, dynamic> json) {
    // Valida conformidade com contrato
    ContractComplianceValidator.assertValid(json, 'money_saving');

    return MoneySavingModuleState(
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      earnedInsignias:
          (json['earned_insignias'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      earnedMedalhas:
          (json['earned_medalhas'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      consecutiveDays: json['consecutive_days'] as int? ?? 0,
      disciplinumCount: json['disciplinum_count'] as int? ?? 0,
      totalSavedAmount: (json['total_saved_amount'] as num?)?.toDouble() ?? 0.0,
      bestStreak: json['best_streak'] as int? ?? 0,
      lastSavingDate: json['last_saving_date'] != null
          ? DateTime.parse(json['last_saving_date'] as String)
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? false,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
    );
  }
}
