import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:disciplinum/core/background/background_callback.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';

/// Serviço de background para notificações de conquistas
/// Gerencia tarefas periódicas que verificam conquistas mesmo quando o app está fechado
class BackgroundAchievementService {
  static BackgroundAchievementService? _instance;
  static BackgroundAchievementService get instance => 
      _instance ??= BackgroundAchievementService._internal();

  BackgroundAchievementService._internal();

  bool _isInitialized = false;

  /// Inicializa o serviço de background
  Future<void> initialize() async {
    if (_isInitialized) {
      LoggerService.instance.d('BackgroundAchievementService já inicializado');
      return;
    }

    try {
      LoggerService.instance.i('🚀 Inicializando BackgroundAchievementService...');

      // Inicializa Workmanager com o callback dispatcher
      await Workmanager().initialize(
        callbackDispatcher,
      );

      _isInitialized = true;
      LoggerService.instance.i('✅ BackgroundAchievementService inicializado com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('❌ Erro ao inicializar BackgroundAchievementService',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Agenda verificação periódica de conquistas
  /// 
  /// Frequência: A cada 15 minutos (mínimo permitido pelo Android)
  /// Executa: Verifica se há novas conquistas/medalhas para notificar
  Future<void> scheduleAchievementChecks() async {
    if (!_isInitialized) {
      LoggerService.instance.w('⚠️ BackgroundAchievementService não inicializado');
      return;
    }

    try {
      LoggerService.instance.i('📅 Agendando verificação de conquistas...');

      await Workmanager().registerPeriodicTask(
        'achievement-check-task',
        'checkAchievementsTask',
        frequency: const Duration(minutes: 15), // Mínimo: 15 minutos
        constraints: Constraints(
          networkType: NetworkType.connected, // Requer conexão para sincronizar
          requiresBatteryNotLow: true,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep, // Mantém tarefa existente
      );

      LoggerService.instance.i('✅ Verificação de conquistas agendada (a cada 15 min)');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao agendar verificação de conquistas', error: e);
    }
  }

  /// Agenda verificação diária de streaks
  /// 
  /// Frequência: A cada 6 horas
  /// Executa: Verifica se streaks estão prestes a quebrar e notifica
  Future<void> scheduleStreakChecks() async {
    if (!_isInitialized) {
      LoggerService.instance.w('⚠️ BackgroundAchievementService não inicializado');
      return;
    }

    try {
      LoggerService.instance.i('📅 Agendando verificação de streaks...');

      await Workmanager().registerPeriodicTask(
        'streak-check-task',
        'dailyStreakCheckTask',
        frequency: const Duration(hours: 6), // A cada 6 horas
        constraints: Constraints(
          networkType: null, // Não precisa de internet
          requiresBatteryNotLow: true,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );

      LoggerService.instance.i('✅ Verificação de streaks agendada (a cada 6 horas)');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao agendar verificação de streaks', error: e);
    }
  }

  /// Agenda uma tarefa one-shot imediata para teste
  Future<void> scheduleOneShotTest() async {
    if (!_isInitialized) {
      LoggerService.instance.w('⚠️ BackgroundAchievementService não inicializado');
      return;
    }

    try {
      LoggerService.instance.i('🧪 Agendando tarefa de teste...');

      await Workmanager().registerOneOffTask(
        'test-task',
        'checkAchievementsTask',
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: null,
          requiresBatteryNotLow: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiresCharging: false,
        ),
      );

      LoggerService.instance.i('✅ Tarefa de teste agendada (10 segundos)');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao agendar tarefa de teste', error: e);
    }
  }

  /// Cancela todas as tarefas agendadas
  Future<void> cancelAllTasks() async {
    if (!_isInitialized) return;

    try {
      LoggerService.instance.i('🛑 Cancelando todas as tarefas background...');
      await Workmanager().cancelAll();
      LoggerService.instance.i('✅ Todas as tarefas canceladas');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao cancelar tarefas', error: e);
    }
  }

  /// Cancela tarefa específica
  Future<void> cancelTask(String uniqueName) async {
    if (!_isInitialized) return;

    try {
      LoggerService.instance.i('🛑 Cancelando tarefa: $uniqueName');
      await Workmanager().cancelByUniqueName(uniqueName);
      LoggerService.instance.i('✅ Tarefa $uniqueName cancelada');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao cancelar tarefa $uniqueName', error: e);
    }
  }

  /// Mostra notificação de conquista em background
  /// 
  /// Este método pode ser chamado de dentro das tarefas background
  static Future<void> showAchievementNotification({
    required String title,
    required String body,
    required String achievementId,
  }) async {
    try {
      // Gera ID único baseado no hash do achievementId
      final notificationId = achievementId.hashCode % 10000 + 6000; // Range 6000-16000

      await NotificationService.showNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: 'achievement:$achievementId',
      );

      LoggerService.instance.i('📱 Notificação de conquista enviada: $title');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao mostrar notificação de conquista', error: e);
    }
  }

  /// Mostra notificação de novo marco de streak
  static Future<void> showStreakMilestoneNotification({
    required String moduleName,
    required int days,
  }) async {
    try {
      final notificationId = days.hashCode % 1000 + 7000;

      await NotificationService.showNotification(
        id: notificationId,
        title: '🔥 Novo Marco no $moduleName!',
        body: 'Você atingiu $days dias consecutivos! Continue mantendo sua disciplina!',
        payload: 'streak:$moduleName:$days',
      );

      LoggerService.instance.i('📱 Notificação de streak enviada: $moduleName - $days dias');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao mostrar notificação de streak', error: e);
    }
  }

  /// Mostra notificação de warning de streak prestes a quebrar
  static Future<void> showStreakWarningNotification({
    required String moduleName,
    required int hoursLeft,
  }) async {
    try {
      final notificationId = moduleName.hashCode % 1000 + 8000;

      await NotificationService.showNotification(
        id: notificationId,
        title: '⏰ Não perca sua sequência!',
        body: 'Você tem $hoursLeft horas para manter seu streak no módulo $moduleName!',
        payload: 'streak_warning:$moduleName',
      );

      LoggerService.instance.i('📱 Notificação de warning enviada: $moduleName');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao mostrar notificação de warning', error: e);
    }
  }
}
