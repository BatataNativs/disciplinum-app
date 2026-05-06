import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Estado do módulo Smoking implementando [ModuleStateContract]
///
/// Implementa o contrato base para o módulo de controle de cigarro.
class SmokingModuleState implements ModuleStateContract {
  @override
  final String moduleId = 'smoking';

  @override
  final int schemaVersion = 1;

  @override
  final DateTime createdAt;

  @override
  DateTime updatedAt;

  // Campos específicos do módulo Smoking
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final List<String> earnedHealthBenefits; // Marcos de saúde alcançados
  final int consecutivePositiveDays;
  final int disciplinumCount;
  final DateTime? lastPositiveCheckIn;
  final DateTime? startDate;
  final double dailyCost;
  final double packCost;
  final String currentStageId;
  final Map<String, List<String>> customMessages;
  final String? customMainMessage;
  final bool isModuleActive;

  SmokingModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.earnedHealthBenefits = const [],
    this.consecutivePositiveDays = 0,
    this.disciplinumCount = 0,
    this.lastPositiveCheckIn,
    this.startDate,
    this.dailyCost = 0.0,
    this.packCost = 0.0,
    this.currentStageId = 'bronze',
    this.customMessages = const {},
    this.customMainMessage,
    this.isModuleActive = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria estado inicial padrão
  factory SmokingModuleState.initial() {
    return SmokingModuleState(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      earnedInsignias: const [],
      earnedMedalhas: const [],
      earnedHealthBenefits: const [],
      consecutivePositiveDays: 0,
      disciplinumCount: 0,
      dailyCost: 0.0,
      packCost: 0.0,
      currentStageId: 'bronze',
      isModuleActive: false,
    );
  }

  /// Alias para updatedAt (compatibilidade)
  DateTime get lastUpdated => updatedAt;

  /// Cria cópia com valores atualizados
  SmokingModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    List<String>? earnedHealthBenefits,
    int? consecutivePositiveDays,
    int? disciplinumCount,
    DateTime? lastPositiveCheckIn,
    DateTime? startDate,
    double? dailyCost,
    double? packCost,
    String? currentStageId,
    Map<String, List<String>>? customMessages,
    String? customMainMessage,
    bool? isModuleActive,
  }) {
    return SmokingModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      earnedHealthBenefits: earnedHealthBenefits ?? this.earnedHealthBenefits,
      consecutivePositiveDays: consecutivePositiveDays ?? this.consecutivePositiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      lastPositiveCheckIn: lastPositiveCheckIn ?? this.lastPositiveCheckIn,
      startDate: startDate ?? this.startDate,
      dailyCost: dailyCost ?? this.dailyCost,
      packCost: packCost ?? this.packCost,
      currentStageId: currentStageId ?? this.currentStageId,
      customMessages: customMessages ?? this.customMessages,
      customMainMessage: customMainMessage ?? this.customMainMessage,
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
      ..setField('earned_health_benefits', earnedHealthBenefits)
      ..setField('consecutive_positive_days', consecutivePositiveDays)
      ..setField('disciplinum_count', disciplinumCount)
      ..setField('last_positive_check_in', lastPositiveCheckIn?.toIso8601String())
      ..setField('start_date', startDate?.toIso8601String())
      ..setField('daily_cost', dailyCost)
      ..setField('pack_cost', packCost)
      ..setField('total_money_saved', totalMoneySaved)
      ..setField('total_days_without_smoking', totalDaysWithoutSmoking)
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
          fieldName: 'consecutive_positive_days',
          currentValue: consecutivePositiveDays,
          goalValue: 30,
        ),
        BaseProgressMetric(
          fieldName: 'disciplinum_count',
          currentValue: disciplinumCount,
          goalValue: 5,
        ),
        BaseProgressMetric(
          fieldName: 'total_money_saved',
          currentValue: totalMoneySaved,
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

  /// Calcula o total de dias sem fumar
  int get totalDaysWithoutSmoking {
    if (startDate == null) return 0;
    return DateTime.now().difference(startDate!).inDays;
  }

  /// Calcula o dinheiro total economizado
  double get totalMoneySaved => dailyCost * consecutivePositiveDays;

  /// Calcula o número de maços economizados
  int get packsSaved {
    if (packCost <= 0) return 0;
    return (totalMoneySaved / packCost).floor();
  }

  /// Verifica se está em streak
  bool get isInStreak => consecutivePositiveDays > 0;

  /// Verifica se tem streak significativo (7+ dias)
  bool get hasSignificantStreak => consecutivePositiveDays >= 7;

  /// Factory para criar a partir de JSON (ex: do Supabase)
  /// Compatível com JSONs antigos (camelCase) e novos (snake_case)
  factory SmokingModuleState.fromJson(Map<String, dynamic> json) {
    // Helper para ler campo em snake_case ou camelCase
    T? readField<T>(String snakeCase, String camelCase) {
      return (json[snakeCase] as T?) ?? (json[camelCase] as T?);
    }

    // Verifica se é um JSON antigo (camelCase)
    final isLegacyFormat = json.containsKey('dailyCost') || json.containsKey('packCost');
    
    if (isLegacyFormat) {
      LoggerService.instance.w('⚠️ SmokingModuleState.fromJson: Detectado formato camelCase (legacy). Migrando dados...');
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

    // Extrai campos de dados com suporte a ambos os formatos
    final dailyCost = (readField<num>('daily_cost', 'dailyCost'))?.toDouble() ?? 0.0;
    final packCost = (readField<num>('pack_cost', 'packCost'))?.toDouble() ?? 0.0;

    return SmokingModuleState(
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
      earnedHealthBenefits:
          (readField<List<dynamic>>('earned_health_benefits', 'earnedHealthBenefits'))
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      consecutivePositiveDays: readField<int>('consecutive_positive_days', 'consecutivePositiveDays') ?? 0,
      disciplinumCount: readField<int>('disciplinum_count', 'disciplinumCount') ?? 0,
      lastPositiveCheckIn: readField<String>('last_positive_check_in', 'lastPositiveCheckIn') != null
          ? DateTime.parse(readField<String>('last_positive_check_in', 'lastPositiveCheckIn')!)
          : null,
      startDate: readField<String>('start_date', 'startDate') != null
          ? DateTime.parse(readField<String>('start_date', 'startDate')!)
          : null,
      dailyCost: dailyCost,
      packCost: packCost,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
      isModuleActive: readField<bool>('is_module_active', 'isModuleActive') ?? 
                      readField<bool>('is_active', 'isActive') ?? false,
    );
  }

  /// Factory para criar a partir de Map (alias para fromJson)
  factory SmokingModuleState.fromMap(Map<String, dynamic> map) => SmokingModuleState.fromJson(map);

  /// Verifica se possui uma insignia específica
  bool hasInsignia(String insigniaId) {
    return earnedInsignias.contains(insigniaId);
  }

  /// Concede uma insignia
  SmokingModuleState awardInsignia(String insigniaId) {
    if (hasInsignia(insigniaId)) return this;
    final updatedInsignias = [...earnedInsignias, insigniaId];
    return copyWith(earnedInsignias: updatedInsignias);
  }

  /// Revoga uma insignia
  SmokingModuleState revokeInsignia(String insigniaId) {
    final updatedInsignias = earnedInsignias.where((id) => id != insigniaId).toList();
    return copyWith(earnedInsignias: updatedInsignias);
  }

  /// Reseta todas as insignias
  SmokingModuleState resetInsignias() {
    return copyWith(earnedInsignias: []);
  }

  /// Verifica se possui uma medalha específica
  bool hasMedalha(String medalhaId) {
    return earnedMedalhas.contains(medalhaId);
  }

  /// Concede uma medalha
  SmokingModuleState awardMedalha(String medalhaId) {
    if (hasMedalha(medalhaId)) return this;
    final updatedMedalhas = [...earnedMedalhas, medalhaId];
    return copyWith(earnedMedalhas: updatedMedalhas);
  }

  /// Revoga uma medalha
  SmokingModuleState revokeMedalha(String medalhaId) {
    final updatedMedalhas = earnedMedalhas.where((id) => id != medalhaId).toList();
    return copyWith(earnedMedalhas: updatedMedalhas);
  }

  /// Reseta todas as medalhas
  SmokingModuleState resetMedalhas() {
    return copyWith(earnedMedalhas: []);
  }

  /// Verifica se possui um benefício de saúde específico
  bool hasHealthBenefit(String benefitId) {
    return earnedHealthBenefits.contains(benefitId);
  }

  /// Concede um benefício de saúde
  SmokingModuleState awardHealthBenefit(String benefitId) {
    if (hasHealthBenefit(benefitId)) return this;
    final updatedBenefits = [...earnedHealthBenefits, benefitId];
    return copyWith(earnedHealthBenefits: updatedBenefits);
  }

  /// Reseta todos os benefícios de saúde
  SmokingModuleState resetHealthBenefits() {
    return copyWith(earnedHealthBenefits: []);
  }

  /// Reseta o estado para inicial, mas preserva a insígnia Madeira
  SmokingModuleState reset() => SmokingModuleState.initial().copyWith(
        earnedInsignias: earnedInsignias.contains('madeira') ? ['madeira'] : const [],
      );
}
