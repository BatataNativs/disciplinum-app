import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Estado do módulo Spending implementando [ModuleStateContract]
///
/// Implementa o contrato base para o módulo de controle de gastos.
class SpendingModuleState implements ModuleStateContract {
  @override
  final String moduleId = 'spending';

  @override
  final int schemaVersion = 1;

  @override
  final DateTime createdAt;

  @override
  DateTime updatedAt;

  // Campos específicos do módulo Spending
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int consecutiveDays;
  final int disciplinumCount;
  final double totalMoneySaved;
  final int totalExpensesAvoided;
  final double monthlyBudget;
  final bool isModuleActive;
  final String currentStageId;
  final int consecutiveMonths;

  SpendingModuleState({
    DateTime? createdAt,
    DateTime? updatedAt,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    this.totalMoneySaved = 0.0,
    this.totalExpensesAvoided = 0,
    this.monthlyBudget = 0.0,
    this.isModuleActive = false,
    this.currentStageId = 'bronze',
    this.consecutiveMonths = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria estado inicial padrão
  factory SpendingModuleState.initial() {
    return SpendingModuleState(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      earnedInsignias: const [],
      earnedMedalhas: const [],
      consecutiveDays: 0,
      disciplinumCount: 0,
      totalMoneySaved: 0.0,
      totalExpensesAvoided: 0,
      monthlyBudget: 0.0,
      isModuleActive: false,
      currentStageId: 'bronze',
    );
  }

  /// Alias para updatedAt (compatibilidade)
  DateTime get lastUpdated => updatedAt;

  /// Cria cópia com valores atualizados
  SpendingModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    double? totalMoneySaved,
    int? totalExpensesAvoided,
    double? monthlyBudget,
    bool? isModuleActive,
    String? currentStageId,
    int? consecutiveMonths,
  }) {
    return SpendingModuleState(
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      totalMoneySaved: totalMoneySaved ?? this.totalMoneySaved,
      totalExpensesAvoided: totalExpensesAvoided ?? this.totalExpensesAvoided,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      currentStageId: currentStageId ?? this.currentStageId,
      consecutiveMonths: consecutiveMonths ?? this.consecutiveMonths,
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
      ..setField('total_money_saved', totalMoneySaved)
      ..setField('total_expenses_avoided', totalExpensesAvoided)
      ..setField('monthly_budget', monthlyBudget)
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
          fieldName: 'total_money_saved',
          currentValue: totalMoneySaved,
          goalValue: 1000.0,
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
  /// Factory para criar a partir de JSON (ex: do Supabase)
  /// Compatível com JSONs antigos (camelCase) e novos (snake_case)
  factory SpendingModuleState.fromJson(Map<String, dynamic> json) {
    // Helper para ler campo em snake_case ou camelCase
    T? readField<T>(String snakeCase, String camelCase) {
      return (json[snakeCase] as T?) ?? (json[camelCase] as T?);
    }

    // Verifica se é um JSON antigo (camelCase)
    final isLegacyFormat = json.containsKey('totalMoneySaved') || json.containsKey('consecutiveDays');
    
    if (isLegacyFormat) {
      LoggerService.instance.w('⚠️ SpendingModuleState.fromJson: Detectado formato camelCase (legacy). Migrando dados...');
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

    return SpendingModuleState(
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
      totalMoneySaved: (readField<num>('total_money_saved', 'totalMoneySaved'))?.toDouble() ?? 0.0,
      totalExpensesAvoided: readField<int>('total_expenses_avoided', 'totalExpensesAvoided') ?? 0,
      monthlyBudget: (readField<num>('monthly_budget', 'monthlyBudget'))?.toDouble() ?? 0.0,
      isModuleActive: readField<bool>('is_module_active', 'isModuleActive') ?? 
                      readField<bool>('is_active', 'isActive') ?? false,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
    );
  }

  /// Factory para criar a partir de Map (alias para fromJson)
  factory SpendingModuleState.fromMap(Map<String, dynamic> map) => SpendingModuleState.fromJson(map);
}
