import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/models/user_module_status.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/services/7_moneySavingChallenge/money_saving_challenge_service.dart';

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
  NicheId.moneySavingChallenge:
      '💰 Hoje é dia de se aproximar mais da sua meta! Que tal marcar mais um quadradinho hoje?',
  NicheId.procrastination:
      '🗓️ Não esqueça dos seus compromissos agendados. Verifique suas tarefas e compromissos para hoje!',
  NicheId.reading:
      '📚 Hora da leitura diária! Vamos viajar mais um pouco no mundo dos livros?',
};

String getModuleMessage(NicheId nicheId, {bool allowCustom = true}) {
  if (allowCustom) {
    if (IapService().isCustomNotifUnlocked) {
      final custom = GamificationService.instance.customMessages[nicheId];
      if (custom != null && custom.isNotEmpty) return custom;
    }
  }
  final msg = moduleMessages[nicheId];
  if (msg != null) return msg;

  return 'Conquista em progresso!';
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
  final Map<NicheId, List<String>> _customPhrases = {};
  final Set<NicheId> _unlockedNotifications =
      {}; // Novo: Módulos desbloqueados por Ad
  final Set<NicheId> _unlockedMotivations = {}; // NOVO

  // Fila de medalhas pendentes de visualização (Popup)
  final List<Map<String, dynamic>> _pendingMedals = [];
  List<Map<String, dynamic>> get pendingMedals =>
      List.unmodifiable(_pendingMedals);

  Map<NicheId, String> get customMessages => _customMessages;
  Map<NicheId, List<String>> get customPhrases => _customPhrases;

  // ID para a notificação persistente (Serviço de Primeiro Plano)
  static const int _foregroundServiceId = 888;
  // Chave para persistência local do nicho ativo
  static const String _prefsActiveNicheKey = 'active_niche_id';
  // Prefixo para o status de cada módulo (Local-First)
  static const String _prefsModuleStatusPrefix = 'module_status_';
  static const String _prefsPendingMedalsKey = 'pending_medals';
  static const String _prefsUnlockedNotifsKey = 'unlocked_notifications';
  static const String _prefsUnlockedMotivationsKey =
      'unlocked_motivations'; // NOVO

  // Controle de monitoramento
  bool _isModuleActive = false;
  Timer? _monitorTimer;
  List<String> monitoredApps = [];
  bool notificationsPaused = false;

  // Mantido para _checkDailyMotivation
  final Map<String, DateTime> _notifiedSchedules = {};

  final Map<String, DateTime> _violationStartByApp = {};
  final Map<String, DateTime> _warnedApps = {};
  final Map<String, DateTime> _lastSeenMonitoredApp = {};
  DateTime _lastHeartbeatSave = DateTime.fromMillisecondsSinceEpoch(0);
  NicheId? currentNicheId;

  void _handleRelapseFromNotification(String? payload) {
    if (payload != null && payload.startsWith('medal_ack')) {
      // Apenas limpamos a notificação, nada especial a fazer aqui
      // O popup será mostrado quando o app abrir
      return;
    }

    NicheId? nicheId;
    if (payload != null) {
      // Tenta parsing do ID
      nicheId = NicheId.values.firstWhere(
        (e) => e.id.toString() == payload,
        orElse: () =>
            NicheId.smoking, // Fallback, mas idealmente tratamos melhor
      );
    } else {
      nicheId = currentNicheId;
    }

    if (nicheId == NicheId.smoking && !payload!.startsWith('reading')) {
      // proteção simples
      final niche = NicheRepository.getById(nicheId!);
      resetMedals(
        nicheId,
        notificationTitle: 'Recaída registrada 😟',
        notificationBody:
            'Sua contagem foi zerada e o módulo desativado. Confira no app o quanto economizou nessa tentativa!',
        iconPath: niche.iconPath,
        deactivate: true,
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

    // Carrega nichos desbloqueados por anúncios
    final unlockedIds = prefs.getStringList(_prefsUnlockedNotifsKey);
    if (unlockedIds != null) {
      for (final idStr in unlockedIds) {
        final nid = NicheId.tryFromInt(int.parse(idStr));
        if (nid != null) _unlockedNotifications.add(nid);
      }
    }

    final unlockedMotivationsIds =
        prefs.getStringList(_prefsUnlockedMotivationsKey);
    if (unlockedMotivationsIds != null) {
      for (final idStr in unlockedMotivationsIds) {
        final nid = NicheId.tryFromInt(int.parse(idStr));
        if (nid != null) _unlockedMotivations.add(nid);
      }
    }

    // Carrega medalhas pendentes
    final pendingJson = prefs.getString(_prefsPendingMedalsKey);
    if (pendingJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(pendingJson);
        _pendingMedals.addAll(decoded.cast<Map<String, dynamic>>());
      } catch (e) {
        debugPrint('Erro ao carregar medalhas pendentes: $e');
      }
    }

    notifyListeners();

    // Tenta restaurar TODOS os módulos ativos e horários
    await _restoreAllActiveModules();
  }

  Future<void> _savePendingMedals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsPendingMedalsKey, jsonEncode(_pendingMedals));
  }

  void consumePendingMedal(Map<String, dynamic> medal) {
    _pendingMedals.remove(medal);
    _savePendingMedals();
    notifyListeners();
  }

  // Novo método unificado para conceder medalhas
  void awardMedal(NicheId nicheId, GamificationMedal medal) {
    // 1. Adicionar à fila de pendentes (para Popup)
    final medalData = {
      'niche_id': nicheId.id,
      'medal_name': medal.nameBr,
      'medal_asset': medal.asset,
      'awarded_at': DateTime.now().toIso8601String(),
    };

    // Evita duplicatas na fila
    final alreadyPending = _pendingMedals.any(
        (m) => m['niche_id'] == nicheId.id && m['medal_name'] == medal.nameBr);

    if (!alreadyPending) {
      _pendingMedals.add(medalData);
      _savePendingMedals();
    }

    // 2. Enviar notificação com ações
    _sendMedalNotificationWithActions(nicheId, medal);

    notifyListeners();
  }

  // --- Desbloqueio de Notificações por Ads ---
  bool isNotificationUnlocked(NicheId nicheId) {
    return _unlockedNotifications.contains(nicheId);
  }

  Future<void> unlockNotification(NicheId nicheId) async {
    _unlockedNotifications.add(nicheId);

    // Salva na persistência local
    final prefs = await SharedPreferences.getInstance();
    final idsAsString =
        _unlockedNotifications.map((n) => n.id.toString()).toList();
    await prefs.setStringList(_prefsUnlockedNotifsKey, idsAsString);

    notifyListeners();
  }

  // --- Desbloqueio de Motivações por Ads ---
  bool isMotivationUnlocked(NicheId nicheId) {
    return _unlockedMotivations.contains(nicheId);
  }

  Future<void> unlockMotivation(NicheId nicheId) async {
    _unlockedMotivations.add(nicheId);

    // Salva na persistência local
    final prefs = await SharedPreferences.getInstance();
    final idsAsString =
        _unlockedMotivations.map((n) => n.id.toString()).toList();
    await prefs.setStringList(_prefsUnlockedMotivationsKey, idsAsString);

    notifyListeners();
  }

  Future<void> _sendMedalNotificationWithActions(
      NicheId nicheId, GamificationMedal medal) async {
    final title = 'Nova Medalha Conquistada! 🏆';
    final body =
        'Parabéns! Você alcançou a medalha de ${medal.nameBr} no módulo ${NicheRepository.getById(nicheId).name}.';
    final id = nicheId.id + 900;

    // Carrega ícone se possível
    AndroidBitmap<Uint8List>? largeIcon;
    try {
      final iconPath =
          medal.asset; // Tenta usar a própria medalha como ícone grande
      if (iconPath.endsWith('.png')) {
        // check simples
        final ByteData data = await rootBundle.load(iconPath);
        largeIcon = ByteArrayAndroidBitmap(data.buffer.asUint8List());
      }
    } catch (_) {}

    await NotificationService.scheduleDailyNotification(
      id: id,
      time: TimeOfDay
          .now(), // Imediato (hack, ou usar show direto) -> NotificationService não tem show direto público fácil com actions?
      // O NotificationService tem schedule, mas flutterLocalNotificationsPlugin tem show.
      // Vou usar o plugin direto aqui para ter controle total das actions
      title: title,
      body: body,
    );

    // REVISÃO: NotificationService.scheduleDailyNotification não é para imediato.
    // Vou usar uma implementação direta aqui similar ao _sendCustomNotification mas com actions.

    final androidDetails = AndroidNotificationDetails(
        'disciplinum_medals', 'Conquistas e Medalhas',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        largeIcon: largeIcon,
        styleInformation: BigTextStyleInformation(body),
        actions: [
          const AndroidNotificationAction(
            'view_app',
            'Ver no app',
            showsUserInterface:
                true, // Abre o app e deve disparar o popup via pending medals
          ),
          const AndroidNotificationAction(
            'dismiss_medal',
            'Ok. Apagar',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ]);

    await flutterLocalNotificationsPlugin.show(
        id, title, body, NotificationDetails(android: androidDetails));
  }

  Future<void> _restoreAllActiveModules() async {
    final prefs = await SharedPreferences.getInstance();
    final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    if (!seenOnboarding) return;

    for (final nicheId in NicheId.values) {
      // 1. Tenta Reconciliar (Local vs Nuvem)
      await _syncWithCloud(nicheId);

      // 2. Se o módulo estiver ativo (pode ter sido restaurado do Local ou Nuvem)
      if (isModuleActive(nicheId)) {
        // Carrega horários base (Check-ins)
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
        }

        // --- CARREGA E AGENDA FRASES MOTIVACIONAIS ---
        final motivationTimes = await CloudSyncService.loadUserNicheTimes(
            nicheId: nicheId.id + 100);

        if (motivationTimes.isNotEmpty) {
          debugPrint(
              '📝 Encontrados ${motivationTimes.length} horários motivacionais para $nicheId');
          motivationSchedulesByModule[nicheId] = motivationTimes
              .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
              .toList();

          // Sincroniza frases salvas na nuvem com o cache local
          final cloudPhrases = motivationTimes
              .map((t) => t.phrase ?? '') // Garante string vazia se null
              .where((p) => p.isNotEmpty) // Remove vazias
              .toList();

          // Se a nuvem tem frases salvas, atualiza o cache local
          if (cloudPhrases.isNotEmpty) {
            _customPhrases[nicheId] = cloudPhrases;
          }
        }

        // --- Agendamento Nativo (Ambos: Check-in + Motivação) ---
        await _scheduleNativeNotifications(nicheId);
      }
    }
  }

  /// Puxa TODOS os dados do cloud e atualiza o estado local do app (Full Sync)
  Future<bool> refreshAllDataFromCloud() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      debugPrint('🔄 Iniciando Full Sync de dados do Cloud...');

      // 1. Puxa todos os status dos módulos
      final statusList = await Supabase.instance.client
          .from('user_module_status')
          .select()
          .eq('user_id', user.id);

      _maxMedalByModule.clear();
      _diasConsecutivosByModule.clear();

      for (var row in statusList as List) {
        final status = UserModuleStatus.fromJson(row);
        final nicheId = NicheId.tryFromInt(status.nicheId);
        if (nicheId != null) {
          if (status.isActive) {
            _diasConsecutivosByModule[nicheId] = status.consecutiveDays;
            if (status.maxMedal != null) {
              _maxMedalByModule[nicheId] = GamificationMedal.values.firstWhere(
                (m) => m.nameBr == status.maxMedal,
                orElse: () => GamificationMedal.bronze,
              );
            }
          }
        }
      }

      // 2. Puxa horários de todos os módulos
      final timesList = await Supabase.instance.client
          .from('user_niche_times')
          .select()
          .eq('user_id', user.id);

      scheduleByModule.clear();
      motivationSchedulesByModule.clear();

      for (var row in timesList as List) {
        final nicheIdRaw = row['niche_id'] as int;
        final hour = row['hour'] as int;
        final minute = row['minute'] as int;
        final phrase = row['phrase'] as String?;

        if (nicheIdRaw > 100) {
          // Motivação
          final nicheId = NicheId.tryFromInt(nicheIdRaw - 100);
          if (nicheId != null) {
            motivationSchedulesByModule.putIfAbsent(nicheId, () => []);
            motivationSchedulesByModule[nicheId]!
                .add(TimeOfDay(hour: hour, minute: minute));
            if (phrase != null && phrase.isNotEmpty) {
              _customPhrases.putIfAbsent(nicheId, () => []);
              if (!_customPhrases[nicheId]!.contains(phrase)) {
                _customPhrases[nicheId]!.add(phrase);
              }
            }
          }
        } else {
          // Check-in
          final nicheId = NicheId.tryFromInt(nicheIdRaw);
          if (nicheId != null) {
            scheduleByModule.putIfAbsent(nicheId, () => []);
            scheduleByModule[nicheId]!
                .add(TimeOfDay(hour: hour, minute: minute));
          }
        }
      }

      // 3. Puxa apps monitorados
      final appsList = await Supabase.instance.client
          .from('user_niche_apps')
          .select()
          .eq('user_id', user.id);

      // Como monitoramento costuma ser de um módulo por vez no app,
      // carregamos os apps do módulo atual se ele existir
      if (currentNicheId != null) {
        monitoredApps = (appsList as List)
            .where((row) => row['niche_id'] == currentNicheId!.id)
            .map((row) => row['app_package'] as String)
            .toList();
      }

      // 4. Módulo 7 (Poupança) - Puxa via serviço dedicado para garantir lógica de migração
      await MoneySavingChallengeService().getChallenges();

      // Persiste as mudanças básicas localmente
      await _saveAllToLocalCache();

      // Reagenda notificações para os novos horários
      for (final nid in _diasConsecutivosByModule.keys) {
        await _scheduleNativeNotifications(nid);
      }

      notifyListeners();
      debugPrint('✅ Full Sync concluído com sucesso.');
      return true;
    } catch (e) {
      debugPrint('❌ Erro no Full Sync: $e');
      return false;
    }
  }

  Future<void> _saveAllToLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    // Salva frases customizadas
    for (var entry in _customPhrases.entries) {
      await prefs.setStringList('custom_phrases_${entry.key.id}', entry.value);
    }
    // Salva status dos módulos ativos para restauração offline
    for (var niche in NicheId.values) {
      final key = '$_prefsModuleStatusPrefix${niche.id}';
      if (_diasConsecutivosByModule.containsKey(niche)) {
        await prefs.setInt(key, _diasConsecutivosByModule[niche]!);
      } else {
        await prefs.remove(key);
      }
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

  Future<void> restoreMonitoringSession() async {
    // Mesmo se já estiver ativo, forçamos o reagendamento para garantir atualizações de frases
    // if (_isModuleActive) return;

    final prefs = await SharedPreferences.getInstance();

    final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    if (!seenOnboarding) {
      debugPrint(
          '🛡️ GamificationService: Bloqueando restauração (Onboarding pendente).');
      return;
    }

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

        // Carrega Apps Monitorados
        final userApps =
            await CloudSyncService.loadUserNicheApps(nicheId: nicheId);
        monitoredApps = userApps.map((a) => a.appPackage).toList();

        // Carrega Horários Check-in
        final userTimes =
            await CloudSyncService.loadUserNicheTimes(nicheId: nicheId.id);
        scheduleByModule[nicheId] = userTimes
            .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
            .toList();

        // Carrega Horários Motivação
        final motivationTimes = await CloudSyncService.loadUserNicheTimes(
            nicheId: nicheId.id + 100);
        motivationSchedulesByModule[nicheId] = motivationTimes
            .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
            .toList();

        // Atualiza cache de frases vindas do banco
        final cloudPhrases = motivationTimes
            .map((t) => t.phrase ?? '')
            .toList(); // Mantemos vazias para respeitar o índice do array

        if (cloudPhrases.any((p) => p.isNotEmpty)) {
          _customPhrases[nicheId] = cloudPhrases;
        }

        // Reagenda tudo
        await _scheduleNativeNotifications(nicheId);

        // Se o monitor não estiver rodando, inicia
        if (!_isModuleActive) {
          _isModuleActive = true;
          await _startForegroundService();
          _monitorTimer =
              Timer.periodic(const Duration(seconds: 2), (timer) async {
            // ... Lógica do timer mantida (será chamada abaixo) ...
            _monitorLoop(timer);
          });
        }

        currentNicheId = nicheId; // Garante que o ID atual está setado

        debugPrint('✅ Sessão carregada e agendada para ${nicheId.name}.');
      } catch (e) {
        debugPrint('Erro ao restaurar sessão de monitoramento: $e');
        await prefs.remove(_prefsActiveNicheKey);
      }
    }
  }

  // --- LOOP DO TIMER EXTRAÍDO PARA REUSO ---
  void _monitorLoop(Timer timer) async {
    try {
      if (!_isModuleActive) {
        timer.cancel();
        return;
      }

      await _saveHeartbeat();

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

      // 2. LÓGICA DE APPS PROIBIDOS (Mantida)
      final activeNicheId = currentNicheId;
      final apps = List<String>.from(monitoredApps);

      if (apps.isNotEmpty && activeNicheId != null) {
        final nowMs = now.millisecondsSinceEpoch;

        // --- CORREÇÃO MÓDULO FOCO: Respeitar intervalo de horários ---
        if (activeNicheId == NicheId.focus) {
          // Se estiver FORA do intervalo, não monitora e limpa estados de violação
          if (!historyFocusInterval(activeNicheId, now)) {
            _violationStartByApp.clear();
            _warnedApps.clear();
            // Retorna para pular esta iteração do loop
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
          debugPrint('✅ Saída definitiva (App Real): $foregroundApp');
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
              debugPrint('✅ Saída definitiva (Inatividade de 60s): $key');
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

  // --- AGENDAMENTO NATIVO ---
  Future<void> _scheduleNativeNotifications(NicheId nicheId) async {
    debugPrint('📅 Configurando alarmes nativos para: ${nicheId.name}');

    // 1. Agendar Check-ins (Mantido)
    final checkIns = scheduleByModule[nicheId];
    if (checkIns != null) {
      for (int i = 0; i < checkIns.length; i++) {
        final time = checkIns[i];
        final notifId = (nicheId.id * 1000) + 100 + i;
        final niche = NicheRepository.getById(nicheId);

        // Define ações (botões)
        List<AndroidNotificationAction>? actions;
        String? payload;

        if (nicheId == NicheId.smoking) {
          payload = nicheId.id.toString();
          // Como actionIdSim agora é 'const' e foi importado, isso funciona
          actions = [
            const AndroidNotificationAction(actionIdSim, 'Sim!',
                showsUserInterface: true, cancelNotification: true),
            const AndroidNotificationAction(actionIdNao, 'Não, tive recaída',
                showsUserInterface: true, cancelNotification: true),
          ];
        }

        String body = _getModuleMessage(nicheId);
        if (nicheId == NicheId.smoking) {
          body =
              'Manteve-se disciplinado hoje? \n\nLembre-se de conferir seu progresso no app 🚀.';
        }

        if (nicheId == NicheId.procrastination) {
          payload = 'procrastination_checkin';
          actions = [
            const AndroidNotificationAction(
              'ver_itens',
              'Ver itens agendados',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ];
        }

        TimeOfDay finalTime = time;
        if (nicheId == NicheId.diet) {
          // Payload com horário original da refeição
          final timeStr =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          payload = 'diet_meal_$timeStr';
          actions = [
            const AndroidNotificationAction('DIET_SIM', 'Fiz/Farei refeição',
                showsUserInterface: false, cancelNotification: true),
            const AndroidNotificationAction('DIET_NAO', 'Não fiz/não farei',
                showsUserInterface: false, cancelNotification: true),
          ];
          body = 'Hora da refeição das $timeStr! Você fez/fará esta refeição?';

          final dt = DateTime(2024, 1, 1, time.hour, time.minute)
              .subtract(const Duration(minutes: 30));
          finalTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        }

        await NotificationService.scheduleDailyNotification(
          id: notifId,
          time: finalTime,
          title: 'Check-in Diário: ${niche.name}',
          body: body,
          actions: actions,
          payload: payload,
        );
      }
    }

    // 2. Agendar Motivações (Frases) - REVISADO E FORÇADO
    final motivations = motivationSchedulesByModule[nicheId];
    if (motivations != null && motivations.isNotEmpty) {
      debugPrint(
          '📝 Agendando ${motivations.length} frases motivacionais para ${nicheId.name}');
      for (int i = 0; i < motivations.length; i++) {
        final time = motivations[i];
        // IDs únicos diferentes dos check-ins (ex: 1500, 1501...)
        final notifId = (nicheId.id * 1000) + 500 + i;
        final niche = NicheRepository.getById(nicheId);
        final phrase = getMotivationalPhrase(nicheId, time);

        debugPrint(
            '🔔 Agendando frase "$phrase" para ${time.hour}:${time.minute}');

        await NotificationService.scheduleDailyNotification(
          id: notifId,
          time: time,
          title: 'Disciplinum: ${niche.name}',
          body: phrase,
        );
      }
    } else {
      debugPrint(
          '⚠️ Nenhuma lista de motivação encontrada para ${nicheId.name} no momento do agendamento.');
    }

    // 3. Agendar Desafio da Poupança (Módulo 7)
    if (nicheId == NicheId.moneySavingChallenge) {
      await scheduleChallengeNotification();
    }
  }

  /// Agenda as notificações específicas do Desafio da Poupança com base nas configurações do modelo
  Future<void> scheduleChallengeNotification() async {
    try {
      final challenge =
          await MoneySavingChallengeService().getActiveChallenge();
      if (challenge == null || challenge.notifFrequency == 'disabled') {
        // Cancela notificações do módulo 7 se estiver desativado
        // O range de IDs para o módulo 7 é 7100+ (checkins) e 7500+ (motivações/desafio)
        // No caso do desafio, usamos um ID fixo ou range. Vamos usar 7001 para a notificação recorrente.
        await NotificationService.cancelNotification(7001);
        return;
      }

      final timeParts = challenge.notifTime.split(':');
      final time = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );

      final title = 'Desafio da Poupança 💰';
      final body = getModuleMessage(NicheId.moneySavingChallenge);
      const int notifId = 7001;

      // Primeiro cancela a anterior para garantir
      await NotificationService.cancelNotification(notifId);

      switch (challenge.notifFrequency) {
        case 'diario':
          await NotificationService.scheduleDailyNotification(
            id: notifId,
            time: time,
            title: title,
            body: body,
          );
          break;
        case 'semanal':
          await NotificationService.scheduleWeeklyNotification(
            id: notifId,
            dayOfWeek: challenge.notifDayOfWeek,
            time: time,
            title: title,
            body: body,
          );
          break;
        case 'mensal':
          await NotificationService.scheduleMonthlyNotification(
            id: notifId,
            dayOfMonth: challenge.notifDayOfMonth,
            time: time,
            title: title,
            body: body,
          );
          break;
      }
      debugPrint(
          '✅ Notificação do Desafio da Poupança agendada: ${challenge.notifFrequency}');
    } catch (e) {
      debugPrint('Erro ao agendar notificação do desafio: $e');
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsActiveNicheKey, nicheId.id);

      // Reagenda tudo (Check-ins e Motivações)
      await _scheduleNativeNotifications(nicheId);
    }

    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();

    await _startForegroundService();

    if (nicheId != null && monitoredApps.isNotEmpty) {
      await _checkRetroactiveViolations(nicheId);
    }

    // Reinicia o timer se necessário
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(const Duration(seconds: 2), _monitorLoop);
  }

  String _getModuleMessage(NicheId nicheId, {bool allowCustom = true}) {
    if (allowCustom) {
      if (IapService().isCustomNotifUnlocked ||
          isNotificationUnlocked(nicheId)) {
        final custom = _customMessages[nicheId];
        if (custom != null && custom.isNotEmpty) return custom;
      }
    }
    return moduleMessages[nicheId] ?? 'Conquista em progresso!';
  }

  // --- BUSCA FRASE CORRETA (Free ou Personalizada) ---
  String getMotivationalPhrase(NicheId nicheId, TimeOfDay time) {
    // 1. Tenta pegar a lista de horários
    final schedules = motivationSchedulesByModule[nicheId];

    // 2. Se estiver desbloqueado (IAP ou Ad), tenta pegar a frase customizada correspondente ao índice
    if (IapService().isMotivationPhrasesUnlocked ||
        isMotivationUnlocked(nicheId)) {
      final phrases = _customPhrases[nicheId];
      if (phrases != null && schedules != null && phrases.isNotEmpty) {
        // Encontra qual "slot" é esse horário
        final index = schedules.indexOf(time);
        if (index >= 0 && index < phrases.length) {
          final customPhrase = phrases[index];
          if (customPhrase.isNotEmpty) return customPhrase;
        }
      }

      // Fallback para mensagem única customizada (legado)
      final customSingle = _customMessages[nicheId];
      if (customSingle != null && customSingle.isNotEmpty) return customSingle;
    }

    // 3. Fallback Padrão (Free ou se não tiver custom)
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
    final now = DateTime.now();
    if (now.difference(_lastHeartbeatSave).inSeconds < 10) {
      return; // Throttling 10s
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_heartbeat', now.millisecondsSinceEpoch);
    _lastHeartbeatSave = now;
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
    final cloudStatus = await CloudSyncService.loadModuleStatus(nicheId);
    final localStatus = await _getLocalStatus(nicheId);

    UserModuleStatus? finalStatus;

    if (cloudStatus != null && localStatus != null) {
      final cloudDate = cloudStatus.lastUpdated ?? DateTime(2000);
      final localDate = localStatus.lastUpdated ?? DateTime(2000);

      if (localDate.isAfter(cloudDate)) {
        debugPrint('🏠 Sincronização: Local é mais recente para $nicheId');
        finalStatus = localStatus;
        CloudSyncService.saveModuleStatus(
          nicheId: nicheId,
          isActive: localStatus.isActive,
          consecutiveDays: localStatus.consecutiveDays,
          maxMedal: localStatus.maxMedal,
        ).catchError((e) => debugPrint('Erro ao atualizar nuvem atrasada: $e'));
      } else {
        debugPrint('☁️ Sincronização: Nuvem é mais recente para $nicheId');
        finalStatus = cloudStatus;
        _saveLocalStatus(nicheId);
      }
    } else {
      finalStatus = cloudStatus ?? localStatus;
      if (finalStatus != null && cloudStatus != null) {
        _saveLocalStatus(nicheId);
      }
    }

    if (finalStatus != null) {
      if (!finalStatus.isActive) {
        _diasConsecutivosByModule.remove(nicheId);
        _maxMedalByModule.remove(nicheId);
        _moduleStartDates.remove(nicheId);
      } else {
        _diasConsecutivosByModule[nicheId] = finalStatus.consecutiveDays;

        if (finalStatus.lastUpdated != null) {
          final lastUpdate = finalStatus.lastUpdated!;
          final days = finalStatus.consecutiveDays;
          _moduleStartDates[nicheId] =
              lastUpdate.subtract(Duration(days: days));
        } else {
          _moduleStartDates[nicheId] = DateTime.now();
        }

        final medalString = finalStatus.maxMedal;
        if (medalString != null) {
          _maxMedalByModule[nicheId] = GamificationMedal.values.firstWhere(
            (e) => e.toString().split('.').last == medalString,
            orElse: () => GamificationMedal.bronze,
          );
        }

        _checkTimeBasedMedals(nicheId);
      }
    } else {
      _diasConsecutivosByModule.remove(nicheId);
      _moduleStartDates.remove(nicheId);
    }

    notifyListeners();
  }

  void startModuleCycle({required NicheId nicheId}) async {
    debugPrint('🚀 Iniciando ciclo para módulo: $nicheId');
    _isModuleActive = true;

    // 1. Tenta carregar dados existentes primeiro
    await _syncWithCloud(nicheId);

    // 2. Se não houver dados (novo módulo ou desativado), inicializa
    if (!_diasConsecutivosByModule.containsKey(nicheId)) {
      debugPrint('🐣 Novo módulo detectado, inicializando streak: $nicheId');
      _diasConsecutivosByModule[nicheId] = 0;
      _moduleStartDates[nicheId] = DateTime.now();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsActiveNicheKey, nicheId.id);

    // 3. Salva o status garantindo que isModuleActive(nicheId) será true
    await _saveLocalStatus(nicheId);
    CloudSyncService.saveModuleStatus(
      nicheId: nicheId,
      isActive: true,
      consecutiveDays: _diasConsecutivosByModule[nicheId] ?? 0,
    );

    // 4. Agenda as notificações nativas (Check-in, Lembretes)
    await _scheduleNativeNotifications(nicheId);

    notifyListeners();
  }

  void stopModuleCycle({required NicheId nicheId}) async {
    _diasConsecutivosByModule.remove(nicheId);
    scheduleByModule.remove(nicheId);
    _saveLocalStatus(nicheId);
    CloudSyncService.saveModuleStatus(
      nicheId: nicheId,
      isActive: false,
      consecutiveDays: 0,
    );
    await _cancelModuleNotifications(nicheId);
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
    _saveLocalStatus(nicheId);
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
        _saveLocalStatus(nicheId);
        CloudSyncService.saveModuleStatus(
          nicheId: nicheId,
          isActive: true,
          maxMedal: newMedal.toString().split('.').last,
        );

        // Substitui chamada antiga pela nova com popup e actions
        awardMedal(nicheId, newMedal);

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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  GamificationMedal? maxMedalForModule(NicheId nicheId) =>
      _maxMedalByModule[nicheId];

  String? currentMedalAsset(NicheId nicheId) {
    return _maxMedalByModule[nicheId]?.asset;
  }

  Future<void> resetMedals(
    NicheId nicheId, {
    int notificationIdOffset = 999,
    String? notificationTitle,
    String? notificationBody,
    bool sendNotification = true,
    String? iconPath = 'assets/icon_disciplinum.png',
    bool deactivate = false,
  }) async {
    _violationStartByApp.clear();
    _warnedApps.clear();
    _lastSeenMonitoredApp.clear();

    if (deactivate) {
      debugPrint('🛑 Desativando módulo localmente: $nicheId');
      _diasConsecutivosByModule.remove(nicheId);
      scheduleByModule.remove(nicheId);
      _moduleStartDates.remove(nicheId);
      _maxMedalByModule.remove(nicheId);

      if (currentNicheId == nicheId) {
        stopMonitoringApps();
      }
    } else {
      _diasConsecutivosByModule[nicheId] = 0;
      _moduleStartDates[nicheId] = DateTime.now();
      _maxMedalByModule.remove(nicheId);
    }

    _saveLocalStatus(nicheId);

    CloudSyncService.saveModuleStatus(
      nicheId: nicheId,
      isActive: !deactivate,
      consecutiveDays: 0,
      forceClearMedal: true,
    ).catchError((e) => debugPrint('Erro ao sincronizar reset: $e'));

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

    if (deactivate) {
      await _cancelModuleNotifications(nicheId);
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

  Future<void> _cancelModuleNotifications(NicheId nicheId) async {
    debugPrint('🔕 Cancelando notificações para o módulo: ${nicheId.name}');
    // Cancela check-ins (ID base + 100, até 10 slots)
    for (int i = 0; i < 10; i++) {
      await NotificationService.cancelNotification(
          (nicheId.id * 1000) + 100 + i);
    }
    // Cancela motivações (ID base + 500, até 10 slots)
    for (int i = 0; i < 10; i++) {
      await NotificationService.cancelNotification(
          (nicheId.id * 1000) + 500 + i);
    }
    // Caso especial módulo 7
    if (nicheId == NicheId.moneySavingChallenge) {
      await NotificationService.cancelNotification(7001);
    }
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

  // Função para salvar mensagem personalizada única (legado)
  Future<void> setCustomMessage(NicheId nicheId, String message) async {
    _customMessages[nicheId] = message;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_msg_${nicheId.id}', message);
    notifyListeners();
  }

  // Função para salvar lista de frases (novo sistema)
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

  Future<void> _saveLocalStatus(NicheId nicheId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = Supabase.instance.client.auth.currentUser;
      final status = UserModuleStatus(
        userId: user?.id ?? 'local_user',
        nicheId: nicheId.id,
        isActive: isModuleActive(nicheId),
        consecutiveDays: _diasConsecutivosByModule[nicheId] ?? 0,
        maxMedal: _maxMedalByModule[nicheId]?.toString().split('.').last,
        lastUpdated: DateTime.now(),
      );

      await prefs.setString('$_prefsModuleStatusPrefix${nicheId.id}',
          jsonEncode(status.toJson()));
      debugPrint(
          '💾 Status local salvo para $nicheId (User: ${user?.id ?? 'local_user'})');
    } catch (e) {
      debugPrint('Erro ao salvar status local: $e');
    }
  }

  Future<UserModuleStatus?> _getLocalStatus(NicheId nicheId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('$_prefsModuleStatusPrefix${nicheId.id}');
      if (json == null) return null;
      return UserModuleStatus.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint('Erro ao carregar status local: $e');
      return null;
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
