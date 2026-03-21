import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine_extensions.dart';

/// Implementação do módulo de disciplina para Money Saving
class MoneySavingDisciplineModule extends ModuleDisciplineInterface {
  final MoneySavingChallengeService _moneySavingService;
  final GamificationAwardEngine _awardEngine;
  
  MoneySavingDisciplineModule({
    required MoneySavingChallengeService moneySavingService,
    required GamificationAwardEngine awardEngine,
  }) : _moneySavingService = moneySavingService,
       _awardEngine = awardEngine;

  @override
  String get moduleId => 'money_saving';

  @override
  String get moduleName => 'Money Saving';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      MoneySavingStreakRule(_moneySavingService, _awardEngine),
      MoneySavingGoalRule(_moneySavingService, _awardEngine),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }
}

/// Regra para verificar streak de economia
class MoneySavingStreakRule extends ModuleRule {
  final MoneySavingChallengeService _moneySavingService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  MoneySavingStreakRule(this._moneySavingService, this._awardEngine);

  @override
  String get ruleId => 'money_saving_streak_check';

  @override
  String get ruleName => 'Verificação de Streak - Economia';

  @override
  String get description => 
      'Verifica e concede insignias por dias consecutivos de economia';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'money_saving' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final eventType = context.getData<String>('eventType');
      if (eventType == null) {
        return ModuleDisciplineResult.failure(
          message: 'Tipo de evento não especificado',
          ruleId: ruleId,
          moduleId: 'money_saving',
        );
      }

      // Implementar processMoneySavingEvent no GamificationAwardEngine
      await _awardEngine.processMoneySavingEvent(eventType, _moneySavingService);
      
      // Por enquanto, apenas logamos o evento
      LoggerService.instance.d('Evento money saving recebido: $eventType');
      
      // Simula uso dos serviços para evitar warnings
      _moneySavingService;
      _awardEngine;
      
      return ModuleDisciplineResult.success(
        message: 'Evento de money saving processado: $eventType',
        ruleId: ruleId,
        moduleId: 'money_saving',
        metadata: {'eventType': eventType},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao processar evento de money saving: $e',
        ruleId: ruleId,
        moduleId: 'money_saving',
      );
    }
  }
}

/// Regra para verificar metas de economia
class MoneySavingGoalRule extends ModuleRule {
  final MoneySavingChallengeService _moneySavingService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  MoneySavingGoalRule(this._moneySavingService, this._awardEngine);

  @override
  String get ruleId => 'money_saving_goal_check';

  @override
  String get ruleName => 'Verificação de Metas - Economia';

  @override
  String get description => 
      'Verifica e concede pontos por metas de economia alcançadas';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'money_saving' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final amountSaved = context.getData<double>('amountSaved') ?? 0.0;
      final dailyGoal = context.getData<double>('dailyGoal') ?? 10.0;
      
      if (amountSaved >= dailyGoal) {
        // Meta diária alcançada
        await _awardEngine.processMoneySavingEvent('challenge_completed', _moneySavingService);
        
        LoggerService.instance.d('Meta diária de economia alcançada: R\$ $amountSaved');
        
        return ModuleDisciplineResult.success(
          message: 'Meta diária de economia alcançada: R\$ $amountSaved',
          ruleId: ruleId,
          moduleId: 'money_saving',
          metadata: {'amountSaved': amountSaved, 'dailyGoal': dailyGoal},
        );
      }

      return ModuleDisciplineResult.success(
        message: 'Meta diária não alcançada ainda',
        ruleId: ruleId,
        moduleId: 'money_saving',
        metadata: {'amountSaved': amountSaved, 'dailyGoal': dailyGoal},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao verificar metas de money saving: $e',
        ruleId: ruleId,
        moduleId: 'money_saving',
      );
    }
  }
}
