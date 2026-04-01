import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_gamification_events.dart';

/// Implementação do módulo de disciplina para Focus
/// Demonstra como um módulo implementa suas próprias regras
class FocusDisciplineModule extends ModuleDisciplineInterface {
  final FocusGamificationEvents _gamificationEvents;
  
  FocusDisciplineModule({
    required FocusGamificationEvents gamificationEvents,
  }) : _gamificationEvents = gamificationEvents;

  @override
  String get moduleId => 'focus';

  @override
  String get moduleName => 'Focus';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      FocusStreakRule(_gamificationEvents),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }
}

/// Regra específica do módulo Focus para verificação de streak
class FocusStreakRule extends ModuleRule {
  final FocusGamificationEvents _gamificationEvents;
  bool _isEnabled = true;

  FocusStreakRule(this._gamificationEvents);

  @override
  String get ruleId => 'focus_streak_check';

  @override
  String get ruleName => 'Verificação de Streak de Foco';

  @override
  String get description => 
      'Verifica e concede insignias por streaks de foco alcançados';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'focus' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      await _gamificationEvents.processFocusEvent('streak_check');

      return ModuleDisciplineResult.success(
        message: 'Streak de foco verificado com sucesso',
        ruleId: ruleId,
        moduleId: 'focus',
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'service': 'focus_service',
        },
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao verificar streak de foco: $e',
        ruleId: ruleId,
        moduleId: 'focus',
      );
    }
  }
}
