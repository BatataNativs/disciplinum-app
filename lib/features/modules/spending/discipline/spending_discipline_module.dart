import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service_wrapper.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine_extensions.dart';

/// Implementação do módulo de disciplina para Spending
class SpendingDisciplineModule extends ModuleDisciplineInterface {
  final SpendingService _spendingService;
  final GamificationAwardEngine _awardEngine;
  
  SpendingDisciplineModule({
    required SpendingService spendingService,
    required GamificationAwardEngine awardEngine,
  }) : _spendingService = spendingService,
       _awardEngine = awardEngine;

  @override
  String get moduleId => 'spending';

  @override
  String get moduleName => 'Spending';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      SpendingGoalRule(
        spendingService: _spendingService,
        awardEngine: _awardEngine,
      ),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }

  bool get isEnabled => true;

  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final eventType = context.getData<String>('eventType');
      if (eventType == null) {
        return ModuleDisciplineResult.failure(
          message: 'Tipo de evento não especificado',
          ruleId: 'spending_module',
          moduleId: 'spending',
        );
      }

      await _awardEngine.processSpendingEvent(eventType, _spendingService);
      
      LoggerService.instance.d('Evento spending recebido: $eventType');
      
      _spendingService;
      _awardEngine;
      
      return ModuleDisciplineResult.success(
        message: 'Evento de spending processado: $eventType',
        ruleId: 'spending_module',
        moduleId: 'spending',
        metadata: {'eventType': eventType},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao processar evento de spending: $e',
        ruleId: 'spending_module',
        moduleId: 'spending',
      );
    }
  }

  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'spending' && isEnabled;
  }
}

class SpendingGoalRule extends ModuleRule {
  final SpendingService _spendingService;
  final GamificationAwardEngine _awardEngine;
  
  SpendingGoalRule({
    required SpendingService spendingService,
    required GamificationAwardEngine awardEngine,
  }) : _spendingService = spendingService,
       _awardEngine = awardEngine;

  @override
  String get ruleId => 'spending_goal_check';

  @override
  String get ruleName => 'Spending Goal Check';

  @override
  String get description => 'Verifica se as metas de spending foram alcançadas';

  bool _isEnabled = true;

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'spending' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final savedAmount = context.getData<double>('savedAmount') ?? 0.0;
      final monthlyGoal = context.getData<double>('monthlyGoal') ?? 100.0;
      
      if (savedAmount >= monthlyGoal) {
        await _awardEngine.processSpendingEvent('monthly_goal_achieved', _spendingService);
        
        LoggerService.instance.d('Meta mensal de spending alcançada: R\$ $savedAmount');
        
        return ModuleDisciplineResult.success(
          message: 'Meta mensal de spending alcançada: R\$ $savedAmount',
          ruleId: ruleId,
          moduleId: 'spending',
          metadata: {'savedAmount': savedAmount, 'monthlyGoal': monthlyGoal},
        );
      }

      return ModuleDisciplineResult.success(
        message: 'Meta mensal não alcançada ainda',
        ruleId: ruleId,
        moduleId: 'spending',
        metadata: {'savedAmount': savedAmount, 'monthlyGoal': monthlyGoal},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao verificar meta de spending: $e',
        ruleId: ruleId,
        moduleId: 'spending',
      );
    }
  }
}
