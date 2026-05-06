import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

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
  /// Compatível com JSONs antigos (camelCase) e novos (snake_case)
  factory ReadingModuleState.fromJson(Map<String, dynamic> json) {
    // Helper para ler campo em snake_case ou camelCase
    T? readField<T>(String snakeCase, String camelCase) {
      return (json[snakeCase] as T?) ?? (json[camelCase] as T?);
    }

    // Verifica se é um JSON antigo (camelCase)
    final isLegacyFormat = json.containsKey('consecutiveDays') || json.containsKey('earnedInsignias');
    
    if (isLegacyFormat) {
      LoggerService.instance.w('⚠️ ReadingModuleState.fromJson: Detectado formato camelCase (legacy). Migrando dados...');
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

    return ReadingModuleState(
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
      consecutiveDays: readField<int>('consecutive_days', 'consecutiveDays') ?? 0,
      lastReadingDate: readField<String>('last_reading_date', 'lastReadingDate') != null
          ? DateTime.parse(readField<String>('last_reading_date', 'lastReadingDate')!)
          : null,
      startDate: readField<String>('start_date', 'startDate') != null
          ? DateTime.parse(readField<String>('start_date', 'startDate')!)
          : null,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
      isModuleActive: readField<bool>('is_module_active', 'isModuleActive') ?? 
                      readField<bool>('is_active', 'isActive') ?? false,
    );
  }

  /// Factory para criar a partir de Map (alias para fromJson)
  factory ReadingModuleState.fromMap(Map<String, dynamic> map) => ReadingModuleState.fromJson(map);

  /// Reseta o estado para inicial, mas preserva a insígnia Madeira
  ReadingModuleState reset() => ReadingModuleState.initial().copyWith(
        earnedInsignias: earnedInsignias.contains('madeira') ? ['madeira'] : const [],
      );
}
