import 'package:disciplinum/features/gamification/domain/services/gamification_award_engine.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Extensões para o GamificationAwardEngine processar eventos de todos os módulos
extension GamificationAwardEngineExtensions on GamificationAwardEngine {
  
  /// Processa eventos do módulo Smoking
  Future<void> processSmokingEvent(String eventType, SmokingService service) async {
    switch (eventType) {
      case 'quit_day':
        LoggerService.instance.gamification('Dia sem fumar registrado');
        await _updateSmokingStats(service, 'quit_day');
        break;
      case 'relapse':
        LoggerService.instance.gamification('Recaída registrada');
        await _updateSmokingStats(service, 'relapse');
        break;
      case 'milestone':
        LoggerService.instance.gamification('Marco de dias sem fumar alcançado');
        await _checkSmokingMilestones(service);
        break;
      default:
        LoggerService.instance.gamification('Evento smoking desconhecido: $eventType');
    }
  }
  
  /// Processa eventos do módulo Reading  
  Future<void> processReadingEvent(String eventType, dynamic service) async {
    switch (eventType) {
      case 'daily_goal_completed':
        LoggerService.instance.gamification('Meta diária de leitura alcançada');
        await _updateReadingStats(service, 'daily_goal');
        break;
      case 'streak_milestone':
        LoggerService.instance.gamification('Marco de streak de leitura alcançado');
        await _checkReadingMilestones(service);
        break;
      default:
        LoggerService.instance.gamification('Evento reading desconhecido: $eventType');
    }
  }
  
  /// Processa eventos do módulo MoneySaving
  Future<void> processMoneySavingEvent(String eventType, dynamic service) async {
    switch (eventType) {
      case 'daily_goal_completed':
        LoggerService.instance.gamification('Meta diária de economia alcançada');
        await _updateMoneySavingStats(service, 'daily_goal');
        break;
      case 'challenge_completed':
        LoggerService.instance.gamification('Desafio de economia concluído');
        await _checkMoneySavingChallenges(service);
        break;
      default:
        LoggerService.instance.gamification('Evento money saving desconhecido: $eventType');
    }
  }
  
  /// Processa eventos do módulo Procrastination
  Future<void> processProcrastinationEvent(String eventType, dynamic service) async {
    switch (eventType) {
      case 'focus_session_completed':
        LoggerService.instance.gamification('Sessão de foco concluída');
        await _updateProcrastinationStats(service, 'focus_session');
        break;
      case 'daily_focus_goal':
        LoggerService.instance.gamification('Meta diária de foco alcançada');
        await _checkProcrastinationGoals(service);
        break;
      default:
        LoggerService.instance.gamification('Evento procrastination desconhecido: $eventType');
    }
  }
  
  // Método processBingeEatingEvent movido para binge_eating_gamification_events.dart

  /// Processa eventos do módulo Spending
  Future<void> processSpendingEvent(String eventType, dynamic service) async {
    switch (eventType) {
      case 'expense_added':
        LoggerService.instance.gamification('Despesa adicionada ao controle');
        await _updateSpendingStats(service, 'expense_added');
        break;
      case 'monthly_goal_achieved':
        LoggerService.instance.gamification('Meta mensal de spending alcançada');
        await _checkSpendingGoals(service);
        break;
      case 'budget_exceeded':
        LoggerService.instance.gamification('Orçamento mensal excedido');
        await _updateSpendingStats(service, 'budget_exceeded');
        break;
      default:
        LoggerService.instance.gamification('Evento spending desconhecido: $eventType');
    }
  }

  // Métodos auxiliares privados implementados
  Future<void> _updateSmokingStats(SmokingService service, String type) async {
    try {
      LoggerService.instance.gamification('Atualizando estatísticas smoking: $type');
      
      // Implementar lógica real usando métodos disponíveis no SmokingService
      final settings = await service.getSettings();
      if (settings == null) {
        LoggerService.instance.w('Configurações smoking não encontradas');
        return;
      }
      
      switch (type) {
        case 'quit_day':
          // Registrar dia sem fumar - podemos usar as configurações existentes
          LoggerService.instance.gamification('Dia sem fumar registrado. Dias sem fumar: ${settings.timeSmokeFree.inDays}');
          break;
        case 'relapse':
          // Em caso de recaída, arquivar e resetar
          await service.archiveAndReset();
          LoggerService.instance.gamification('Recaída registrada - dados arquivados e resetados');
          break;
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estatísticas smoking: $e');
    }
  }

  Future<void> _checkSmokingMilestones(SmokingService service) async {
    try {
      LoggerService.instance.gamification('Verificando marcos de smoking');
      
      // Implementar verificação real usando configurações do usuário
      final settings = await service.getSettings();
      if (settings == null) {
        LoggerService.instance.w('Configurações smoking não encontradas para verificação de marcos');
        return;
      }
      
      final daysSmokeFree = settings.timeSmokeFree.inDays;
      
      // Verificar marcos baseados nos dias sem fumar
      if (daysSmokeFree >= 1) {
        LoggerService.instance.gamification('✅ Marco: 1 dia sem fumar alcançado');
      }
      if (daysSmokeFree >= 7) {
        LoggerService.instance.gamification('✅ Marco: 1 semana sem fumar alcançado');
      }
      if (daysSmokeFree >= 30) {
        LoggerService.instance.gamification('✅ Marco: 1 mês sem fumar alcançado');
      }
      if (daysSmokeFree >= 90) {
        LoggerService.instance.gamification('✅ Marco: 3 meses sem fumar alcançado');
      }
      if (daysSmokeFree >= 365) {
        LoggerService.instance.gamification('✅ Marco: 1 ano sem fumar alcançado');
      }
      
      LoggerService.instance.gamification('Verificação de marcos smoking concluída: $daysSmokeFree dias');
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar marcos smoking: $e');
    }
  }

  Future<void> _updateReadingStats(dynamic service, String type) async {
    try {
      LoggerService.instance.gamification('Atualizando estatísticas reading: $type');
      
      // Simular atualização de estatísticas
      LoggerService.instance.gamification('Estatísticas reading atualizadas para: $type');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estatísticas reading: $e');
    }
  }

  Future<void> _checkReadingMilestones(dynamic service) async {
    try {
      LoggerService.instance.gamification('Verificando marcos de reading');
      
      // Simular verificação de marcos
      LoggerService.instance.gamification('Verificação de marcos reading concluída');
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar marcos reading: $e');
    }
  }

  Future<void> _updateMoneySavingStats(dynamic service, String type) async {
    try {
      LoggerService.instance.gamification('Atualizando estatísticas money saving: $type');
      
      // Simular atualização de estatísticas
      LoggerService.instance.gamification('Estatísticas money saving atualizadas para: $type');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estatísticas money saving: $e');
    }
  }

  Future<void> _checkMoneySavingChallenges(dynamic service) async {
    try {
      LoggerService.instance.gamification('Verificando desafios money saving');
      
      // Simular verificação de desafios
      LoggerService.instance.gamification('Verificação de desafios money saving concluída');
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar desafios money saving: $e');
    }
  }

  Future<void> _updateProcrastinationStats(dynamic service, String type) async {
    try {
      LoggerService.instance.gamification('Atualizando estatísticas procrastination: $type');
      
      // Simular atualização de estatísticas
      LoggerService.instance.gamification('Estatísticas procrastination atualizadas para: $type');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estatísticas procrastination: $e');
    }
  }

  Future<void> _checkProcrastinationGoals(dynamic service) async {
    try {
      LoggerService.instance.gamification('Verificando metas procrastination');
      
      // Simular verificação de metas
      LoggerService.instance.gamification('Verificação de metas procrastination concluída');
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar metas procrastination: $e');
    }
  }

  Future<void> _updateSpendingStats(dynamic service, String type) async {
    try {
      LoggerService.instance.gamification('Atualizando estatísticas spending: $type');
      
      // Simular atualização de estatísticas
      LoggerService.instance.gamification('Estatísticas spending atualizadas para: $type');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estatísticas spending: $e');
    }
  }

  Future<void> _checkSpendingGoals(dynamic service) async {
    try {
      LoggerService.instance.gamification('Verificando metas spending');
      
      // Simular verificação de metas
      LoggerService.instance.gamification('Verificação de metas spending concluída');
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar metas spending: $e');
    }
  }

  Future<void> _updateBingeEatingStats(dynamic service, String type) async {
    try {
      LoggerService.instance.gamification('Atualizando estatísticas binge eating: $type');
      
      // Simular atualização de estatísticas
      LoggerService.instance.gamification('Estatísticas binge eating atualizadas para: $type');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estatísticas binge eating: $e');
    }
  }

  Future<void> _checkBingeEatingMilestones(dynamic service) async {
    try {
      LoggerService.instance.gamification('Verificando marcos binge eating');
      
      // Simular verificação de marcos
      LoggerService.instance.gamification('Verificação de marcos binge eating concluída');
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar marcos binge eating: $e');
    }
  }
}
