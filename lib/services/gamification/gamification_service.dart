import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:async';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import '../cloud/cloud_sync_service.dart';
import '../iap/iap_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';

// Mensagens por módulo
final Map<NicheId, String> moduleMessages = {
  NicheId.smoking:
      '⚠️ Seja forte! Uma tragada a menos hoje são mais dias de vida amanhã.',
  NicheId.bingeEating:
      '🥑 Seja forte! Resista hoje e terá mais saúde amanhã (além de economizar dinheiro!).',
  NicheId.diet:
      '🍎 Seja forte! A regularidade é a chave. Mantenha sua dieta e verá os resultados!',
  NicheId.spending:
      '💲 Uma comprinha agora é realmente necessária? Pense bem antes de gastar!',
  NicheId.focus:
      '⏳ Atenção aos objetivos. Mantenha o foco e a disciplina para alcançar seu objetivo!',
  NicheId.adultContent:
      '🔞 Vai fazer isso mesmo? Cuidado com os efeitos negativos a longo prazo!',
};

String getModuleMessage(NicheId nicheId, {bool allowCustom = true}) {
  if (allowCustom) {
    if (IapService().isCustomNotifUnlocked) {
      final custom = GamificationService.instance.customMessages[nicheId];
      if (custom != null && custom.isNotEmpty) return custom;
    }
  }
  return moduleMessages[nicheId] ?? 'Conquista em progresso!';
}

enum GamificationMedal { bronze, prata, ouro, diamante }

extension GamificationMedalExtension on GamificationMedal {
  String get nameBr {
    switch (this) {
      case GamificationMedal.bronze:
        return 'Bronze';
      case GamificationMedal.prata:
        return 'Prata';
      case GamificationMedal.ouro:
        return 'Ouro';
      case GamificationMedal.diamante:
        return 'Diamante';
    }
  }

  String get asset {
    switch (this) {
      case GamificationMedal.bronze:
        return 'assets/medal_bronze.png';
      case GamificationMedal.prata:
        return 'assets/medal_silver.png';
      case GamificationMedal.ouro:
        return 'assets/medal_gold.png';
      case GamificationMedal.diamante:
        return 'assets/medal_diamond.png';
    }
  }
}

class GamificationService extends ChangeNotifier {
  // Singleton pattern
  static final GamificationService _instance = GamificationService._internal();
  static GamificationService get instance => _instance;

  factory GamificationService() => _instance;

  GamificationService._internal() {
    _loadPreferences();
    NotificationService.onRelapseDetected = _handleRelapseFromNotification;
  }

  // Cache local das medalhas e dias
  final Map<NicheId, GamificationMedal> _maxMedalByModule = {};
  final Map<NicheId, int> _diasConsecutivosByModule = {};
  final Map<NicheId, DateTime> _moduleStartDates = {};
  final Map<NicheId, String> _customMessages = {};
  final Map<NicheId, List<String>> _customPhrases =
      {}; // Novas frases múltiplas

  Map<NicheId, String> get customMessages => _customMessages;
  Map<NicheId, List<String>> get customPhrases => _customPhrases;

  // ID para a notificação persistente (Serviço de Primeiro Plano)
  static const int _foregroundServiceId = 888;
  // Chave para persistência local do nicho ativo
  static const String _prefsActiveNicheKey = 'active_niche_id';

  // Controle de monitoramento
  bool _isModuleActive = false;
  Timer? _monitorTimer;
  List<String> monitoredApps = [];
  bool notificationsPaused = false;
  DateTime? _lastScheduleNotificationTime;
  final Map<String, DateTime> _notifiedSchedules = {};
  final Map<String, DateTime> _violationStartByApp = {};
  final Map<String, DateTime> _warnedApps = {};
  final Map<String, DateTime> _lastSeenMonitoredApp = {};
  NicheId? currentNicheId;

  void _handleRelapseFromNotification(String? payload) {
    NicheId? nicheId;
    if (payload != null) {
      nicheId = NicheId.values.firstWhere(
        (e) => e.id.toString() == payload,
        orElse: () => NicheId.smoking,
      );
    } else {
      nicheId = currentNicheId;
    }

    if (nicheId == NicheId.smoking) {
      final niche = NicheRepository.getById(nicheId!);
      resetMedals(
        nicheId,
        notificationTitle: 'Recaída registrada 😟',
        notificationBody:
            'Sua contagem foi zerada e o módulo desativado. Confira no app o quanto economizou nessa tentativa!',
        iconPath: niche.iconPath,
        deactivate: true, // Desativa ao ter recaída (Solicitação do usuário)
      );
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsPaused =
        prefs.getBool('settings_notifications_paused') ?? false;

    // Carrega mensagens customizadas
    for (final niche in NicheId.values) {
      final msg = prefs.getString('custom_msg_${niche.id}');
      if (msg != null) _customMessages[niche] = msg;

      // Carrega frases motivacionais múltiplas
      final phrasesJson = prefs.getStringList('custom_phrases_${niche.id}');
      if (phrasesJson != null) {
        _customPhrases[niche] = phrasesJson;
      }
    }

    notifyListeners();

    // Tenta restaurar TODOS os módulos ativos e horários
    await _restoreAllActiveModules();
  }

  Future<void> _restoreAllActiveModules() async {
    bool hasActiveSchedule = false;
    for (final nicheId in NicheId.values) {
      final status = await CloudSyncService.loadModuleStatus(nicheId);
      if (status != null && status.isActive) {
        await _syncWithCloud(nicheId);

        // Carrega horários (necessário para o monitoramento de check-in rodar)
        final userTimes =
            await CloudSyncService.loadUserNicheTimes(nicheId: nicheId.id);
        if (userTimes.isNotEmpty) {
          scheduleByModule[nicheId] = userTimes
              .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
              .toList();

          if (nicheId == NicheId.focus &&
              scheduleByModule[nicheId]!.length >= 2) {
            final times = scheduleByModule[nicheId]!;
            focusIntervalByModule[nicheId] =
                TimeOfDayRange(start: times[0], end: times[1]);
          }

          hasActiveSchedule = true;
        }

        // CARREGA MOTIVAÇÕES (ID Virtual: nicheId + 100)
        final motivationTimes = await CloudSyncService.loadUserNicheTimes(
            nicheId: nicheId.id + 100);
        if (motivationTimes.isNotEmpty) {
          motivationSchedulesByModule[nicheId] = motivationTimes
              .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
              .toList();

          // Sincroniza as frases da nuvem para o cache local
          final cloudPhrases = motivationTimes
              .map((t) => t.phrase ?? '')
              .where((p) => p.isNotEmpty)
              .toList();
          if (cloudPhrases.isNotEmpty) {
            _customPhrases[nicheId] = cloudPhrases;
          }

          hasActiveSchedule = true;
        }
      }
    }

    if (hasActiveSchedule && !_isModuleActive) {
      // Inicia o timer global se houver horários ativos
      startMonitoringApps();
    }
  }

  Map<NicheId, List<TimeOfDay>> scheduleByModule = {};
  Map<NicheId, List<TimeOfDay>> motivationSchedulesByModule = {};
  Map<NicheId, TimeOfDayRange> focusIntervalByModule = {};

  bool get isGeneralMonitoringActive => _isModuleActive;
  Map<NicheId, int> get diasConsecutivosByModule => _diasConsecutivosByModule;

  Map<NicheId, String> get medalsByModule {
    return _maxMedalByModule.map((key, value) => MapEntry(key, value.nameBr));
  }

  bool isModuleActive(NicheId nicheId) {
    return _diasConsecutivosByModule.containsKey(nicheId);
  }

  /// Chamado pela tela de configurações para pausar/retomar notificações
  void setNotificationsPaused(bool value) async {
    notificationsPaused = value;

    if (value) {
      _violationStartByApp.clear();
      _warnedApps.clear();
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_notifications_paused', value);
  }

  /// Restaura a sessão de monitoramento se o app foi morto pelo sistema
  Future<void> restoreMonitoringSession() async {
    if (_isModuleActive) return; // Já está rodando

    final prefs = await SharedPreferences.getInstance();

    // --- BLINDAGEM DE SEGURANÇA (NOVO) ---
    // Impede que o monitoramento tente iniciar se o usuário ainda está no Onboarding.
    // Isso evita o pop-up de permissão prematuro.
    final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    if (!seenOnboarding) {
      debugPrint(
          '🛡️ GamificationService: Bloqueando restauração (Onboarding pendente).');
      return;
    }
    // -------------------------------------

    // CORREÇÃO: Usamos getInt pois salvamos o ID numérico do enum
    final savedId = prefs.getInt(_prefsActiveNicheKey);

    if (savedId != null) {
      try {
        final nicheId = NicheId.tryFromInt(savedId);

        if (nicheId == null) {
          debugPrint('Nicho salvo inválido: $savedId');
          await prefs.remove(_prefsActiveNicheKey);
          return;
        }

        debugPrint(
            '🔄 Restaurando sessão de monitoramento para: ${nicheId.name}');

        await _syncWithCloud(nicheId);
        final userApps =
            await CloudSyncService.loadUserNicheApps(nicheId: nicheId);
        final userTimes =
            await CloudSyncService.loadUserNicheTimes(nicheId: nicheId.id);
        final motivationTimes = await CloudSyncService.loadUserNicheTimes(
            nicheId: nicheId.id + 100);

        monitoredApps = userApps.map((a) => a.appPackage).toList();
        scheduleByModule[nicheId] = userTimes
            .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
            .toList();
        motivationSchedulesByModule[nicheId] = motivationTimes
            .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
            .toList();

        await startMonitoringApps(
          nicheId: nicheId,
          horarios: scheduleByModule[nicheId],
        );
      } catch (e) {
        debugPrint('Erro ao restaurar sessão de monitoramento: $e');
        await prefs.remove(_prefsActiveNicheKey);
      }
    }
  }

  Future<void> startMonitoringApps({
    NicheId? nicheId,
    List<TimeOfDay>? horarios,
    TimeOfDayRange? intervaloFoco,
  }) async {
    _isModuleActive = true;

    if (nicheId != null) {
      currentNicheId = nicheId;
      await _syncWithCloud(nicheId);
      if (horarios != null) scheduleByModule[nicheId] = horarios;
      if (intervaloFoco != null) focusIntervalByModule[nicheId] = intervaloFoco;

      // Persistência: Salva o ID (int) nas prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsActiveNicheKey, nicheId.id);
    }

    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();

    await _startForegroundService();

    if (nicheId != null && monitoredApps.isNotEmpty) {
      await _checkRetroactiveViolations(nicheId);
    }

    _monitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        if (!_isModuleActive) {
          timer.cancel();
          return;
        }

        await _saveHeartbeat();

        // Iterar por todos os nichos que possuem progresso ativo
        final activeNiches = _diasConsecutivosByModule.keys.toList();
        for (final activeNicheId in activeNiches) {
          try {
            _checkMidnightUpdate(activeNicheId);
            _checkDailyMotivation(activeNicheId);
          } catch (e) {
            debugPrint('Erro no loop de progresso para $activeNicheId: $e');
          }
        }

        if (notificationsPaused) {
          _violationStartByApp.clear();
          _warnedApps.clear();
          return;
        }

        final now = DateTime.now();

        // 1. LÓGICA DE HORÁRIOS (Para todos os módulos cadastrados)
        if (_lastScheduleNotificationTime == null ||
            now.difference(_lastScheduleNotificationTime!).inSeconds >= 5) {
          final moduleKeys = scheduleByModule.keys.toList();
          for (final nId in moduleKeys) {
            final horarios = scheduleByModule[nId];
            if (horarios != null && horarios.isNotEmpty) {
              for (final t in horarios) {
                DateTime tempoAlvo =
                    DateTime(now.year, now.month, now.day, t.hour, t.minute);
                if (nId == NicheId.diet) {
                  tempoAlvo = tempoAlvo.subtract(const Duration(minutes: 30));
                }

                if (_isSameMinute(now, tempoAlvo)) {
                  final key = '${nId.id}_${t.hour}_${t.minute}';
                  if (!_hasNotifiedToday(key)) {
                    try {
                      final niche = NicheRepository.getAll()
                          .firstWhere((n) => n.id == nId);

                      debugPrint('🔔 Disparando notificação de check-in: $key');

                      if (nId == NicheId.smoking) {
                        debugPrint(
                            '🔔 [Check-in] Enviando check-in para Smoking...');
                        await sendModuleNotification(
                          'Manteve-se disciplinado hoje? \n\nLembre-se de conferir seu progresso no app 🚀.',
                          title: 'Check-in Diário: ${niche.name}',
                          iconPath: niche.iconPath,
                          actions: [
                            const AndroidNotificationAction(actionIdSim, 'Sim!',
                                showsUserInterface: true,
                                cancelNotification: true),
                            const AndroidNotificationAction(
                                actionIdNao, 'Não, tive recaída',
                                showsUserInterface: true,
                                cancelNotification: true),
                          ],
                          payload: nId.id.toString(),
                          id: nId.id + 2000,
                        );
                      } else {
                        debugPrint(
                            '🔔 [Check-in] Enviando notice para ${nId.name}...');
                        await sendModuleNotification(
                          _getModuleMessage(nId),
                          title: 'Disciplinum: ${niche.name}',
                          iconPath: niche.iconPath,
                          id: nId.id + 2000,
                        );
                      }

                      _markAsNotified(key);
                      _lastScheduleNotificationTime = now;
                    } catch (e) {
                      debugPrint('Erro ao enviar notificação de horário: $e');
                    }
                  }
                }
              }
            }
          }

          // 1.2 LÓGICA DE MOTIVAÇÃO (VIRTUAL ID)
          final motivationKeys = motivationSchedulesByModule.keys.toList();
          for (final nId in motivationKeys) {
            final motivHorarios = motivationSchedulesByModule[nId];
            if (motivHorarios != null && motivHorarios.isNotEmpty) {
              for (final t in motivHorarios) {
                DateTime tempoAlvo =
                    DateTime(now.year, now.month, now.day, t.hour, t.minute);

                if (_isSameMinute(now, tempoAlvo)) {
                  final key = 'motiv_${nId.id}_${t.hour}_${t.minute}';
                  if (!_hasNotifiedToday(key)) {
                    try {
                      final niche = NicheRepository.getAll()
                          .firstWhere((n) => n.id == nId);

                      debugPrint('🔔 Disparando motivação: $key');

                      final frase = getMotivationalPhrase(nId, t);
                      await sendModuleNotification(
                        frase,
                        title: 'Disciplinum: ${niche.name}',
                        iconPath: niche.iconPath,
                        id: nId.id + 3000, // Offset diferente para motivação
                      );

                      _markAsNotified(key);
                    } catch (e) {
                      debugPrint('Erro ao enviar notificação de motivação: $e');
                    }
                  }
                }
              }
            }
          }
        }

        // 2. LÓGICA DE APPS PROIBIDOS
        final activeNicheId = currentNicheId;
        final apps = List<String>.from(monitoredApps);

        if (apps.isNotEmpty && activeNicheId != null) {
          final nowMs = now.millisecondsSinceEpoch;
          final usageApps = await UsageStats.queryUsageStats(
            now.subtract(const Duration(seconds: 60)),
            now,
          );

          final systemIgnoreList = [
            'com.disciplinum.app',
            'com.android.systemui',
            'android',
            'com.sec.android.app.launcher', // Samsung Home
            'com.google.android.apps.nexuslauncher', // Pixel Home
            'com.miui.home', // Xiaomi Home
            'com.huawei.android.launcher', // Huawei Home
          ];

          String? foregroundApp;
          if (usageApps.isNotEmpty) {
            usageApps.sort((a, b) {
              final lastA = int.tryParse(a.lastTimeUsed ?? '0') ?? 0;
              final lastB = int.tryParse(b.lastTimeUsed ?? '0') ?? 0;
              return lastB.compareTo(lastA);
            });

            // ESTRATÉGIA DO ÚLTIMO APP REAL:
            // Buscamos o app mais recente que NÃO seja do sistema/launcher.
            // Isso evita que o Samsung Launcher "roube" o foco e cause timeouts falsos.
            for (final app in usageApps) {
              final pkg = app.packageName!;
              final lastUsedMs = int.tryParse(app.lastTimeUsed ?? '0') ?? 0;

              // Se o app é muito antigo (mais de 60s), ignoramos
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
                final baseMessage = getModuleMessage(activeNicheId);
                await sendModuleNotification(
                  '$baseMessage\n\n⚠️ Saia do app em até 30s para não perder seu progresso.',
                  title: 'Disciplinum: ${niche.name}',
                  iconPath: niche.iconPath,
                );
                _warnedApps[key] = now;
                _violationStartByApp[key] = DateTime.now();
                debugPrint('🏁 Contagem iniciada para $key');
              }
            } else {
              final start = _violationStartByApp[key]!;
              final duration = now.difference(start).inSeconds;
              debugPrint('⏳ $key: ${duration}s / 30s');

              if (duration >= 30) {
                debugPrint('🛑 Limite de 30s atingido em $key');
                final niche = NicheRepository.getById(activeNicheId);

                resetMedals(
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
            debugPrint('✅ Saída definitiva (App): $foregroundApp');
            _violationStartByApp.clear();
            _warnedApps.clear();
            _lastSeenMonitoredApp.clear();
          } else {
            // Caso seja Ignore (Launcher/Bixby/Sistema) ou NULL
            // Verificamos se já faz tempo que o app monitorado não aparece
            final activeKeys = _violationStartByApp.keys.toList();
            for (final key in activeKeys) {
              final lastSeen = _lastSeenMonitoredApp[key];
              if (lastSeen == null) continue; // Segurança extra

              final diff = now.difference(lastSeen).inSeconds;
              if (diff >= 20) {
                // Aumentado para 20s para evitar falsos salvamentos por delay do OS
                debugPrint('✅ Saída definitiva (Timeout após ${diff}s): $key');
                _violationStartByApp.remove(key);
                _warnedApps.remove(key);
                _lastSeenMonitoredApp.remove(key);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Erro no loop de monitoramento: $e');
      }
    });
  }

  String _getModuleMessage(NicheId nicheId, {bool allowCustom = true}) {
    if (allowCustom) {
      if (IapService().isCustomNotifUnlocked) {
        final custom = _customMessages[nicheId];
        if (custom != null && custom.isNotEmpty) return custom;
      }
    }
    return moduleMessages[nicheId] ?? 'Conquista em progresso!';
  }

  /// Retorna a frase motivacional para um horário específico
  String getMotivationalPhrase(NicheId nicheId, TimeOfDay time) {
    if (IapService().isMotivationPhrasesUnlocked) {
      final phrases = _customPhrases[nicheId];
      final schedules = motivationSchedulesByModule[nicheId];

      if (phrases != null && schedules != null && phrases.isNotEmpty) {
        // Encontra o índice do horário na lista (ordenada de preferência)
        final index = schedules.indexOf(time);
        if (index >= 0 && index < phrases.length) {
          return phrases[index];
        }
      }

      // Fallback para a mensagem customizada única se não houver lista
      final custom = _customMessages[nicheId];
      if (custom != null && custom.isNotEmpty) return custom;
    }

    return moduleMessages[nicheId] ?? 'Mantenha o foco e a disciplina!';
  }

  void stopMonitoringApps() async {
    _isModuleActive = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();
    monitoredApps.clear();
    currentNicheId = null;
    notificationsPaused = false;
    _lastScheduleNotificationTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsActiveNicheKey);

    await _stopForegroundService();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_heartbeat', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _checkRetroactiveViolations(NicheId nicheId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastHeartbeat = prefs.getInt('last_heartbeat');
    if (lastHeartbeat == null) return;

    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastHeartbeat);
    final now = DateTime.now();

    if (now.difference(lastTime).inMinutes >= 1) {
      debugPrint('Checando violações retroativas desde $lastTime');
      final usageApps = await UsageStats.queryUsageStats(lastTime, now);

      for (final usage in usageApps) {
        if (monitoredApps.contains(usage.packageName)) {
          final lastUsed = int.tryParse(usage.lastTimeUsed ?? '0') ?? 0;
          if (lastUsed > lastHeartbeat) {
            debugPrint('Violação retroativa detectada em ${usage.packageName}');
            resetMedals(nicheId,
                notificationTitle: 'Progresso Resetado (Offline) 🕵️',
                notificationBody:
                    'Detectamos uso de app selecionado para monitoramento enquanto o Disciplinum estava fechado.');
            return;
          }
        }
      }
    }
  }

  final Map<NicheId, DateTime> _lastMidnightCheckByModule = {};
  void _checkMidnightUpdate(NicheId nicheId) {
    final now = DateTime.now();
    final lastCheck = _lastMidnightCheckByModule[nicheId];
    if (lastCheck != null && lastCheck.day == now.day) {
      return;
    }
    _lastMidnightCheckByModule[nicheId] = now;
    _checkTimeBasedMedals(nicheId);
  }

  Future<void> _syncWithCloud(NicheId nicheId) async {
    final status = await CloudSyncService.loadModuleStatus(nicheId);
    if (status != null) {
      if (!status.isActive) {
        // Se o módulo está inativo na nuvem, garante que não está no cache local
        _diasConsecutivosByModule.remove(nicheId);
        _maxMedalByModule.remove(nicheId);
        _moduleStartDates.remove(nicheId);
      } else {
        _diasConsecutivosByModule[nicheId] = status.consecutiveDays;

        if (status.lastUpdated != null) {
          final lastUpdate = status.lastUpdated!;
          final days = status.consecutiveDays;
          _moduleStartDates[nicheId] =
              lastUpdate.subtract(Duration(days: days));
        } else {
          _moduleStartDates[nicheId] = DateTime.now();
        }

        final medalString = status.maxMedal;
        if (medalString != null) {
          _maxMedalByModule[nicheId] = GamificationMedal.values.firstWhere(
            (e) => e.toString().split('.').last == medalString,
            orElse: () => GamificationMedal.bronze,
          );
        }

        _checkTimeBasedMedals(nicheId);
      }
    } else {
      // Se não tem status, considera inativo/zerado
      _diasConsecutivosByModule.remove(nicheId);
      _moduleStartDates.remove(nicheId);
    }

    notifyListeners();
  }

  void startModuleCycle({required NicheId nicheId}) async {
    _isModuleActive = true;
    await _syncWithCloud(nicheId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsActiveNicheKey, nicheId.id);

    if ((_diasConsecutivosByModule[nicheId] ?? 0) == 0) {
      _moduleStartDates[nicheId] = DateTime.now();
      CloudSyncService.saveModuleStatus(
        nicheId: nicheId,
        isActive: true,
        consecutiveDays: 0,
      );
    }
  }

  void stopModuleCycle({required NicheId nicheId}) async {
    _diasConsecutivosByModule.remove(nicheId);
    scheduleByModule.remove(nicheId);
    CloudSyncService.saveModuleStatus(
      nicheId: nicheId,
      isActive: false,
      consecutiveDays: 0,
    );
    notifyListeners();
  }

  void _checkTimeBasedMedals(NicheId nicheId) {
    final startDate = _moduleStartDates[nicheId];
    if (startDate == null) return;

    final now = DateTime.now();
    final daysActive = now.difference(startDate).inDays;

    if (daysActive <= 0) return;

    if (daysActive != _diasConsecutivosByModule[nicheId]) {
      _updateStatus(nicheId, daysActive);
      _verificaMedalhaDias(nicheId, daysActive);
    }
  }

  void _updateStatus(NicheId nicheId, int dias) {
    _diasConsecutivosByModule[nicheId] = dias;
    CloudSyncService.saveModuleStatus(
      nicheId: nicheId,
      isActive: true,
      consecutiveDays: dias,
    );
    notifyListeners();
  }

  void _verificaMedalhaDias(NicheId nicheId, int dias) {
    GamificationMedal? newMedal;

    if (dias >= 10) {
      newMedal = GamificationMedal.diamante;
    } else if (dias >= 7) {
      newMedal = GamificationMedal.ouro;
    } else if (dias >= 5) {
      newMedal = GamificationMedal.prata;
    } else if (dias >= 3) {
      newMedal = GamificationMedal.bronze;
    }

    final current = _maxMedalByModule[nicheId];
    if (newMedal != null) {
      if (current == null || newMedal.index > current.index) {
        _maxMedalByModule[nicheId] = newMedal;
        CloudSyncService.saveModuleStatus(
          nicheId: nicheId,
          isActive: true,
          maxMedal: newMedal.toString().split('.').last,
        );

        _sendCustomNotification(
          nicheId.id + 900,
          'Nova Medalha Conquistada! 🏆',
          'Parabéns! Você alcançou a medalha de ${newMedal.nameBr} neste módulo.',
        );
        notifyListeners();
      }
    }
  }

  bool _hasNotifiedToday(String key) {
    final last = _notifiedSchedules[key];
    if (last == null) return false;
    return _isSameDay(last, DateTime.now());
  }

  void _markAsNotified(String key) {
    _notifiedSchedules[key] = DateTime.now();
  }

  bool _isSameMinute(DateTime a, DateTime b) =>
      a.hour == b.hour && a.minute == b.minute;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  GamificationMedal? maxMedalForModule(NicheId nicheId) =>
      _maxMedalByModule[nicheId];

  String? currentMedalAsset(NicheId nicheId) {
    return _maxMedalByModule[nicheId]?.asset;
  }

  void resetMedals(
    NicheId nicheId, {
    int notificationIdOffset = 999,
    String? notificationTitle,
    String? notificationBody,
    bool sendNotification = true,
    String? iconPath,
    bool deactivate = false,
  }) {
    // 1. LIMPEZA LOCAL IMEDIATA (Crítico para parar o loop)
    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();

    if (deactivate) {
      debugPrint('🛑 Desativando módulo localmente: $nicheId');
      _diasConsecutivosByModule.remove(nicheId);
      scheduleByModule.remove(nicheId);
      _moduleStartDates.remove(nicheId);
      _maxMedalByModule.remove(nicheId);

      // Se era o nicho atual, paramos o monitoramento global
      if (currentNicheId == nicheId) {
        stopMonitoringApps();
      }
    } else {
      _diasConsecutivosByModule[nicheId] = 0;
      _moduleStartDates[nicheId] = DateTime.now();
      _maxMedalByModule.remove(nicheId);
    }

    // 2. SINCRONIZAÇÃO (Pode falhar sem quebrar o local)
    CloudSyncService.saveModuleStatus(
      nicheId: nicheId,
      isActive: !deactivate,
      consecutiveDays: 0,
      forceClearMedal: true,
    ).catchError((e) => debugPrint('Erro ao sincronizar reset: $e'));

    // 3. NOTIFICAÇÃO
    if (sendNotification) {
      final title = notificationTitle ?? 'Contagem Reiniciada ⚠️';
      final body = notificationBody ??
          'O uso prolongado de um app monitorado reiniciou sua contagem de dias.';

      _sendCustomNotification(
        nicheId.id + notificationIdOffset,
        title,
        body,
        iconPath: iconPath,
      );
    }

    notifyListeners();
  }

  Future<void> _checkDailyMotivation(NicheId nicheId) async {
    final key = 'motivation_${nicheId.id}';

    if (_hasNotifiedToday(key)) return;

    final diasConsecutivos = _diasConsecutivosByModule[nicheId] ?? 0;
    if (diasConsecutivos == 0) return;

    final nextGoal = _getNextMedalGoal(diasConsecutivos);
    if (nextGoal == null) return;

    final missing = nextGoal - diasConsecutivos;
    String? msg;

    if (missing > 0 && missing <= 5) {
      msg = 'Faltam só $missing dias para sua próxima medalha! 🥇';
    } else if (missing == 0) {
      msg = 'Hoje é o dia! Mantenha o foco para conquistar a medalha.';
    }

    if (msg != null) {
      await _sendCustomNotification(
        nicheId.id + 800,
        'Mantenha o Foco! 🔥',
        msg,
      );
      _markAsNotified(key);
    }
  }

  int? _getNextMedalGoal(int currentDays) {
    if (currentDays < 3) return 3;
    if (currentDays < 5) return 5;
    if (currentDays < 7) return 7;
    if (currentDays < 10) return 10;
    return null;
  }

  Future<void> _sendCustomNotification(int id, String title, String body,
      {String? iconPath}) async {
    AndroidBitmap<Uint8List>? largeIcon;
    if (iconPath != null) {
      try {
        final ByteData data = await rootBundle.load(iconPath);
        largeIcon = ByteArrayAndroidBitmap(data.buffer.asUint8List());
      } catch (e) {
        debugPrint('Erro ao carregar ícone da notificação custom: $e');
      }
    }

    final androidDetails = AndroidNotificationDetails(
      'disciplinum_channel',
      'Disciplinum Notificações',
      importance: Importance.max,
      priority: Priority.high,
      playSound: NotificationService.soundEnabled,
      enableVibration: true,
      enableLights: true,
      largeIcon: largeIcon,
      styleInformation: BigTextStyleInformation(body),
    );
    final details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(id, title, body, details);
  }

  Future<void> setCustomMessage(NicheId nicheId, String message) async {
    _customMessages[nicheId] = message;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_msg_${nicheId.id}', message);
    notifyListeners();
  }

  Future<void> setCustomPhrases(NicheId nicheId, List<String> phrases) async {
    _customPhrases[nicheId] = phrases;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_phrases_${nicheId.id}', phrases);
    notifyListeners();
  }

  bool historyFocusInterval(NicheId? nicheId, DateTime now) {
    if (nicheId == null || focusIntervalByModule[nicheId] == null) {
      if (nicheId == NicheId.focus) return false;
      return true;
    }

    final foco = focusIntervalByModule[nicheId]!;
    final minsNow = now.hour * 60 + now.minute;
    final minsIni = foco.start.hour * 60 + foco.start.minute;
    final minsFim = foco.end.hour * 60 + foco.end.minute;

    if (minsIni > minsFim) {
      return minsNow >= minsIni || minsNow <= minsFim;
    } else {
      return minsNow >= minsIni && minsNow <= minsFim;
    }
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }
}

class TimeOfDayRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeOfDayRange({required this.start, required this.end});
}
