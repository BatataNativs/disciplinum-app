import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';

/// Estado do módulo Procrastination implementando [ModuleStateContract]
///
/// Implementa o contrato base para o módulo de controle de procrastinação.
class ProcrastinationModuleState implements ModuleStateContract {
  @override
  final String moduleId = 'procrastination';

  @override
  final int schemaVersion = 1;

  @override
  final DateTime createdAt;

  @override
  DateTime updatedAt;

  // Campos específicos do módulo Procrastination
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveProductiveDays;
  final int disciplinumCount;
  final int totalTasksCompleted;
  final int totalFocusMinutes;
  final bool isActive;
  final String currentStageId;

  ProcrastinationModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveProductiveDays = 0,
    this.disciplinumCount = 0,
    this.totalTasksCompleted = 0,
    this.totalFocusMinutes = 0,
    this.isActive = false,
    this.currentStageId = 'bronze',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria cópia com valores atualizados
  ProcrastinationModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveProductiveDays,
    int? disciplinumCount,
    int? totalTasksCompleted,
    int? totalFocusMinutes,
    bool? isActive,
    String? currentStageId,
  }) {
    return ProcrastinationModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveProductiveDays: consecutiveProductiveDays ?? this.consecutiveProductiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
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
      ..setField('consecutive_productive_days', consecutiveProductiveDays)
      ..setField('disciplinum_count', disciplinumCount)
      ..setField('total_tasks_completed', totalTasksCompleted)
      ..setField('total_focus_minutes', totalFocusMinutes)
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
          fieldName: 'consecutive_productive_days',
          currentValue: consecutiveProductiveDays,
          goalValue: 30,
        ),
        BaseProgressMetric(
          fieldName: 'disciplinum_count',
          currentValue: disciplinumCount,
          goalValue: 5,
        ),
        BaseProgressMetric(
          fieldName: 'total_tasks_completed',
          currentValue: totalTasksCompleted,
          goalValue: 100,
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
  factory ProcrastinationModuleState.fromJson(Map<String, dynamic> json) {
    // Valida conformidade com contrato
    ContractComplianceValidator.assertValid(json, 'procrastination');

    return ProcrastinationModuleState(
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
      consecutiveProductiveDays: json['consecutive_productive_days'] as int? ?? 0,
      disciplinumCount: json['disciplinum_count'] as int? ?? 0,
      totalTasksCompleted: json['total_tasks_completed'] as int? ?? 0,
      totalFocusMinutes: json['total_focus_minutes'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
    );
  }
}
