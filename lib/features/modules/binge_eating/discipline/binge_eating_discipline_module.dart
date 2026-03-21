import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine_extensions.dart';

/// Implementação do módulo de disciplina para Binge Eating
class BingeEatingDisciplineModule extends ModuleDisciplineInterface {
  final BingeEatingService _bingeEatingService;
  final GamificationAwardEngine _awardEngine;
  
  BingeEatingDisciplineModule({
    required BingeEatingService bingeEatingService,
    required GamificationAwardEngine awardEngine,
  }) : _bingeEatingService = bingeEatingService,
       _awardEngine = awardEngine;

  @override
  String get moduleId => 'binge_eating';

  @override
  String get moduleName => 'Binge Eating';

  List<ModuleRule>? _rules;

  @override
  List<ModuleRule> get rules => _rules ?? [];

  @override
  Future<void> initializeRules() async {
    _rules = [
      BingeEatingStreakRule(_bingeEatingService, _awardEngine),
      BingeEatingRecoveryRule(_bingeEatingService, _awardEngine),
    ];
  }

  @override
  Future<void> dispose() async {
    _rules?.clear();
    _rules = null;
  }
}

/// Regra para verificar streak de recuperação
class BingeEatingStreakRule extends ModuleRule {
  final BingeEatingService _bingeEatingService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  BingeEatingStreakRule(this._bingeEatingService, this._awardEngine);

  @override
  String get ruleId => 'binge_eating_streak_check';

  @override
  String get ruleName => 'Verificação de Streak - Recuperação';

  @override
  String get description => 
      'Verifica e concede insignias por dias consecutivos sem episódios';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'binge_eating' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final eventType = context.getData<String>('eventType');
      if (eventType == null) {
        return ModuleDisciplineResult.failure(
          message: 'Tipo de evento não especificado',
          ruleId: ruleId,
          moduleId: 'binge_eating',
        );
      }

      // Implementar processBingeEatingEvent no GamificationAwardEngine
      await _awardEngine.processBingeEatingEvent(eventType, _bingeEatingService);
      
      // Por enquanto, apenas logamos o evento
      LoggerService.instance.d('Evento binge eating recebido: $eventType');
      
      // Simula uso dos serviços para evitar warnings
      _bingeEatingService;
      _awardEngine;
      
      return ModuleDisciplineResult.success(
        message: 'Evento de binge eating processado: $eventType',
        ruleId: ruleId,
        moduleId: 'binge_eating',
        metadata: {'eventType': eventType},
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao processar evento de binge eating: $e',
        ruleId: ruleId,
        moduleId: 'binge_eating',
      );
    }
  }
}

/// Regra para verificar marcos de recuperação
class BingeEatingRecoveryRule extends ModuleRule {
  final BingeEatingService _bingeEatingService;
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  BingeEatingRecoveryRule(this._bingeEatingService, this._awardEngine);

  @override
  String get ruleId => 'binge_eating_recovery_check';

  @override
  String get ruleName => 'Verificação de Marcos - Recuperação';

  @override
  String get description => 
      'Verifica e concede pontos por marcos de recuperação alcançados';

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) => _isEnabled = value;

  @override
  bool canExecute(ModuleDisciplineContext context) {
    return context.moduleId == 'binge_eating' && isEnabled;
  }

  @override
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context) async {
    try {
      final daysRecovery = context.getData<int>('daysRecovery') ?? 0;
      
      if (daysRecovery > 0 && daysRecovery % 7 == 0) {
        // Marco a cada 7 dias de recuperação
        await _awardEngine.processBingeEatingEvent('recovery_milestone', _bingeEatingService);
        
        LoggerService.instance.d('Marco de recuperação: $daysRecovery dias');
        
        return ModuleDisciplineResult.success(
          message: 'Marco de recuperação alcançado: $daysRecovery dias',
          ruleId: ruleId,
          moduleId: 'binge_eating',
          metadata: {'daysRecovery': daysRecovery},
        );
      }

      return ModuleDisciplineResult.success(
        message: 'Nenhum marco a verificar',
        ruleId: ruleId,
        moduleId: 'binge_eating',
      );
    } catch (e) {
      return ModuleDisciplineResult.failure(
        message: 'Erro ao verificar marcos de binge eating: $e',
        ruleId: ruleId,
        moduleId: 'binge_eating',
      );
    }
  }
}
