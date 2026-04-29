import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

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
  final bool isModuleActive;
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
    this.isModuleActive = false,
    this.currentStageId = 'bronze',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria estado inicial padrão
  factory ProcrastinationModuleState.initial() {
    return ProcrastinationModuleState(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      earnedInsignias: const [],
      earnedMedalhas: const [],
      consecutiveProductiveDays: 0,
      disciplinumCount: 0,
      totalTasksCompleted: 0,
      totalFocusMinutes: 0,
      isModuleActive: false,
      currentStageId: 'bronze',
    );
  }

  /// Alias para updatedAt (compatibilidade)
  DateTime get lastUpdated => updatedAt;

  /// Getter para consecutiveDays (alias para consecutiveProductiveDays)
  int get consecutiveDays => consecutiveProductiveDays;

  /// Cria cópia com valores atualizados
  ProcrastinationModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveProductiveDays,
    int? disciplinumCount,
    int? totalTasksCompleted,
    int? totalFocusMinutes,
    bool? isModuleActive,
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
      isModuleActive: isModuleActive ?? this.isModuleActive,
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
      ..setField('is_module_active', isModuleActive)
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
  /// Compatível com JSONs antigos (camelCase) e novos (snake_case)
  factory ProcrastinationModuleState.fromJson(Map<String, dynamic> json) {
    // Helper para ler campo em snake_case ou camelCase
    T? readField<T>(String snakeCase, String camelCase) {
      return (json[snakeCase] as T?) ?? (json[camelCase] as T?);
    }

    // Verifica se é um JSON antigo (camelCase)
    final isLegacyFormat = json.containsKey('totalTasksCompleted') || json.containsKey('consecutiveProductiveDays');
    
    if (isLegacyFormat) {
      LoggerService.instance.w('⚠️ ProcrastinationModuleState.fromJson: Detectado formato camelCase (legacy). Migrando dados...');
    }

    // Extrai timestamps com fallback para now() se não existirem (backward compatibility)
    final createdAt = json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String)
        : (json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now());
    
    final updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : (json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now());

    return ProcrastinationModuleState(
      createdAt: createdAt,
      updatedAt: updatedAt,
      earnedInsignias:
          (readField<List<dynamic>>('earned_insignias', 'earnedInsignias'))
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      earnedMedalhas:
          (readField<List<dynamic>>('earned_medalhas', 'earnedMedalhas'))
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      consecutiveProductiveDays: readField<int>('consecutive_productive_days', 'consecutiveProductiveDays') ?? 0,
      disciplinumCount: readField<int>('disciplinum_count', 'disciplinumCount') ?? 0,
      totalTasksCompleted: readField<int>('total_tasks_completed', 'totalTasksCompleted') ?? 0,
      totalFocusMinutes: readField<int>('total_focus_minutes', 'totalFocusMinutes') ?? 0,
      isModuleActive: readField<bool>('is_module_active', 'isModuleActive') ?? 
                      readField<bool>('is_active', 'isActive') ?? false,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
    );
  }

  /// Factory para criar a partir de Map (alias para fromJson)
  factory ProcrastinationModuleState.fromMap(Map<String, dynamic> map) => ProcrastinationModuleState.fromJson(map);
}
