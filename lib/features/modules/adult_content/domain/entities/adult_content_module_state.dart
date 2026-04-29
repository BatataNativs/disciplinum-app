import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Estado do módulo Adult Content implementando [ModuleStateContract]
///
/// Implementa o contrato base para o módulo de controle de conteúdo adulto.
class AdultContentModuleState implements ModuleStateContract {
  @override
  final String moduleId = 'adult_content';

  @override
  final int schemaVersion = 1;

  @override
  final DateTime createdAt;

  @override
  DateTime updatedAt;

  // Campos específicos do módulo Adult Content
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final int disciplinumCount;
  final DateTime? lastBlockedDate;
  final DateTime? startDate;
  final bool isModuleActive;
  final String currentStageId;

  AdultContentModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    this.lastBlockedDate,
    this.startDate,
    this.isModuleActive = false,
    this.currentStageId = 'bronze',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria estado inicial padrão
  factory AdultContentModuleState.initial() {
    return AdultContentModuleState(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      earnedInsignias: const [],
      earnedMedalhas: const [],
      consecutiveDays: 0,
      disciplinumCount: 0,
      isModuleActive: false,
      currentStageId: 'bronze',
    );
  }

  /// Alias para updatedAt (compatibilidade)
  DateTime get lastUpdated => updatedAt;

  /// Cria cópia com valores atualizados
  AdultContentModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    DateTime? lastBlockedDate,
    DateTime? startDate,
    bool? isModuleActive,
    String? currentStageId,
  }) {
    return AdultContentModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      lastBlockedDate: lastBlockedDate ?? this.lastBlockedDate,
      startDate: startDate ?? this.startDate,
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
      ..setField('consecutive_days', consecutiveDays)
      ..setField('disciplinum_count', disciplinumCount)
      ..setField('last_blocked_date', lastBlockedDate?.toIso8601String())
      ..setField('start_date', startDate?.toIso8601String())
      ..setField('is_module_active', isModuleActive)
      ..setField('current_stage_id', currentStageId)
      ..setField('last_updated', updatedAt.toIso8601String());

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
          fieldName: 'total_blocked_attempts',
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
  /// Compatível com JSONs antigos (camelCase) e novos (snake_case)
  factory AdultContentModuleState.fromJson(Map<String, dynamic> json) {
    // Helper para ler campo em snake_case ou camelCase
    T? readField<T>(String snakeCase, String camelCase) {
      return (json[snakeCase] as T?) ?? (json[camelCase] as T?);
    }

    // Verifica se é um JSON antigo (camelCase)
    final isLegacyFormat = json.containsKey('consecutiveDays');
    
    if (isLegacyFormat) {
      LoggerService.instance.w('⚠️ AdultContentModuleState.fromJson: Detectado formato camelCase (legacy). Migrando dados...');
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

    return AdultContentModuleState(
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
      disciplinumCount: readField<int>('disciplinum_count', 'disciplinumCount') ?? 0,
      lastBlockedDate: readField<String>('last_blocked_date', 'lastBlockedDate') != null
          ? DateTime.parse(readField<String>('last_blocked_date', 'lastBlockedDate')!)
          : null,
      isModuleActive: readField<bool>('is_module_active', 'isModuleActive') ?? 
                      readField<bool>('is_active', 'isActive') ?? false,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
    );
  }

  /// Factory para criar a partir de Map (alias para fromJson)
  factory AdultContentModuleState.fromMap(Map<String, dynamic> map) => AdultContentModuleState.fromJson(map);
}
