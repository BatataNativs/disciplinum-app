import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine_extensions.dart';

/// Implementação do módulo de disciplina para Procrastination
class ProcrastinationDisciplineModule extends ModuleDisciplineInterface {
  final ProcrastinationService _procrastinationService;
  final GamificationAwardEngine _awardEngine;
  
  ProcrastinationDisciplineModule({
    required ProcrastinationService procrastinationService,
    required GamificationAwardEngine awardEngine,
  }) : _procrastinationService = procrastinationService,
       _awardEngine = awardEngine;

  @override
  String get moduleId => 'procrastination';

  @override
  String get moduleName => 'Procrastination';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      ProcrastinationStreakRule(_procrastinationService, _awardEngine),
      ProcrastinationFocusRule(_procrastinationService, _awardEngine),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }
}

/// Regra para verificar streak de produtividade
class ProcrastinationStreakRule extends ModuleRule {
  final ProcrastinationService _procrastinationService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  ProcrastinationStreakRule(this._procrastinationService, this._awardEngine);

  @override
  String get ruleId => 'procrastination_streak_check';

  @override
  String get ruleName => 'Verificação de Streak - Produtividade';

  @override
  String get description => 
      'Verifica e concede insignias por dias consecutivos sem procrastinação';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'procrastination' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final eventType = context.getData<String>('eventType');
      if (eventType == null) {
        return ModuleDisciplineResult.failure(
          message: 'Tipo de evento não especificado',
          ruleId: ruleId,
          moduleId: 'procrastination',
        );
      }

      // Implementar processProcrastinationEvent no GamificationAwardEngine
      await _awardEngine.processProcrastinationEvent(eventType, _procrastinationService);
      
      // Por enquanto, apenas logamos o evento
      LoggerService.instance.d('Evento procrastination recebido: $eventType');
      
      // Simula uso dos serviços para evitar warnings
      _procrastinationService;
      _awardEngine;
      
      return ModuleDisciplineResult.success(
        message: 'Evento de procrastination processado: $eventType',
        ruleId: ruleId,
        moduleId: 'procrastination',
        metadata: {'eventType': eventType},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao processar evento de procrastination: $e',
        ruleId: ruleId,
        moduleId: 'procrastination',
      );
    }
  }
}

/// Regra para verificar foco e produtividade
class ProcrastinationFocusRule extends ModuleRule {
  final ProcrastinationService _procrastinationService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  ProcrastinationFocusRule(this._procrastinationService, this._awardEngine);

  @override
  String get ruleId => 'procrastination_focus_check';

  @override
  String get ruleName => 'Verificação de Foco - Produtividade';

  @override
  String get description => 
      'Verifica e concede pontos por sessões de foco concluídas';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'procrastination' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final focusMinutes = context.getData<int>('focusMinutes') ?? 0;
      final dailyGoal = context.getData<int>('dailyGoal') ?? 60;
      
      if (focusMinutes >= dailyGoal) {
        // Meta diária de foco alcançada
        await _awardEngine.processProcrastinationEvent('daily_focus_goal', _procrastinationService);
        
        LoggerService.instance.d('Meta diária de foco alcançada: $focusMinutes minutos');
        
        return ModuleDisciplineResult.success(
          message: 'Meta diária de foco alcançada: $focusMinutes minutos',
          ruleId: ruleId,
          moduleId: 'procrastination',
          metadata: {'focusMinutes': focusMinutes, 'dailyGoal': dailyGoal},
        );
      }

      return ModuleDisciplineResult.success(
        message: 'Meta diária de foco não alcançada ainda',
        ruleId: ruleId,
        moduleId: 'procrastination',
        metadata: {'focusMinutes': focusMinutes, 'dailyGoal': dailyGoal},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao verificar foco de procrastination: $e',
        ruleId: ruleId,
        moduleId: 'procrastination',
      );
    }
  }
}
