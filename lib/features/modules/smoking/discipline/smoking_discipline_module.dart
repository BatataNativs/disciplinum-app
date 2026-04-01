import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_gamification_events.dart';

/// Implementação do módulo de disciplina para Smoking
class SmokingDisciplineModule extends ModuleDisciplineInterface {
  final SmokingGamificationEvents _gamificationEvents;
  
  SmokingDisciplineModule({
    required SmokingGamificationEvents gamificationEvents,
  }) : _gamificationEvents = gamificationEvents;

  @override
  String get moduleId => 'smoking';

  @override
  String get moduleName => 'Smoking';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      SmokingStreakRule(_gamificationEvents),
      SmokingMilestoneRule(_gamificationEvents),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }
}

/// Regra para verificar streak de dias sem fumar
class SmokingStreakRule extends ModuleRule {
  final SmokingGamificationEvents _gamificationEvents;
  bool _isEnabled = true;

  SmokingStreakRule(this._gamificationEvents);

  @override
  String get ruleId => 'smoking_streak_check';

  @override
  String get ruleName => 'Verificação de Streak - Sem Fumar';

  @override
  String get description => 
      'Verifica e concede insignias por dias sem fumar';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'smoking' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final eventType = context.getData<String>('eventType');
      if (eventType == null) {
        return ModuleDisciplineResult.failure(
          message: 'Tipo de evento não especificado',
          ruleId: ruleId,
          moduleId: 'smoking',
        );
      }

      // Implementar processSmokingEvent no serviço local
      await _gamificationEvents.processSmokingEvent(eventType);
      
      // Por enquanto, apenas logamos o evento
      LoggerService.instance.d('Evento smoking recebido: $eventType');
      
      return ModuleDisciplineResult.success(
        message: 'Evento de smoking processado: $eventType',
        ruleId: ruleId,
        moduleId: 'smoking',
        metadata: {'eventType': eventType},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao processar evento de smoking: $e',
        ruleId: ruleId,
        moduleId: 'smoking',
      );
    }
  }
}

/// Regra para verificar marcos de conquista
class SmokingMilestoneRule extends ModuleRule {
  final SmokingGamificationEvents _gamificationEvents;
  bool _isEnabled = true;

  SmokingMilestoneRule(this._gamificationEvents);

  @override
  String get ruleId => 'smoking_milestone_check';

  @override
  String get ruleName => 'Verificação de Marcos - Fumo';

  @override
  String get description => 
      'Verifica e concede pontos por marcos de tempo sem fumar';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'smoking' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      // Lógica específica para verificar marcos de smoking
      final daysWithoutSmoking = context.getData<int>('daysWithoutSmoking') ?? 0;
      
      if (daysWithoutSmoking > 0 && daysWithoutSmoking % 30 == 0) {
        // Marco a cada 30 dias
        await _gamificationEvents.processSmokingEvent('milestone_30_days');
        
        return ModuleDisciplineResult.success(
          message: 'Marco de $daysWithoutSmoking dias sem fumar alcançado',
          ruleId: ruleId,
          moduleId: 'smoking',
          metadata: {'daysWithoutSmoking': daysWithoutSmoking},
        );
      }

      return ModuleDisciplineResult.success(
        message: 'Nenhum marco a verificar',
        ruleId: ruleId,
        moduleId: 'smoking',
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao verificar marcos de smoking: $e',
        ruleId: ruleId,
        moduleId: 'smoking',
      );
    }
  }
}
