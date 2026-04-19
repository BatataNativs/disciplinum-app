import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';

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
  factory SmokingModuleState.fromJson(Map<String, dynamic> json) {
    // Valida conformidade com contrato
    ContractComplianceValidator.assertValid(json, 'smoking');

    return SmokingModuleState(
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
      consecutivePositiveDays: json['consecutive_positive_days'] as int? ?? 0,
      disciplinumCount: json['disciplinum_count'] as int? ?? 0,
      lastPositiveCheckIn: json['last_positive_check_in'] != null
          ? DateTime.parse(json['last_positive_check_in'] as String)
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      dailyCost: (json['daily_cost'] as num?)?.toDouble() ?? 0.0,
      packCost: (json['pack_cost'] as num?)?.toDouble() ?? 0.0,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
      isModuleActive: json['is_module_active'] as bool? ?? json['is_active'] as bool? ?? false,
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
}
