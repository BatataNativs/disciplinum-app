import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/presentation/providers/money_saving_gamification_provider.dart';

/// Engine de gamificação para Money Saving usando providers locais
class GamificationAwardEngine {
  final ProviderContainer _container;
  
  GamificationAwardEngine(this._container);
  
  /// Processa eventos de money saving e concede recompensas
  void processMoneySavingEvent(String eventType) async {
    try {
      final service = _container.read(moneySavingGamificationProvider);
      
      // Usar processModuleEvent que é o método público disponível
      switch (eventType) {
        case 'deposit':
          await service.processModuleEvent({'type': 'daily_save', 'amount': 10.0});
          LoggerService.instance.i('Depósito processado para gamificação');
          break;
        case 'challenge_completed':
          await service.processModuleEvent({'type': 'goal_completed', 'goalAmount': 100.0});
          LoggerService.instance.i('Desafio completado processado');
          break;
        case 'streak_maintained':
          await service.processModuleEvent({'type': 'streak_update', 'streakDays': 1});
          LoggerService.instance.i('Streak mantido processado');
          break;
        default:
          LoggerService.instance.d('Evento desconhecido: $eventType');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao processar evento money saving', error: e);
    }
  }
}

/// Implementação do módulo de disciplina para Money Saving
class MoneySavingDisciplineModule {
  MoneySavingDisciplineModule();

  String get moduleId => 'money_saving';
  String get moduleName => 'Money Saving';
  List<ModuleRule> get rules => []; // Regras serão adicionadas conforme necessário

  Future<void> initializeRules() async {
    LoggerService.instance.i('MoneySavingDisciplineModule inicializado');
  }

  Future<void> dispose() async {
    LoggerService.instance.i('MoneySavingDisciplineModule disposed');
  }
}

/// Regra para verificar streak de economia
class MoneySavingStreakRule extends ModuleRule {
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  MoneySavingStreakRule(this._awardEngine);

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

      // Processa evento usando o GamificationAwardEngine
      _awardEngine.processMoneySavingEvent(eventType);
      
      // Log do evento processado
      LoggerService.instance.d('Evento money saving processado: $eventType');
      
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
  final GamificationAwardEngine _awardEngine;
  bool _isEnabled = true;

  MoneySavingGoalRule(this._awardEngine);

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
        // Meta diária alcançada - processa recompensa
        _awardEngine.processMoneySavingEvent('challenge_completed');
        
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
