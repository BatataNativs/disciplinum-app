import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';

/// Estado do módulo Focus implementando [ModuleStateContract]
/// 
/// Exemplo de como um módulo deve implementar o contrato base.
/// Este padrão deve ser seguido por todos os 9 módulos.
class FocusModuleState implements ModuleStateContract {
  @override
  final String moduleId = 'focus';

  @override
  final int schemaVersion = 1;

  @override
  final DateTime createdAt;

  @override
  DateTime updatedAt;

  // Campos específicos do módulo Focus
  final int sessionsCompleted;
  final int totalFocusMinutes;
  final int currentStreakDays;
  final int longestStreakDays;
  final String currentStageId;
  final List<String> unlockedAchievements;

  FocusModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sessionsCompleted = 0,
    this.totalFocusMinutes = 0,
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.currentStageId = 'bronze',
    this.unlockedAchievements = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria cópia com valores atualizados
  FocusModuleState copyWith({
    int? sessionsCompleted,
    int? totalFocusMinutes,
    int? currentStreakDays,
    int? longestStreakDays,
    String? currentStageId,
    List<String>? unlockedAchievements,
  }) {
    return FocusModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      currentStageId: currentStageId ?? this.currentStageId,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
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
      ..setField('sessions_completed', sessionsCompleted)
      ..setField('total_focus_minutes', totalFocusMinutes)
      ..setField('current_streak_days', currentStreakDays)
      ..setField('longest_streak_days', longestStreakDays)
      ..setField('unlocked_achievements', unlockedAchievements)
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
          fieldName: 'sessions_completed',
          currentValue: sessionsCompleted,
          goalValue: 100,
        ),
        BaseProgressMetric(
          fieldName: 'total_focus_minutes',
          currentValue: totalFocusMinutes,
          goalValue: 1000,
        ),
        BaseProgressMetric(
          fieldName: 'current_streak_days',
          currentValue: currentStreakDays,
          goalValue: 30,
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
  factory FocusModuleState.fromJson(Map<String, dynamic> json) {
    // Valida conformidade com contrato
    ContractComplianceValidator.assertValid(json, 'focus');

    return FocusModuleState(
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sessionsCompleted: json['sessions_completed'] as int? ?? 0,
      totalFocusMinutes: json['total_focus_minutes'] as int? ?? 0,
      currentStreakDays: json['current_streak_days'] as int? ?? 0,
      longestStreakDays: json['longest_streak_days'] as int? ?? 0,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
      unlockedAchievements:
          (json['unlocked_achievements'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
    );
  }
}
