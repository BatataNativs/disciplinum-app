import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';

/// Regra de disciplina que pode ser aplicada
abstract class DisciplineRule {
  final String id;
  final String name;
  final String description;
  final NicheId moduleId;
  final bool isEnabled;

  DisciplineRule({
    required this.id,
    required this.name,
    required this.description,
    required this.moduleId,
    this.isEnabled = true,
  });

  /// Executa a regra
  Future<DisciplineResult> execute(DisciplineContext context);

  /// Verifica se a regra pode ser aplicada
  bool canExecute(DisciplineContext context);
}

/// Contexto de execução de regras
class DisciplineContext {
  final NicheId moduleId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  DisciplineContext({
    required this.moduleId,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Resultado da execução de uma regra
class DisciplineResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? metadata;
  final DisciplineRule? rule;

  DisciplineResult({
    required this.success,
    required this.message,
    this.metadata,
    this.rule,
  });

  factory DisciplineResult.success(String message, {Map<String, dynamic>? metadata, DisciplineRule? rule}) {
    return DisciplineResult(
      success: true,
      message: message,
      metadata: metadata,
      rule: rule,
    );
  }

  factory DisciplineResult.failure(String message, {DisciplineRule? rule}) {
    return DisciplineResult(
      success: false,
      message: message,
      rule: rule,
    );
  }
}

/// Eventos do DisciplineEngine
class RuleExecutedEvent extends AppEvent {
  final DisciplineRule rule;
  final DisciplineResult result;

  RuleExecutedEvent({
    required this.rule,
    required this.result,
  }) : super(data: {
    'rule_id': rule.id,
    'rule_name': rule.name,
    'success': result.success,
    'message': result.message,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

class RulesUpdatedEvent extends AppEvent {
  final List<DisciplineRule> rules;

  RulesUpdatedEvent(this.rules) : super(data: {
    'rules_count': rules.length,
    'enabled_count': rules.where((r) => r.isEnabled).length,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

/// Regra: Verificar streak de foco
class FocusStreakRule extends DisciplineRule {
  final FocusService _focusService;
  final GamificationAwardEngine _awardEngine;

  FocusStreakRule(this._focusService, this._awardEngine)
      : super(
          id: 'focus_streak_check',
          name: 'Verificação de Streak de Foco',
          description: 'Verifica e concede insignias por streaks de foco',
          moduleId: NicheId.focus,
        );

  @override
  bool canExecute(DisciplineContext context) {
    return context.moduleId == NicheId.focus && isEnabled;
  }

  @override
  Future<DisciplineResult> execute(DisciplineContext context) async {
    try {
      await _awardEngine.checkFocusInsigniasByPeriods(
        NicheId.focus,
        _focusService,
      );

      return DisciplineResult.success(
        'Streak de foco verificado com sucesso',
        rule: this,
      );
    } catch (e) {
      return DisciplineResult.failure(
        'Erro ao verificar streak de foco: $e',
        rule: this,
      );
    }
  }
}

/// Regra: Verificar conteúdo adulto bloqueado
class AdultContentBlockRule extends DisciplineRule {
  final AdultContentService _adultContentService;
  final GamificationAwardEngine _awardEngine;

  AdultContentBlockRule(this._adultContentService, this._awardEngine)
      : super(
          id: 'adult_content_block_check',
          name: 'Verificação de Bloqueio Adult',
          description: 'Verifica e concede pontos por bloqueio de conteúdo adulto',
          moduleId: NicheId.adultContent,
        );

  @override
  bool canExecute(DisciplineContext context) {
    return context.moduleId == NicheId.adultContent && isEnabled;
  }

  @override
  Future<DisciplineResult> execute(DisciplineContext context) async {
    try {
      final action = context.data['action'] as String?;
      if (action == null) {
        return DisciplineResult.failure('Ação não especificada', rule: this);
      }

      await _awardEngine.processAdultContentEvent(action, _adultContentService);

      return DisciplineResult.success(
        'Evento de conteúdo adulto processado: $action',
        metadata: {'action': action},
        rule: this,
      );
    } catch (e) {
      return DisciplineResult.failure(
        'Erro ao processar evento de conteúdo adulto: $e',
        rule: this,
      );
    }
  }
}

/// Regra: Verificar metas de dieta
class DietGoalRule extends DisciplineRule {
  final DietService _dietService;
  final GamificationAwardEngine _awardEngine;

  DietGoalRule(this._dietService, this._awardEngine)
      : super(
          id: 'diet_goal_check',
          name: 'Verificação de Metas de Dieta',
          description: 'Verifica e concede pontos por metas de dieta alcançadas',
          moduleId: NicheId.diet,
        );

  @override
  bool canExecute(DisciplineContext context) {
    return context.moduleId == NicheId.diet && isEnabled;
  }

  @override
  Future<DisciplineResult> execute(DisciplineContext context) async {
    try {
      final eventType = context.data['eventType'] as String?;
      if (eventType == null) {
        return DisciplineResult.failure('Tipo de evento não especificado', rule: this);
      }

      await _awardEngine.processDietEvent(eventType, _dietService);

      return DisciplineResult.success(
        'Evento de dieta processado: $eventType',
        metadata: {'eventType': eventType},
        rule: this,
      );
    } catch (e) {
      return DisciplineResult.failure(
        'Erro ao processar evento de dieta: $e',
        rule: this,
      );
    }
  }
}

/// Cérebro central do sistema de disciplina
class DisciplineEngine {
  static DisciplineEngine? _instance;
  static DisciplineEngine get instance => _instance ??= DisciplineEngine._();

  DisciplineEngine._();

  final List<DisciplineRule> _rules = [];
  final StreamController<DisciplineResult> _resultsController = 
      StreamController<DisciplineResult>.broadcast();

  /// Stream de resultados das regras
  Stream<DisciplineResult> get results => _resultsController.stream;

  /// Registra uma nova regra
  void registerRule(DisciplineRule rule) {
    _rules.removeWhere((r) => r.id == rule.id);
    _rules.add(rule);
    
    LoggerService.instance.i('Regra registrada: ${rule.name} (${rule.id})');
    EventBus.instance.emit(RulesUpdatedEvent(_rules));
  }

  /// Remove uma regra
  void unregisterRule(String ruleId) {
    final originalLength = _rules.length;
    _rules.removeWhere((r) => r.id == ruleId);
    final wasRemoved = _rules.length < originalLength;
    
    if (wasRemoved) {
      LoggerService.instance.i('Regra removida: $ruleId');
      EventBus.instance.emit(RulesUpdatedEvent(_rules));
    }
  }

  /// Habilita/desabilita uma regra
  void toggleRule(String ruleId, bool enabled) {
    final ruleIndex = _rules.indexWhere((r) => r.id == ruleId);
    if (ruleIndex != -1) {
      // Note: Isso exigiria que as regras sejam mutáveis ou usemos um padrão diferente
      // Por enquanto, apenas logamos a ação
      LoggerService.instance.i('Regra $ruleId ${enabled ? 'habilitada' : 'desabilitada'}');
      EventBus.instance.emit(RulesUpdatedEvent(_rules));
    }
  }

  /// Executa regras para um contexto específico
  Future<List<DisciplineResult>> executeRules(DisciplineContext context) async {
    final applicableRules = _rules.where((rule) => rule.canExecute(context)).toList();
    final results = <DisciplineResult>[];

    LoggerService.instance.d(
      'Executando ${applicableRules.length} regras para módulo ${context.moduleId}'
    );

    for (final rule in applicableRules) {
      try {
        final result = await rule.execute(context);
        results.add(result);
        
        _resultsController.add(result);
        EventBus.instance.emit(RuleExecutedEvent(rule: rule, result: result));

        LoggerService.instance.d(
          'Regra executada: ${rule.name} -> ${result.success ? "SUCESSO" : "FALHA"}'
        );
      } catch (e) {
        final errorResult = DisciplineResult.failure(
          'Erro inesperado ao executar regra ${rule.name}: $e',
          rule: rule,
        );
        
        results.add(errorResult);
        _resultsController.add(errorResult);
        
        LoggerService.instance.e(
          'Erro ao executar regra ${rule.name}',
          error: e,
        );
      }
    }

    return results;
  }

  /// Executa regras para um módulo específico
  Future<List<DisciplineResult>> executeRulesForModule(
    NicheId moduleId, {
    Map<String, dynamic>? data,
  }) async {
    final context = DisciplineContext(
      moduleId: moduleId,
      data: data ?? {},
    );

    return executeRules(context);
  }

  /// Obtém todas as regras
  List<DisciplineRule> get allRules => List.unmodifiable(_rules);

  /// Obtém regras de um módulo específico
  List<DisciplineRule> getRulesForModule(NicheId moduleId) {
    return _rules.where((rule) => rule.moduleId == moduleId).toList();
  }

  /// Obtém estatísticas das regras
  Map<String, dynamic> getStatistics() {
    return {
      'total_rules': _rules.length,
      'enabled_rules': _rules.where((r) => r.isEnabled).length,
      'rules_by_module': {
        for (final module in NicheId.values)
          module.id.toString(): _rules.where((r) => r.moduleId == module).length,
      },
    };
  }

  /// Limpa recursos
  void dispose() {
    _resultsController.close();
    _rules.clear();
    LoggerService.instance.i('DisciplineEngine disposed');
  }
}

/// Inicializador do DisciplineEngine com regras padrão
class DisciplineEngineInitializer {
  static Future<void> initialize({
    FocusService? focusService,
    AdultContentService? adultContentService,
    DietService? dietService,
    GamificationAwardEngine? awardEngine,
  }) async {
    final engine = DisciplineEngine.instance;

    // Regra de streak de foco
    if (focusService != null && awardEngine != null) {
      engine.registerRule(FocusStreakRule(focusService, awardEngine));
    }

    // Regra de conteúdo adulto
    if (adultContentService != null && awardEngine != null) {
      engine.registerRule(AdultContentBlockRule(adultContentService, awardEngine));
    }

    // Regra de dieta
    if (dietService != null && awardEngine != null) {
      engine.registerRule(DietGoalRule(dietService, awardEngine));
    }

    LoggerService.instance.i(
      'DisciplineEngine inicializado com ${engine.allRules.length} regras'
    );
  }
}
