import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';

/// Implementação do módulo de disciplina para Diet
class DietDisciplineModule extends ModuleDisciplineInterface {
  final DietService _dietService;
  final GamificationAwardEngine _awardEngine;
  
  DietDisciplineModule({
    required DietService dietService,
    required GamificationAwardEngine awardEngine,
  }) : _dietService = dietService,
       _awardEngine = awardEngine;

  @override
  String get moduleId => 'diet';

  @override
  String get moduleName => 'Diet';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      DietGoalRule(_dietService, _awardEngine),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }
}

/// Regra específica do módulo Diet
class DietGoalRule extends ModuleRule {
  final DietService _dietService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  DietGoalRule(this._dietService, this._awardEngine);

  @override
  String get ruleId => 'diet_goal_check';

  @override
  String get ruleName => 'Verificação de Metas de Dieta';

  @override
  String get description => 
      'Verifica e concede pontos por metas de dieta alcançadas';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'diet' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final eventType = context.getData<String>('eventType');
      if (eventType == null) {
        return ModuleDisciplineResult.failure(
          message: 'Tipo de evento não especificado',
          ruleId: ruleId,
          moduleId: 'diet',
        );
      }

      await _awardEngine.processDietEvent(eventType, _dietService);

      return ModuleDisciplineResult.success(
        message: 'Evento de dieta processado: $eventType',
        ruleId: ruleId,
        moduleId: 'diet',
        metadata: {'eventType': eventType},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao processar evento de dieta: $e',
        ruleId: ruleId,
        moduleId: 'diet',
      );
    }
  }
}
