import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// Mantive o alias 'fln' para segurança
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:disciplinum/main.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/features/modules/diet/domain/services/meal_tracking_service.dart';

final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    fln.FlutterLocalNotificationsPlugin();

const String actionIdSim = 'CHECKIN_SIM';
const String actionIdNao = 'CHECKIN_NAO';
const String actionIdBingeSim = 'BINGE_CHECKIN_SIM';
const String actionIdBingeNao = 'BINGE_CHECKIN_NAO';

Future<void> initNotifications() async {
  if (kIsWeb) return;

  tz.initializeTimeZones();

  try {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    LoggerService.instance.e('Erro ao configurar timezone', error: e);
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  }

  const fln.AndroidInitializationSettings initializationSettingsAndroid =
      fln.AndroidInitializationSettings('@mipmap/launcher_icon');

  const fln.InitializationSettings initializationSettings =
      fln.InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
      if (response.actionId == actionIdNao) {
        NotificationService.onRelapseDetected?.call(response.payload);
      }

      if (response.actionId == actionIdSim) {
        NotificationService.onCheckInSim?.call(response.payload);
      }

      // Actions para check-in do módulo Compulsão Alimentar
      if (response.actionId == actionIdBingeSim) {
        NotificationService.onBingeCheckInSim?.call(response.payload);
      }

      if (response.actionId == actionIdBingeNao) {
        NotificationService.onBingeRelapseDetected?.call(response.payload);
      }

      // NOVO: Handlers para notificações de insígnias
      if (response.actionId == 'view_insignia') {
        // Abrir home e exibir insígnia conquistada
        navigatorKey.currentState?.pushNamed(AppRouter.home);
        // Cancelar notificação também ao clicar "Ver no app"
        // ID da notificação de insígnia é 5000 + index, mas não temos acesso ao index aqui
        // Então vamos cancelar todas as notificações de insígnias (5000-5010)
        for (int i = 0; i < 15; i++) {
          flutterLocalNotificationsPlugin.cancel(5000 + i);
        }
      }
      
      if (response.actionId == 'dismiss_insignia') {
        // Apenas fechar notificação (já foi tratada pelo addPendingInsignia)
        // Cancelar todas as notificações de insígnias
        for (int i = 0; i < 15; i++) {
          flutterLocalNotificationsPlugin.cancel(5000 + i);
        }
      }

      // Lógica para abrir módulo de Procrastinação na aba correta (Check-in Diário)
      if (response.payload == 'procrastination_checkin' ||
          response.actionId == 'ver_itens') {
        final niche = NicheRepository.getById(NicheId.procrastination);
        navigatorKey.currentState?.pushNamed(
          AppRouter.nicheDetail,
          arguments: {
            'niche': niche,
            'initialTabIndex': 2, // Aba Ativar Módulo (ou tarefas)
          },
        );
      }

      // Lógica para abrir módulo de Leitura
      if (response.payload == 'reading' || response.actionId == 'reading_log') {
        final niche = NicheRepository.getById(NicheId.reading);
        navigatorKey.currentState?.pushNamed(
          AppRouter.nicheDetail,
          arguments: {
            'niche': niche,
            'initialTabIndex': 1, // Aba Minha Estante
          },
        );
      }

      // Lógica para fechar a notificação de leitura (ID 9000)
      if (response.actionId == 'reading_skip') {
        flutterLocalNotificationsPlugin.cancel(9000);
      }

      // Lógica para ações rápidas de TAREFAS de Procrastinação
      if (response.payload != null && response.payload!.startsWith('task_')) {
        final actionId = response.actionId;
        if (actionId == 'done' ||
            actionId == 'delete' ||
            actionId == 'postpone') {
          // Usa o Singleton para processar a ação
          ProcrastinationService.instance
              .handleNotificationAction(actionId!, response.payload!);
        }
      }

      // Lógica para ações rápidas de DIETA (refeições)
      if (response.payload != null &&
          response.payload!.startsWith('diet_meal_')) {
        final mealTime = response.payload!.replaceFirst('diet_meal_', '');
        if (response.actionId == 'DIET_SIM') {
          MealTrackingService.instance.recordMeal(mealTime, done: true);
        } else if (response.actionId == 'DIET_NAO') {
          MealTrackingService.instance.recordMeal(mealTime, done: false);
        }
      }
    },
  );

  final prefs = await SharedPreferences.getInstance();
  NotificationService.soundEnabled =
      prefs.getBool('settings_sound_enabled') ?? true;
}

Future<bool> requestNotificationPermissionIfNeeded() async {
  if (kIsWeb) return false;

  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    final granted = await androidPlugin.requestNotificationsPermission();
    await androidPlugin.requestExactAlarmsPermission();
    return granted ?? false;
  }
  return false;
}

Future<void> sendModuleNotification(String body,
    {String title = 'Atenção',
    String? iconPath,
    List<fln.AndroidNotificationAction>? actions,
    String? payload,
    int id = 0}) async {
  if (kIsWeb) return;

  fln.AndroidBitmap<Uint8List>? largeIcon;
  if (iconPath != null) {
    try {
      final ByteData data = await rootBundle.load(iconPath);
      largeIcon = fln.ByteArrayAndroidBitmap(data.buffer.asUint8List());
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar ícone da notificação', error: e);
    }
  }

  final androidPlatformChannelSpecifics = fln.AndroidNotificationDetails(
    'disciplinum_channel',
    'Disciplinum Notificações',
    channelDescription: 'Notificações de disciplina e monitoramento',
    importance: fln.Importance.max,
    priority: fln.Priority.high,
    showWhen: true,
    playSound: NotificationService.soundEnabled,
    enableVibration: true,
    largeIcon: largeIcon,
    styleInformation: fln.BigTextStyleInformation(body),
    actions: actions,
  );

  final platformChannelSpecifics =
      fln.NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

class NotificationService {
  static bool soundEnabled = true;
  static void Function(String?)? onRelapseDetected;
  static void Function(String?)? onCheckInSim;
  static void Function(String?)? onBingeRelapseDetected;
  static void Function(String?)? onBingeCheckInSim;

  static Future<void> init() async => initNotifications();

  static Future<bool> requestPermission() async =>
      await requestNotificationPermissionIfNeeded();

  static Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_sound_enabled', value);
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required TimeOfDay time,
    required String body,
    String title = 'Lembrete Diário',
    String? payload,
    List<fln.AndroidNotificationAction>? actions,
  }) async {
    if (kIsWeb) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidPlatformChannelSpecifics = fln.AndroidNotificationDetails(
      'disciplinum_scheduled',
      'Lembretes Agendados',
      channelDescription: 'Notificações agendadas (Frases, Check-in)',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      playSound: soundEnabled,
      styleInformation: fln.BigTextStyleInformation(body),
      actions: actions,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        fln.NotificationDetails(android: androidPlatformChannelSpecifics),
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: fln.DateTimeComponents.time,
        payload: payload,
      );
      LoggerService.instance.d('Agendado: $title para $scheduledDate (ID: $id)');
    } catch (e) {
      LoggerService.instance.e('ERRO ao agendar notificação', error: e);
    }
  }

  static Future<void> scheduleWeeklyNotification({
    required int id,
    required int dayOfWeek, // 1 (Segunda) a 7 (Domingo)
    required TimeOfDay time,
    required String body,
    String title = 'Lembrete Semanal',
    String? payload,
  }) async {
    if (kIsWeb) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidPlatformChannelSpecifics = fln.AndroidNotificationDetails(
      'disciplinum_scheduled',
      'Lembretes Agendados',
      channelDescription: 'Notificações agendadas (Frases, Check-in)',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      playSound: soundEnabled,
      styleInformation: fln.BigTextStyleInformation(body),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      fln.NotificationDetails(android: androidPlatformChannelSpecifics),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: fln.DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
    LoggerService.instance.d('Agendado Semanal: $title para $scheduledDate (ID: $id)');
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    List<fln.AndroidNotificationAction>? actions,
  }) async {
    if (kIsWeb) return;

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (tzScheduledDate.isBefore(now)) return;

    final androidPlatformChannelSpecifics = fln.AndroidNotificationDetails(
      'disciplinum_tasks',
      'Tarefas e Lembretes',
      channelDescription: 'Notificações de tarefas individuais',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      playSound: soundEnabled,
      styleInformation: fln.BigTextStyleInformation(body),
      actions: actions,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      fln.NotificationDetails(android: androidPlatformChannelSpecifics),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
    LoggerService.instance.d('Agendado Único: $title para $tzScheduledDate (ID: $id)');
  }

  static Future<void> scheduleMonthlyNotification({
    required int id,
    required int dayOfMonth, // 1 a 31
    required TimeOfDay time,
    required String body,
    String title = 'Lembrete Mensal',
    String? payload,
  }) async {
    if (kIsWeb) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      dayOfMonth,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 30));
      scheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        dayOfMonth,
        time.hour,
        time.minute,
      );
    }

    final androidPlatformChannelSpecifics = fln.AndroidNotificationDetails(
      'disciplinum_scheduled',
      'Lembretes Agendados',
      channelDescription: 'Notificações agendadas (Frases, Check-in)',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      playSound: soundEnabled,
      styleInformation: fln.BigTextStyleInformation(body),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      fln.NotificationDetails(android: androidPlatformChannelSpecifics),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: fln.DateTimeComponents.dayOfMonthAndTime,
      payload: payload,
    );
    LoggerService.instance.d('Agendado Mensal: $title para $scheduledDate (ID: $id)');
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> openNotificationSettings() async {
    if (kIsWeb || !Platform.isAndroid) return;

    const packageName = 'com.disciplinum.app';

    try {
      final intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: <String, dynamic>{
          'android.provider.extra.APP_PACKAGE': packageName,
        },
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (_) {
      final fallback = AndroidIntent(
        action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
        data: 'package:$packageName',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await fallback.launch();
    }
  }

  /// Envia notificação de check-in para o módulo Compulsão Alimentar
  static Future<void> sendBingeCheckinNotification({
    String title = 'Check-in Diário',
    String body = 'Você resistiu às tentações de delivery hoje?',
    String? iconPath,
    int id = 3000,
  }) async {
    if (kIsWeb) return;

    final actions = [
      const fln.AndroidNotificationAction(
        actionIdBingeSim,
        'Resisti às tentações',
        showsUserInterface: true,
        cancelNotification: true,
      ),
      const fln.AndroidNotificationAction(
        actionIdBingeNao,
        'Não resisti',
        showsUserInterface: true,
        cancelNotification: true,
      ),
    ];

    final androidDetails = fln.AndroidNotificationDetails(
      'binge_checkin_channel',
      'Check-in Compulsão Alimentar',
      channelDescription:
          'Notificações de check-in diário para controle de compulsão alimentar',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      enableVibration: true,
      playSound: soundEnabled,
      actions: actions,
      styleInformation: fln.BigTextStyleInformation(body),
    );

    final platformDetails = fln.NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: 'binge_checkin',
    );
  }
}
