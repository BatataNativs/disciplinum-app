import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:disciplinum/core/background/batched_achievement_notifier.dart';
import 'package:disciplinum/core/background/background_retry_handler.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';

// Repositórios de gamificação dos módulos
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/repositories/spending_gamification_repository.dart';
import 'package:disciplinum/features/modules/reading/gamification/data/repositories/reading_gamification_repository.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/repositories/procrastination_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/repositories/adult_content_gamification_repository.dart';

/// Callback dispatcher para tarefas em background
/// Este método é executado em um isolate separado quando o app está fechado
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      LoggerService.instance.i('🔄 Background task executando: $task');

      // Inicializa ObjectBox primeiro (necessário para repositórios e notificações)
      await ObjectBoxService.instance.initialize();

      // Inicializa notificações para poder mostrar em background
      await NotificationService.init();

      switch (task) {
        case 'checkAchievementsTask':
          await _checkAchievementsInBackground();
          break;
        case 'dailyStreakCheckTask':
          await _checkDailyStreaksInBackground();
          break;
        default:
          LoggerService.instance.w('⚠️ Tarefa desconhecida: $task');
      }

      return Future.value(true);
    } catch (e, stackTrace) {
      LoggerService.instance.e('❌ Erro na tarefa background: $task', 
          error: e, 
          stackTrace: stackTrace);
      return Future.value(false);
    }
  });
}

/// Verifica conquistas pendentes em background
Future<void> _checkAchievementsInBackground() async {
  final success = await BackgroundRetryHandler.executeWithRetry(
    () async {
      LoggerService.instance.i('🏆 Verificando conquistas em background...');

      // Inicializa batch notifier para esta execução
      final batchNotifier = BatchedAchievementNotifier();
      batchNotifier.clear(); // Limpa qualquer estado anterior

      // Verifica conquistas de cada módulo ativo
      await _checkSmokingAchievements(batchNotifier);
      await _checkSpendingAchievements(batchNotifier);
      await _checkReadingAchievements(batchNotifier);
      await _checkFocusAchievements(batchNotifier);
      await _checkMoneySavingAchievements(batchNotifier);
      await _checkProcrastinationAchievements(batchNotifier);
      await _checkDietAchievements(batchNotifier);
      await _checkBingeEatingAchievements(batchNotifier);
      await _checkAdultContentAchievements(batchNotifier);

      // Envia todas as notificações pendentes de uma vez (batched)
      await batchNotifier.flush();

      LoggerService.instance.i('✅ Verificação de conquistas concluída');
    },
    maxRetries: 3,
    initialDelay: const Duration(seconds: 1),
    taskName: 'checkAchievements',
  );

  if (!success) {
    LoggerService.instance.e('❌ Falha ao verificar conquistas após múltiplas tentativas');
  }
}

/// Verifica conquistas do módulo Smoking
Future<void> _checkSmokingAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = SmokingGamificationRepository.instance;
    final state = await repository.getSmokingState();

    if (state == null || !state.isModuleActive) return;

    // Verifica se há novas medalhas elegíveis
    final newAchievements = <String>[];

    // Verifica insígnias conquistadas recentemente (últimas 24h)
    final lastCheck = DateTime.now().subtract(const Duration(days: 1));
    if (state.lastPositiveCheckIn != null && 
        state.lastPositiveCheckIn!.isAfter(lastCheck) &&
        state.consecutivePositiveDays > 0) {
      
      // Notifica sobre streak atual
      if (state.consecutivePositiveDays == 7) {
        newAchievements.add('🔥 7 dias sem fumar!');
      } else if (state.consecutivePositiveDays == 30) {
        newAchievements.add('🎉 1 mês sem fumar!');
      } else if (state.consecutivePositiveDays == 100) {
        newAchievements.add('🏆 100 dias sem fumar!');
      }
    }

    // Envia notificações se houver novas conquistas
    for (final achievement in newAchievements) {
      notifier.queueNotification(
        moduleName: 'Smoking',
        achievementType: 'streak',
        title: '🏆 Nova Conquista!',
        body: achievement,
        achievementId: 'smoking_${state.consecutivePositiveDays}',
      );
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Smoking', error: e);
  }
}

/// Verifica conquistas do módulo Spending
Future<void> _checkSpendingAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = SpendingGamificationRepository.instance;
    final state = await repository.getSpendingState();

    if (state == null || !state.isModuleActive) return;

    // Verifica marcos de meses consecutivos
    if (state.consecutiveMonths > 0) {
      final milestones = [3, 6, 12, 24];
      
      for (final milestone in milestones) {
        if (state.consecutiveMonths == milestone) {
          notifier.queueNotification(
            moduleName: 'Spending',
            achievementType: 'milestone',
            title: '💰 Marco Financeiro!',
            body: '$milestone meses com contas em dia!',
            achievementId: 'spending_$milestone',
          );
          break;
        }
      }
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Spending', error: e);
  }
}

/// Verifica conquistas do módulo Reading
Future<void> _checkReadingAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = ReadingGamificationRepository.instance;
    final state = await repository.getReadingState();

    if (state == null || !state.isModuleActive) return;

    // Verifica marcos de streak de leitura
    if (state.consecutiveDays > 0) {
      final milestones = [7, 30, 100, 365];
      
      for (final milestone in milestones) {
        if (state.consecutiveDays == milestone) {
          notifier.queueNotification(
            moduleName: 'Reading',
            achievementType: 'streak',
            title: '📚 Streak de Leitura!',
            body: '$milestone dias consecutivos de leitura!',
            achievementId: 'reading_$milestone',
          );
          break;
        }
      }
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Reading', error: e);
  }
}

/// Verifica conquistas do módulo Focus
Future<void> _checkFocusAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = FocusGamificationRepository.instance;
    final state = await repository.getFocusState();

    if (state == null || !state.isModuleActive) return;

    // Verifica marcos de sessões de foco
    if (state.sessionsCompleted > 0) {
      final milestones = [10, 50, 100, 500];
      
      for (final milestone in milestones) {
        if (state.sessionsCompleted == milestone) {
          notifier.queueNotification(
            moduleName: 'Focus',
            achievementType: 'sessions',
            title: '🎯 Sessões de Foco!',
            body: '$milestone sessões completadas!',
            achievementId: 'focus_sessions_$milestone',
          );
          break;
        }
      }
    }

    // Verifica marcos de horas de foco
    final totalHours = state.totalFocusMinutes ~/ 60;
    if (totalHours > 0) {
      final hourMilestones = [10, 50, 100, 500];
      
      for (final milestone in hourMilestones) {
        if (totalHours == milestone) {
          notifier.queueNotification(
            moduleName: 'Focus',
            achievementType: 'hours',
            title: '⏱️ Horas de Foco!',
            body: '$milestone horas de foco profundo!',
            achievementId: 'focus_hours_$milestone',
          );
          break;
        }
      }
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Focus', error: e);
  }
}

/// Verifica conquistas do módulo Money Saving
Future<void> _checkMoneySavingAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = MoneySavingGamificationRepository.instance;
    final state = await repository.getMoneySavingState();

    if (state == null || !state.isModuleActive) return;

    // Verifica marcos de economia
    if (state.totalSavedAmount > 0) {
      final milestones = [100, 500, 1000, 5000, 10000];
      
      for (final milestone in milestones) {
        if (state.totalSavedAmount >= milestone && state.totalSavedAmount < milestone + 100) {
          notifier.queueNotification(
            moduleName: 'Money Saving',
            achievementType: 'savings',
            title: '💰 Economia Total!',
            body: 'Você economizou R\$ $milestone ou mais!',
            achievementId: 'moneysaving_$milestone',
          );
          break;
        }
      }
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Money Saving', error: e);
  }
}

/// Verifica conquistas do módulo Procrastination
Future<void> _checkProcrastinationAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = ProcrastinationGamificationRepository.instance;
    final state = await repository.getProcrastinationState();

    if (state == null || !state.isModuleActive) return;

    // Verifica marcos de tarefas concluídas
    if (state.totalTasksCompleted > 0) {
      final milestones = [10, 50, 100, 500];
      
      for (final milestone in milestones) {
        if (state.totalTasksCompleted == milestone) {
          notifier.queueNotification(
            moduleName: 'Procrastination',
            achievementType: 'tasks',
            title: '✅ Tarefas Concluídas!',
            body: '$milestone tarefas sem procrastinação!',
            achievementId: 'procrastination_$milestone',
          );
          break;
        }
      }
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Procrastination', error: e);
  }
}

/// Verifica conquistas do módulo Diet
Future<void> _checkDietAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = DietGamificationRepository.instance;
    final state = await repository.getDietState();

    if (state == null || !state.isModuleActive) return;

    // Verifica marcos de refeições saudáveis
    if (state.consecutiveDays > 0) {
      final milestones = [7, 30, 100];
      
      for (final milestone in milestones) {
        if (state.consecutiveDays == milestone) {
          notifier.queueNotification(
            moduleName: 'Diet',
            achievementType: 'streak',
            title: '🥗 Streak Alimentar!',
            body: '$milestone dias de alimentação saudável!',
            achievementId: 'diet_$milestone',
          );
          break;
        }
      }
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Diet', error: e);
  }
}

/// Verifica conquistas do módulo Binge Eating
Future<void> _checkBingeEatingAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = BingeEatingGamificationRepository.instance;
    final state = await repository.getBingeEatingState();

    if (state == null || !state.isModuleActive) return;

    // Verifica marcos de dias sem compulsão
    if (state.consecutivePositiveDays > 0) {
      final milestones = [7, 30, 100];
      
      for (final milestone in milestones) {
        if (state.consecutivePositiveDays == milestone) {
          notifier.queueNotification(
            moduleName: 'Binge Eating',
            achievementType: 'streak',
            title: '🎉 Controle Alimentar!',
            body: '$milestone dias sem compulsão alimentar!',
            achievementId: 'bingeeating_$milestone',
          );
          break;
        }
      }
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Binge Eating', error: e);
  }
}

/// Verifica conquistas do módulo Adult Content
Future<void> _checkAdultContentAchievements(BatchedAchievementNotifier notifier) async {
  try {
    final repository = AdultContentGamificationRepository.instance;
    final state = await repository.getAdultContentState();

    if (state == null || !state.isModuleActive) return;

    // Verifica marcos de dias limpos
    if (state.consecutiveDays > 0) {
      final milestones = [7, 30, 100];
      
      for (final milestone in milestones) {
        if (state.consecutiveDays == milestone) {
          notifier.queueNotification(
            moduleName: 'Adult Content',
            achievementType: 'streak',
            title: '💪 Disciplina Digital!',
            body: '$milestone dias de foco e produtividade!',
            achievementId: 'adultcontent_$milestone',
          );
          break;
        }
      }
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar conquistas Adult Content', error: e);
  }
}

/// Verifica streaks diários em background
Future<void> _checkDailyStreaksInBackground() async {
  final success = await BackgroundRetryHandler.executeWithRetry(
    () async {
      LoggerService.instance.i('🔥 Verificando streaks diários em background...');

      // Inicializa batch notifier para esta execução
      final batchNotifier = BatchedAchievementNotifier();
      batchNotifier.clear();

      // Verifica se há streaks prestes a quebrar (último check-in há mais de 20h)
      await _checkStreaksAboutToBreak();

      // Verifica marcos de streak alcançados
      await _checkStreakMilestones(batchNotifier);

      // Envia notificações pendentes
      await batchNotifier.flush();

      LoggerService.instance.i('✅ Verificação de streaks concluída');
    },
    maxRetries: 3,
    initialDelay: const Duration(seconds: 1),
    taskName: 'checkDailyStreaks',
  );

  if (!success) {
    LoggerService.instance.e('❌ Falha ao verificar streaks após múltiplas tentativas');
  }
}

/// Verifica se há streaks prestes a quebrar
Future<void> _checkStreaksAboutToBreak() async {
  try {
    final warningThreshold = DateTime.now().subtract(const Duration(hours: 20));
    final streaksAtRisk = <String>[];

    // Verifica Smoking
    try {
      final smokingState = await SmokingGamificationRepository.instance.getSmokingState();
      if (smokingState != null && 
          smokingState.isModuleActive && 
          smokingState.consecutivePositiveDays > 0 &&
          (smokingState.lastPositiveCheckIn == null || 
           smokingState.lastPositiveCheckIn!.isBefore(warningThreshold))) {
        streaksAtRisk.add('🔥 Smoking: ${smokingState.consecutivePositiveDays} dias em risco!');
      }
    } catch (_) {}

    // Verifica Reading
    try {
      final readingState = await ReadingGamificationRepository.instance.getReadingState();
      if (readingState != null && 
          readingState.isModuleActive && 
          readingState.consecutiveDays > 0 &&
          (readingState.lastReadingDate == null || 
           readingState.lastReadingDate!.isBefore(warningThreshold))) {
        streaksAtRisk.add('📚 Reading: ${readingState.consecutiveDays} dias em risco!');
      }
    } catch (_) {}

    // Verifica Diet
    try {
      final dietState = await DietGamificationRepository.instance.getDietState();
      if (dietState != null && 
          dietState.isModuleActive && 
          dietState.consecutiveDays > 0 &&
           dietState.lastUpdated.isBefore(warningThreshold)) {
        streaksAtRisk.add('🥗 Diet: ${dietState.consecutiveDays} dias em risco!');
      }
    } catch (_) {}

    // Envia notificação de alerta se houver streaks em risco
    if (streaksAtRisk.isNotEmpty) {
      await NotificationService.showNotification(
        id: 9998,
        title: '⚠️ Streaks em Risco!',
        body: 'Você tem ${streaksAtRisk.length} streak(s) prestes a quebrar. Abra o app para manter!',
        payload: 'streak_warning',
      );
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar streaks em risco', error: e);
  }
}

/// Verifica marcos de streak alcançados
Future<void> _checkStreakMilestones(BatchedAchievementNotifier notifier) async {
  try {
    final milestones = <String, int>{};

    // Verifica Smoking
    try {
      final state = await SmokingGamificationRepository.instance.getSmokingState();
      if (state != null && state.isModuleActive && state.consecutivePositiveDays > 0) {
        final milestoneDays = [7, 30, 100, 365];
        for (final day in milestoneDays) {
          if (state.consecutivePositiveDays == day) {
            milestones['🔥 Smoking'] = day;
            break;
          }
        }
      }
    } catch (_) {}

    // Verifica Reading
    try {
      final state = await ReadingGamificationRepository.instance.getReadingState();
      if (state != null && state.isModuleActive && state.consecutiveDays > 0) {
        final milestoneDays = [7, 30, 100, 365];
        for (final day in milestoneDays) {
          if (state.consecutiveDays == day) {
            milestones['📚 Reading'] = day;
            break;
          }
        }
      }
    } catch (_) {}

    // Notifica sobre marcos alcançados
    for (final entry in milestones.entries) {
      notifier.queueNotification(
        moduleName: entry.key.replaceAll(RegExp(r'[^a-zA-Z ]'), '').trim(), // Remove emojis
        achievementType: 'streak_milestone',
        title: '🎉 Marco Alcançado!',
        body: '${entry.key}: ${entry.value} dias de streak!',
        achievementId: 'streak_milestone_${entry.key}_${entry.value}',
      );
    }

  } catch (e) {
    LoggerService.instance.e('Erro ao verificar marcos de streak', error: e);
  }
}
