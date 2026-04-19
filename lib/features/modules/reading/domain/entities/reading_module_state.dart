import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';

/// Estado do módulo Reading implementando [ModuleStateContract]
///
/// Implementa o contrato base para o módulo de leitura.
class ReadingModuleState implements ModuleStateContract {
  @override
  final String moduleId = 'reading';

  @override
  final int schemaVersion = 1;

  @override
  final DateTime createdAt;

  @override
  DateTime updatedAt;

  // Campos específicos do módulo Reading
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final DateTime? lastReadingDate;
  final DateTime? startDate;
  final String currentStageId;
  final bool isModuleActive;

  ReadingModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.lastReadingDate,
    this.startDate,
    this.currentStageId = 'bronze',
    this.isModuleActive = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria estado inicial padrão
  factory ReadingModuleState.initial() {
    return ReadingModuleState(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      earnedInsignias: const [],
      earnedMedalhas: const [],
      consecutiveDays: 0,
      currentStageId: 'bronze',
      isModuleActive: false,
    );
  }

  /// Alias para updatedAt (compatibilidade)
  DateTime get lastUpdated => updatedAt;

  /// Cria cópia com valores atualizados
  ReadingModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    DateTime? lastReadingDate,
    DateTime? startDate,
    String? currentStageId,
    bool? isModuleActive,
  }) {
    return ReadingModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      startDate: startDate ?? this.startDate,
      currentStageId: currentStageId ?? this.currentStageId,
      isModuleActive: isModuleActive ?? this.isModuleActive,
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
      ..setField('last_reading_date', lastReadingDate?.toIso8601String())
      ..setField('start_date', startDate?.toIso8601String())
      ..setField('is_module_active', isModuleActive)
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
          fieldName: 'total_reading_days',
          currentValue: consecutiveDays,
          goalValue: 100,
        ),
        BaseProgressMetric(
          fieldName: 'books_completed',
          currentValue: earnedInsignias.length,
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
  factory ReadingModuleState.fromJson(Map<String, dynamic> json) {
    // Valida conformidade com contrato
    ContractComplianceValidator.assertValid(json, 'reading');

    return ReadingModuleState(
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
      lastReadingDate: json['last_reading_date'] != null
          ? DateTime.parse(json['last_reading_date'] as String)
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
      isModuleActive: json['is_module_active'] as bool? ?? json['is_active'] as bool? ?? false,
    );
  }

  /// Factory para criar a partir de Map (alias para fromJson)
  factory ReadingModuleState.fromMap(Map<String, dynamic> map) => ReadingModuleState.fromJson(map);
}
