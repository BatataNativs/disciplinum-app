import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart' show rootBundle;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String actionIdSim = 'CHECKIN_SIM';
const String actionIdNao = 'CHECKIN_NAO';

Future<void> initNotifications() async {
  if (kIsWeb) return;

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.actionId == actionIdNao) {
        // Handle relapse via global handler
        NotificationService.onRelapseDetected?.call(response.payload);
      }
    },
  );

  // Load implementation
  final prefs = await SharedPreferences.getInstance();
  NotificationService.soundEnabled =
      prefs.getBool('settings_sound_enabled') ?? true;
}

/// Solicita permissão SOMENTE quando ativar o módulo de notificações!
Future<bool> requestNotificationPermissionIfNeeded() async {
  if (kIsWeb) return false;

  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin != null) {
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }
  return false;
}

/// Envia uma notificação local imediata (ex: quando o módulo é ativado)
Future<void> sendModuleNotification(String body,
    {String title = 'Atenção',
    String? iconPath,
    List<AndroidNotificationAction>? actions,
    String? payload,
    int id = 0}) async {
  if (kIsWeb) return;

  AndroidBitmap<Uint8List>? largeIcon;
  if (iconPath != null) {
    try {
      final ByteData data = await rootBundle.load(iconPath);
      largeIcon = ByteArrayAndroidBitmap(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('Erro ao carregar ícone da notificação: $e');
    }
  }

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'disciplinum_channel',
    'Disciplinum Notificações',
    channelDescription: 'Notificações de disciplina e monitoramento',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    playSound: NotificationService.soundEnabled,
    enableVibration: true,
    largeIcon: largeIcon, // Adiciona o ícone do nicho
    styleInformation: BigTextStyleInformation(body),
    actions: actions,
  );

  final platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id, // Usa o ID passado ou 0 (default)
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

class NotificationService {
  static bool soundEnabled = true;
  static void Function(String?)? onRelapseDetected;

  /// Inicializa o plugin (se quiser chamar via classe)
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
  }) async {
    if (kIsWeb) return;
    // Futuro: implementar agendamento com zonedSchedule
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Abre as configurações de notificações do app Android
  static Future<void> openNotificationSettings() async {
    if (kIsWeb || !Platform.isAndroid) return;

    const packageName = 'com.disciplinum.app';

    try {
      // Android 8.0+ – tela de notificações do app
      final intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: <String, dynamic>{
          'android.provider.extra.APP_PACKAGE': packageName,
        },
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (_) {
      // Fallback garantido: tela de detalhes do app
      final fallback = AndroidIntent(
        action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
        data: 'package:$packageName',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await fallback.launch();
    }
  }
}
