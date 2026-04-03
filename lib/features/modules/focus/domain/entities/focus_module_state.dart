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
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int sessionsCompleted;
  final int totalFocusMinutes;
  final int currentStreakDays;
  final int longestStreakDays;
  final String currentStageId;
  final List<String> unlockedAchievements;
  final List<String> respectedPeriods;
  final bool isActive;

  FocusModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.sessionsCompleted = 0,
    this.totalFocusMinutes = 0,
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.currentStageId = 'bronze',
    this.unlockedAchievements = const [],
    this.respectedPeriods = const [],
    this.isActive = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria estado inicial padrão
  factory FocusModuleState.initial() {
    return FocusModuleState(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      earnedInsignias: const [],
      earnedMedalhas: const [],
      sessionsCompleted: 0,
      totalFocusMinutes: 0,
      currentStreakDays: 0,
      longestStreakDays: 0,
      currentStageId: 'bronze',
      unlockedAchievements: const [],
      respectedPeriods: const [],
      isActive: false,
    );
  }

  /// Alias para updatedAt (compatibilidade)
  DateTime get lastUpdated => updatedAt;

  /// Contagem de períodos respeitados
  int get respectedPeriodsCount => respectedPeriods.length;

  /// Cria cópia com valores atualizados
  FocusModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? sessionsCompleted,
    int? totalFocusMinutes,
    int? currentStreakDays,
    int? longestStreakDays,
    String? currentStageId,
    List<String>? unlockedAchievements,
    List<String>? respectedPeriods,
    bool? isActive,
  }) {
    return FocusModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      currentStageId: currentStageId ?? this.currentStageId,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      respectedPeriods: respectedPeriods ?? this.respectedPeriods,
      isActive: isActive ?? this.isActive,
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
      respectedPeriods:
          (json['respected_periods'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  /// Factory para criar a partir de Map (alias para fromJson)
  factory FocusModuleState.fromMap(Map<String, dynamic> map) => FocusModuleState.fromJson(map);

  /// Reseta o estado para inicial
  FocusModuleState reset() => FocusModuleState.initial();

  /// Verifica se tem uma insignia específica
  bool hasInsignia(String insigniaId) => earnedInsignias.contains(insigniaId);

  /// Verifica se tem uma medalha específica
  bool hasMedalha(String medalhaId) => earnedMedalhas.contains(medalhaId);

  /// Retorna a próxima insignia (primeira não conquistada)
  String? get nextInsignia {
    final allInsignias = ['madeira', 'bronze', 'prata', 'ouro', 'diamante'];
    for (final id in allInsignias) {
      if (!earnedInsignias.contains(id)) return id;
    }
    return null;
  }

  /// Contagem de disciplinum (respectedPeriods.length)
  int get disciplinumCount => respectedPeriods.length;
}
