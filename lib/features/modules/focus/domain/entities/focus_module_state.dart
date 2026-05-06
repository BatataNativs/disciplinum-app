import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/contract_helpers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

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
  final bool isModuleActive;

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
    this.isModuleActive = false,
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
      isModuleActive: false,
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
    bool? isModuleActive,
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
      ..setField('sessions_completed', sessionsCompleted)
      ..setField('total_focus_minutes', totalFocusMinutes)
      ..setField('current_streak_days', currentStreakDays)
      ..setField('longest_streak_days', longestStreakDays)
      ..setField('unlocked_achievements', unlockedAchievements)
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
  /// Compatível com JSONs antigos (camelCase) e novos (snake_case)
  factory FocusModuleState.fromJson(Map<String, dynamic> json) {
    // Helper para ler campo em snake_case ou camelCase
    T? readField<T>(String snakeCase, String camelCase) {
      return (json[snakeCase] as T?) ?? (json[camelCase] as T?);
    }

    // Verifica se é um JSON antigo (camelCase)
    final isLegacyFormat = json.containsKey('sessionsCompleted') || json.containsKey('totalFocusMinutes');
    
    if (isLegacyFormat) {
      LoggerService.instance.w('⚠️ FocusModuleState.fromJson: Detectado formato camelCase (legacy). Migrando dados...');
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

    return FocusModuleState(
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
      sessionsCompleted: readField<int>('sessions_completed', 'sessionsCompleted') ?? 0,
      totalFocusMinutes: readField<int>('total_focus_minutes', 'totalFocusMinutes') ?? 0,
      currentStreakDays: readField<int>('current_streak_days', 'currentStreakDays') ?? 0,
      longestStreakDays: readField<int>('longest_streak_days', 'longestStreakDays') ?? 0,
      currentStageId: json['stage']?['id'] as String? ?? 'bronze',
      unlockedAchievements:
          (readField<List<dynamic>>('unlocked_achievements', 'unlockedAchievements'))
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      respectedPeriods:
          (readField<List<dynamic>>('respected_periods', 'respectedPeriods'))
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      isModuleActive: json['is_module_active'] as bool? ?? json['is_active'] as bool? ?? false,
    );
  }

  /// Factory para criar a partir de Map (alias para fromJson)
  factory FocusModuleState.fromMap(Map<String, dynamic> map) => FocusModuleState.fromJson(map);

  /// Reseta o estado para inicial, mas preserva a insígnia Madeira
  FocusModuleState reset() => FocusModuleState.initial().copyWith(
        earnedInsignias: earnedInsignias.contains('madeira') ? ['madeira'] : const [],
      );

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

  /// Contagem de disciplinum (quantas vezes a insígnia 'disciplinum' foi conquistada)
  int get disciplinumCount => earnedInsignias.where((i) => i == 'disciplinum').length;
}
