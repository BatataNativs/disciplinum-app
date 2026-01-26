import 'dart:io';
import 'package:flutter/foundation.dart';
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

final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    fln.FlutterLocalNotificationsPlugin();

const String actionIdSim = 'CHECKIN_SIM';
const String actionIdNao = 'CHECKIN_NAO';

Future<void> initNotifications() async {
  if (kIsWeb) return;

  tz.initializeTimeZones();

  try {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    debugPrint('Erro ao configurar timezone: $e');
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
      debugPrint('Erro ao carregar ícone da notificação: $e');
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
        // REMOVIDO: uiLocalNotificationDateInterpretation
        // Motivo: Não é necessário para Android e estava causando erro de compilação
        // Se precisar dar suporte a iOS no futuro, precisaremos verificar a versão do plugin

        matchDateTimeComponents: fln.DateTimeComponents.time,
        payload: payload,
      );
      debugPrint('Agendado: $title para $scheduledDate (ID: $id)');
    } catch (e) {
      debugPrint('ERRO ao agendar notificação: $e');
      // Dica: Se der erro dizendo que precisa do uiLocalNotificationDateInterpretation em tempo de execução
      // (o que é raro no Android), avise-me. Mas a compilação vai passar agora.
    }
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
}
