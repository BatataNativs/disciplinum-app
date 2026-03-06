import 'dart:async';
import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/gamification/gamification_messages.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';

class AppMonitoringService {
  static final AppMonitoringService _instance =
      AppMonitoringService._internal();
  static AppMonitoringService get instance => _instance;

  AppMonitoringService._internal();

  // ID para a notificação persistente (Serviço de Primeiro Plano)
  static const int _foregroundServiceId = 888;
  static const String _prefsActiveNicheKey = 'active_niche_id';

  bool _isModuleActive = false;
  Timer? _monitorTimer;
  List<String> monitoredApps = [];
  bool notificationsPaused = false;

  final Map<String, DateTime> _violationStartByApp = {};
  final Map<String, DateTime> _warnedApps = {};
  final Map<String, DateTime> _lastSeenMonitoredApp = {};
  DateTime _lastHeartbeatSave = DateTime.fromMillisecondsSinceEpoch(0);
  NicheId? currentNicheId;

  bool get isActive => _isModuleActive;

  void setNotificationsPaused(bool value) async {
    notificationsPaused = value;
    if (value) {
      _violationStartByApp.clear();
      _warnedApps.clear();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_notifications_paused', value);
  }

  Future<void> startMonitoring({
    required NicheId nicheId,
    required List<String> apps,
  }) async {
    _isModuleActive = true;
    currentNicheId = nicheId;
    monitoredApps = apps;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsActiveNicheKey, nicheId.id);

    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();

    await _startForegroundService();
    await _checkRetroactiveViolations(nicheId);

    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(const Duration(seconds: 2), _monitorLoop);
  }

  void stopMonitoring() async {
    _isModuleActive = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();
    monitoredApps.clear();
    currentNicheId = null;
    notificationsPaused = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsActiveNicheKey);

    await _stopForegroundService();
  }

  void _monitorLoop(Timer timer) async {
    try {
      if (!_isModuleActive) {
        timer.cancel();
        return;
      }

      await _saveHeartbeat();

      // O GamificationService ainda precisa rodar o loop de progresso (dias consecutivos)
      // Delegamos isso de volta ou Rodamos aqui se passarmos a referência
      GamificationService.instance.runProgressCheck();

      if (notificationsPaused) {
        _violationStartByApp.clear();
        _warnedApps.clear();
        return;
      }

      final now = DateTime.now();
      final activeNicheId = currentNicheId;
      final apps = List<String>.from(monitoredApps);

      if (apps.isNotEmpty && activeNicheId != null) {
        final nowMs = now.millisecondsSinceEpoch;

        if (activeNicheId == NicheId.focus) {
          if (!GamificationService.instance
              .historyFocusInterval(activeNicheId, now)) {
            _violationStartByApp.clear();
            _warnedApps.clear();
            return;
          }
        }

        final usageApps = await UsageStats.queryUsageStats(
          now.subtract(const Duration(seconds: 60)),
          now,
        );

        final systemIgnoreList = [
          'com.disciplinum.app',
          'com.android.systemui',
          'android',
          'com.sec.android.app.launcher',
          'com.google.android.apps.nexuslauncher',
          'com.miui.home',
          'com.huawei.android.launcher',
        ];

        String? foregroundApp;
        if (usageApps.isNotEmpty) {
          usageApps.sort((a, b) {
            final lastA = int.tryParse(a.lastTimeUsed ?? '0') ?? 0;
            final lastB = int.tryParse(b.lastTimeUsed ?? '0') ?? 0;
            return lastB.compareTo(lastA);
          });

          for (final app in usageApps) {
            final pkg = app.packageName!;
            final lastUsedMs = int.tryParse(app.lastTimeUsed ?? '0') ?? 0;

            if (lastUsedMs < nowMs - 60000) continue;

            if (!systemIgnoreList.contains(pkg)) {
              foregroundApp = pkg;
              break;
            }
          }
        }

        bool isForegroundMonitored =
            foregroundApp != null && apps.contains(foregroundApp);
        bool isForegroundIgnore =
            foregroundApp != null && systemIgnoreList.contains(foregroundApp);
        bool isForegroundOther = foregroundApp != null &&
            !isForegroundMonitored &&
            !isForegroundIgnore;

        if (isForegroundMonitored) {
          final key = foregroundApp;
          _lastSeenMonitoredApp[key] = now;

          if (!_violationStartByApp.containsKey(key)) {
            if (!_warnedApps.containsKey(key)) {
              final niche = NicheRepository.getById(activeNicheId);
              final baseMessage = GamificationMessages.getModuleMessage(
                activeNicheId,
                isUnlocked: IapService().isCustomNotifUnlocked ||
                    GamificationService.instance
                        .isNotificationUnlocked(activeNicheId),
                customMessages: GamificationService.instance.customMessages,
              );
              await GamificationService.instance.sendModuleNotification(
                '$baseMessage\n\n⚠️ Saia do app em até 30s para não perder seu progresso.',
                title: 'Disciplinum: ${niche.name}',
                iconPath: niche.iconPath,
              );
              _warnedApps[key] = now;
              _violationStartByApp[key] = DateTime.now();
            }
          } else {
            final start = _violationStartByApp[key]!;
            final duration = now.difference(start).inSeconds;
            if (duration >= 30) {
              final niche = NicheRepository.getById(activeNicheId);
              await GamificationService.instance.resetMedals(
                activeNicheId,
                notificationTitle: 'Progresso Zerado 😢',
                notificationBody:
                    'Você utilizou o app monitorado por 30 segundos ou mais. Progresso reiniciado.',
                iconPath: niche.iconPath,
                deactivate: true,
              );

              _violationStartByApp.remove(key);
              _warnedApps.remove(key);
            }
          }
        } else if (isForegroundOther) {
          _violationStartByApp.clear();
          _warnedApps.clear();
          _lastSeenMonitoredApp.clear();
        } else {
          final activeKeys = _violationStartByApp.keys.toList();
          for (final key in activeKeys) {
            final lastSeen = _lastSeenMonitoredApp[key];
            if (lastSeen == null) continue;

            final diff = now.difference(lastSeen).inSeconds;
            if (diff >= 60) {
              _violationStartByApp.remove(key);
              _lastSeenMonitoredApp.remove(key);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro no loop de monitoramento: $e');
    }
  }

  Future<void> _startForegroundService() async {
    const androidDetails = AndroidNotificationDetails(
      'disciplinum_monitor_channel',
      'Monitoramento Disciplinum',
      channelDescription: 'Mantém o app ativo para monitorar seus hábitos',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
    );

    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      _foregroundServiceId,
      'Monitoramento Ativo',
      'O Disciplinum está te ajudando a manter bons hábitos e disciplina.',
      details,
    );
  }

  Future<void> _stopForegroundService() async {
    await flutterLocalNotificationsPlugin.cancel(_foregroundServiceId);
  }

  Future<void> _saveHeartbeat() async {
    final now = DateTime.now();
    if (now.difference(_lastHeartbeatSave).inSeconds < 10) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_heartbeat', now.millisecondsSinceEpoch);
    _lastHeartbeatSave = now;
    
    // NOVO: Verificar se período de foco foi concluído
    await _checkFocusPeriodCompletion();
  }

  // NOVO: Verificar conclusão de períodos de foco
  Future<void> _checkFocusPeriodCompletion() async {
    final activeNicheId = currentNicheId;
    if (activeNicheId == null || activeNicheId != NicheId.focus) return;
    
    final gamification = GamificationService.instance;
    final focusInterval = gamification.focusIntervalByModule[activeNicheId];
    if (focusInterval == null) return;
    
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = focusInterval.start.hour * 60 + focusInterval.start.minute;
    final endMinutes = focusInterval.end.hour * 60 + focusInterval.end.minute;
    
    // CORRIGIDO: Verificar se está DENTRO do período de foco (não após)
    final isInsideFocusPeriod = _isInsideFocusPeriod(currentMinutes, startMinutes, endMinutes);
    
    if (!isInsideFocusPeriod) {
      // Se está fora do período, verificar se o período acabou de terminar
      final lastCheckKey = 'last_focus_check_${activeNicheId.id}';
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(lastCheckKey);
      final lastCheckTime = lastCheck != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastCheck)
          : DateTime.now().subtract(const Duration(hours: 24));
      
      // Se verificou há menos de 30 minutos, não precisa verificar novamente
      if (now.difference(lastCheckTime).inMinutes < 30) return;
      
      // Calcular quando o período terminou (se cruzou meia-noite, ajustar)
      DateTime periodEndTime;
      if (startMinutes <= endMinutes) {
        // Período normal (ex: 9:00-17:00)
        periodEndTime = DateTime(
          now.year, now.month, now.day,
          focusInterval.end.hour, focusInterval.end.minute
        );
      } else {
        // Período cruza meia-noite (ex: 22:00-6:00)
        if (currentMinutes < endMinutes) {
          // Ainda no mesmo dia (ex: agora são 5:00, período terminou 6:00)
          periodEndTime = DateTime(
            now.year, now.month, now.day,
            focusInterval.end.hour, focusInterval.end.minute
          );
        } else {
          // Já passou para o próximo dia (ex: agora são 7:00, período terminou 6:00 de hoje)
          periodEndTime = DateTime(
            now.year, now.month, now.day,
            focusInterval.end.hour, focusInterval.end.minute
          ).subtract(const Duration(days: 1));
        }
      }
      
      // Verificar se houve violações DURANTE o período de foco (últimas 2 horas são suficientes)
      final hadViolations = await _hadViolationsInFocusPeriod(
        periodEndTime.subtract(const Duration(hours: 2)),
        periodEndTime,
      );
      
      if (!hadViolations) {
        // Período respeitado! Adicionar contador
        gamification.addRespectedFocusPeriod(activeNicheId);
        debugPrint('✅ Período de foco respeitado! Total: ${gamification.getRespectedFocusPeriods(activeNicheId)}');
      }
      
      // Salvar timestamp desta verificação
      await prefs.setInt(lastCheckKey, now.millisecondsSinceEpoch);
    }
  }
  
  // NOVO: Verificar se está DENTRO do período de foco
  bool _isInsideFocusPeriod(int currentMinutes, int startMinutes, int endMinutes) {
    if (startMinutes <= endMinutes) {
      // Período não cruza meia-noite (ex: 9:00-17:00)
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // Período cruza meia-noite (ex: 22:00-6:00)
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }
  
  // NOVO: Verificar se houve violações em um período
  Future<bool> _hadViolationsInFocusPeriod(DateTime startTime, DateTime endTime) async {
    try {
      final usageApps = await UsageStats.queryUsageStats(startTime, endTime);
      
      for (final usage in usageApps) {
        if (monitoredApps.contains(usage.packageName)) {
          final totalTime = int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0;
          // Se usou app monitorado por mais de 30 segundos, houve violação
          if (totalTime > 30000) { // 30 segundos em milissegundos
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar violações: $e');
    }
    return false;
  }

  Future<void> _checkRetroactiveViolations(NicheId nicheId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastHeartbeat = prefs.getInt('last_heartbeat');
    if (lastHeartbeat == null) return;

    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastHeartbeat);
    final now = DateTime.now();

    if (now.difference(lastTime).inMinutes >= 1) {
      final usageApps = await UsageStats.queryUsageStats(lastTime, now);
      for (final usage in usageApps) {
        if (monitoredApps.contains(usage.packageName)) {
          final lastUsed = int.tryParse(usage.lastTimeUsed ?? '0') ?? 0;
          if (lastUsed > lastHeartbeat) {
            await GamificationService.instance.resetMedals(
              nicheId,
              notificationTitle: 'Progresso Resetado (Offline) 🕵️',
              notificationBody:
                  'Detectamos uso de app selecionado para monitoramento enquanto o Disciplinum estava fechado.',
            );
            return;
          }
        }
      }
    }
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt(_prefsActiveNicheKey);
    if (savedId != null) {
      final nicheId = NicheId.tryFromInt(savedId);
      if (nicheId != null) {
        currentNicheId = nicheId;
        _isModuleActive = true;
        await _startForegroundService();
        _monitorTimer?.cancel();
        _monitorTimer =
            Timer.periodic(const Duration(seconds: 2), _monitorLoop);
      }
    }
  }
}
