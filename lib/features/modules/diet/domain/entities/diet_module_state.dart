import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';

/// Estado do módulo Diet implementando [ModuleStateContract]
///
/// Implementa o contrato base para o módulo de controle de dieta.
class DietModuleState implements ModuleStateContract {
  @override
  final String moduleId = 'diet';

  @override
  final int schemaVersion = 1;

  @override
  final DateTime createdAt;

  @override
  DateTime updatedAt;

  // Campos específicos do módulo Diet
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final int disciplinumCount;
  final bool isActive;
  final String currentStageId;

  DietModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    this.isActive = false,
    this.currentStageId = 'bronze',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria cópia com valores atualizados
  DietModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    bool? isActive,
    String? currentStageId,
  }) {
    return DietModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
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
      ..setField('is_active', isActive)
      ..setStage(currentStage)
      ..setProgressMetric(progressMetrics[0])
      ..setProgressMetric(progressMetrics[1]);

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
          fieldName: 'total_meals_logged',
          currentValue: consecutiveDays,
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
  factory DietModuleState.fromJson(Map<String, dynamic> json) {
    // Valida conformidade com contrato
    ContractComplianceValidator.assertValid(json, 'diet');

    return DietModuleState(
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
      isActive: json['is_active'] as bool? ?? false,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
    );
  }
}
