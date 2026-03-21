import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine_extensions.dart';

/// Implementação do módulo de disciplina para Reading
class ReadingDisciplineModule extends ModuleDisciplineInterface {
  final ReadingService _readingService;
  final GamificationAwardEngine _awardEngine;
  
  ReadingDisciplineModule({
    required ReadingService readingService,
    required GamificationAwardEngine awardEngine,
  }) : _readingService = readingService,
       _awardEngine = awardEngine;

  @override
  String get moduleId => 'reading';

  @override
  String get moduleName => 'Reading';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      ReadingStreakRule(_readingService, _awardEngine),
      ReadingGoalRule(_readingService, _awardEngine),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }
}

/// Regra para verificar streak de leitura
class ReadingStreakRule extends ModuleRule {
  final ReadingService _readingService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  ReadingStreakRule(this._readingService, this._awardEngine);

  @override
  String get ruleId => 'reading_streak_check';

  @override
  String get ruleName => 'Verificação de Streak - Leitura';

  @override
  String get description => 
      'Verifica e concede insignias por dias consecutivos de leitura';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'reading' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final eventType = context.getData<String>('eventType');
      if (eventType == null) {
        return ModuleDisciplineResult.failure(
          message: 'Tipo de evento não especificado',
          ruleId: ruleId,
          moduleId: 'reading',
        );
      }

      // Implementar processReadingEvent no GamificationAwardEngine
      await _awardEngine.processReadingEvent(eventType, _readingService);
      
      LoggerService.instance.d('Evento reading recebido: $eventType');
      
      _readingService;
      _awardEngine;
      
      return ModuleDisciplineResult.success(
        message: 'Evento de reading processado: $eventType',
        ruleId: ruleId,
        moduleId: 'reading',
        metadata: {'eventType': eventType},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao processar evento de reading: $e',
        ruleId: ruleId,
        moduleId: 'reading',
      );
    }
  }
}

/// Regra para verificar metas de leitura
class ReadingGoalRule extends ModuleRule {
  final ReadingService _readingService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  ReadingGoalRule(this._readingService, this._awardEngine);

  @override
  String get ruleId => 'reading_goal_check';

  @override
  String get ruleName => 'Verificação de Metas - Leitura';

  @override
  String get description => 
      'Verifica e concede pontos por metas de leitura alcançadas';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'reading' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final pagesRead = context.getData<int>('pagesRead') ?? 0;
      final dailyGoal = context.getData<int>('dailyGoal') ?? 20;
      
      if (pagesRead >= dailyGoal) {
        // Meta diária alcançada
        // Implementar processReadingEvent no GamificationAwardEngine
        await _awardEngine.processReadingEvent('daily_goal_completed', _readingService);
        
        LoggerService.instance.d('Meta diária de leitura alcançada: $pagesRead páginas');
        
        return ModuleDisciplineResult.success(
          message: 'Meta diária de leitura alcançada: $pagesRead páginas',
          ruleId: ruleId,
          moduleId: 'reading',
          metadata: {'pagesRead': pagesRead, 'dailyGoal': dailyGoal},
        );
      }

      return ModuleDisciplineResult.success(
        message: 'Meta diária não alcançada ainda',
        ruleId: ruleId,
        moduleId: 'reading',
        metadata: {'pagesRead': pagesRead, 'dailyGoal': dailyGoal},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao verificar metas de reading: $e',
        ruleId: ruleId,
        moduleId: 'reading',
      );
    }
  }
}
