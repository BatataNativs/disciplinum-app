import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';

/// Implementação do módulo de disciplina para Adult Content
class AdultContentDisciplineModule extends ModuleDisciplineInterface {
  final AdultContentService _adultContentService;
  final GamificationAwardEngine _awardEngine;
  
  AdultContentDisciplineModule({
    required AdultContentService adultContentService,
    required GamificationAwardEngine awardEngine,
  }) : _adultContentService = adultContentService,
       _awardEngine = awardEngine;

  @override
  String get moduleId => 'adult_content';

  @override
  String get moduleName => 'Adult Content';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      AdultContentBlockRule(_adultContentService, _awardEngine),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }
}

/// Regra específica do módulo Adult Content
class AdultContentBlockRule extends ModuleRule {
  final AdultContentService _adultContentService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  AdultContentBlockRule(this._adultContentService, this._awardEngine);

  @override
  String get ruleId => 'adult_content_block_check';

  @override
  String get ruleName => 'Verificação de Bloqueio Adult';

  @override
  String get description => 
      'Verifica e concede pontos por bloqueio de conteúdo adulto';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'adult_content' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final action = context.getData<String>('action');
      if (action == null) {
        return ModuleDisciplineResult.failure(
          message: 'Ação não especificada',
          ruleId: ruleId,
          moduleId: 'adult_content',
        );
      }

      await _awardEngine.processAdultContentEvent(action, _adultContentService);

      return ModuleDisciplineResult.success(
        message: 'Evento de conteúdo adulto processado: $action',
        ruleId: ruleId,
        moduleId: 'adult_content',
        metadata: {'action': action},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao processar evento de conteúdo adulto: $e',
        ruleId: ruleId,
        moduleId: 'adult_content',
      );
    }
  }
}
