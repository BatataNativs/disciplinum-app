import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/models/8_procrastination/procrastination_model.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

class ProcrastinationService extends ChangeNotifier {
  static const String _moduleId = 'procrastination';
  static const String _localKey = 'procrastination_data';

  final GamificationService _gamificationService;
  final SharedPreferences _prefs;
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, ProcrastinationDay> _days = {};

  static ProcrastinationService? _instance;
  static ProcrastinationService get instance => _instance!;

  ProcrastinationService(this._gamificationService, this._prefs) {
    _instance = this;
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Carrega local primeiro (cache imediato)
    final String? localData = _prefs.getString(_localKey);
    if (localData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(localData);
        _days = decoded.map(
            (key, value) => MapEntry(key, ProcrastinationDay.fromJson(value)));
        notifyListeners();
      } catch (e) {
        debugPrint('Erro ao carregar dados locais de procrastinação: $e');
      }
    }

    // 2. Tenta carregar da nuvem se estiver logado
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        // Se offline/guest, ainda assim verifica virada de dia
        await _checkMidnightReset();
        return;
      }

      final response = await _supabase
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', _moduleId)
          .maybeSingle();

      if (response != null && response['module_data'] != null) {
        final cloudJson = response['module_data'];
        final Map<String, dynamic> decoded =
            cloudJson is String ? jsonDecode(cloudJson) : cloudJson;

        final cloudDays = decoded.map(
            (key, value) => MapEntry(key, ProcrastinationDay.fromJson(value)));

        _days = cloudDays;
        await _prefs.setString(
            _localKey,
            jsonEncode(
                _days.map((key, value) => MapEntry(key, value.toJson()))));
        notifyListeners();
      }

      // Verifica virada de dia após carregar dados (Cloud ou Local)
      await _checkMidnightReset();
    } catch (e) {
      debugPrint('Erro ao sincronizar com nuvem (load): $e');
      await _checkMidnightReset();
    }
  }

  /// Verifica se houve virada de dia e se dias anteriores foram cumpridos.
  /// Isso evita punição imediata enquanto o dia ainda está ocorrendo.
  Future<void> _checkMidnightReset() async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final lastCheckStr = _prefs.getString('procrastination_last_check');

    if (lastCheckStr == null) {
      // Primeira execução: marca hoje como iniciado e sai
      await _prefs.setString('procrastination_last_check', todayKey);
      return;
    }

    if (lastCheckStr == todayKey) return; // Já verificado hoje

    // Identifica o intervalo de dias entre o último check e hoje
    DateTime lastCheckDate = DateTime.parse(lastCheckStr);
    DateTime checkDate =
        DateTime(lastCheckDate.year, lastCheckDate.month, lastCheckDate.day);
    DateTime today = DateTime(now.year, now.month, now.day);

    bool resetTriggered = false;

    // Verifica todos os dias passados desde o último check (inclusive o dia do último check)
    // até ontem. O dia de hoje ainda não é validado para falha.
    while (checkDate.isBefore(today)) {
      final key = _dateKey(checkDate);
      final day = _days[key];

      // Só penaliza se:
      // 1. Tinha tarefas
      // 2. Não completou todas
      // 3. Não está marcado como completo nem como falha ainda
      if (day != null &&
          day.tasks.isNotEmpty &&
          !day.allTasksCompleted &&
          !day.isDayComplete &&
          !day.isDayFailed) {
        _days[key] = day.copyWith(isDayFailed: true, isDayComplete: false);

        if (!resetTriggered) {
          _gamificationService.resetMedals(
            NicheId.procrastination,
            notificationTitle: "Dia Incompleto 📉",
            notificationBody:
                "Você deixou tarefas pendentes em dias anteriores. Seu streak foi reiniciado.",
            deactivate: false,
          );
          resetTriggered = true;
        }
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    await _prefs.setString('procrastination_last_check', todayKey);
    if (resetTriggered) {
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    final jsonData = _days.map((key, value) => MapEntry(key, value.toJson()));
    final encoded = jsonEncode(jsonData);

    // Salva local
    await _prefs.setString(_localKey, encoded);

    // Salva cloud
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': jsonData,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id, module_id');
    } catch (e) {
      debugPrint('Erro ao sincronizar com nuvem (save): $e');
    }
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  List<ProcrastinationTask> getTasksForDay(DateTime date) {
    final key = _dateKey(date);
    final tasks = _days[key]?.tasks ?? [];

    // Sort: tasks with time first (earlier to later), then untimed tasks
    final sortedTasks = List<ProcrastinationTask>.from(tasks);
    sortedTasks.sort((a, b) {
      if (a.startTime != null && b.startTime != null) {
        return a.startTime!.compareTo(b.startTime!);
      }
      if (a.startTime != null) return -1;
      if (b.startTime != null) return 1;
      return 0;
    });

    return sortedTasks;
  }

  ProcrastinationDay? getDay(DateTime date) {
    return _days[_dateKey(date)];
  }

  Future<void> addTask(DateTime date, ProcrastinationTask task) async {
    final key = _dateKey(date);
    final day = _days[key] ?? ProcrastinationDay(date: date, tasks: []);

    final updatedTasks = List<ProcrastinationTask>.from(day.tasks)..add(task);

    _days[key] = day.copyWith(tasks: updatedTasks);
    await _saveData();
    await _scheduleTaskNotification(task);
    notifyListeners();
  }

  Future<void> updateTask(
      DateTime date, ProcrastinationTask updatedTask) async {
    final key = _dateKey(date);
    final day = _days[key];
    if (day == null) return;

    final updatedTasks =
        day.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
    _days[key] = day.copyWith(tasks: updatedTasks);

    await _saveData();
    await _scheduleTaskNotification(updatedTask);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(DateTime date, String taskId) async {
    final key = _dateKey(date);
    final day = _days[key];
    if (day == null) return;

    final updatedTasks = day.tasks.map((t) {
      if (t.id == taskId) {
        final newStatus = !t.isCompleted;
        return t.copyWith(isCompleted: newStatus);
      }
      return t;
    }).toList();

    _days[key] = day.copyWith(tasks: updatedTasks);

    // Se marcou como concluído, cancela a notificação
    final updatedTask = updatedTasks.firstWhere((t) => t.id == taskId);
    if (updatedTask.isCompleted) {
      await _cancelTaskNotification(taskId);
    } else {
      await _scheduleTaskNotification(updatedTask);
    }

    await _saveData();
    notifyListeners();

    // Verifica se completou o dia
    if (updatedTask.isCompleted) {
      await checkDayCompletion(date);
    }
  }

  Future<void> removeTask(DateTime date, String taskId) async {
    final key = _dateKey(date);
    final day = _days[key];
    if (day == null) return;

    final updatedTasks = day.tasks.where((t) => t.id != taskId).toList();
    _days[key] = day.copyWith(tasks: updatedTasks);
    await _saveData();
    await _cancelTaskNotification(taskId);
    notifyListeners();
  }

  Future<void> clearCompletedTasks(DateTime date) async {
    final key = _dateKey(date);
    final day = _days[key];
    if (day == null) return;

    final updatedTasks = day.tasks.where((t) => !t.isCompleted).toList();
    _days[key] = day.copyWith(tasks: updatedTasks);
    await _saveData();
    notifyListeners();
  }

  /// Verifica se o dia foi cumprido (apenas sucesso imediato).
  /// A falha é verificada retrospectivamente em [_checkMidnightReset].
  Future<bool> checkDayCompletion(DateTime date) async {
    final key = _dateKey(date);
    final day = _days[key];

    if (day == null || day.tasks.isEmpty) return false;

    final allCompleted = day.allTasksCompleted;

    if (allCompleted) {
      if (!day.isDayComplete) {
        _days[key] = day.copyWith(isDayComplete: true, isDayFailed: false);
        await _saveData();
        notifyListeners();
      }
      return true;
    }

    // Se não completou tudo, mas estava marcado como completo (ex: desmarcou algo),
    // removemos o status de completo.
    if (day.isDayComplete && !allCompleted) {
      _days[key] = day.copyWith(isDayComplete: false);
      await _saveData();
      notifyListeners();
    }

    return false;
  }

  Future<void> deleteAllTasks() async {
    _days = {};
    await _saveData();

    // Resetar o last_check para hoje ao limpar tudo, evitando punições retroativas de dias vazios que tinham tarefas
    final todayKey = _dateKey(DateTime.now());
    await _prefs.setString('procrastination_last_check', todayKey);

    // Cancelar todas as notificações pendentes (idealmente filtrando por ID range do módulo)
    // Por simplicidade aqui, o cancelamento individual é mais seguro se tivermos os IDs,
    // mas como limpamos TUDO, podemos confiar que novas tarefas terão novos agendamentos.
    notifyListeners();
  }

  // --- NOTIFICAÇÕES ---

  Future<void> _scheduleTaskNotification(ProcrastinationTask task) async {
    if (task.isCompleted) {
      await _cancelTaskNotification(task.id);
      return;
    }

    final scheduledDate = task.startTime ??
        DateTime(
            task.startTime?.year ?? DateTime.now().year,
            task.startTime?.month ?? DateTime.now().month,
            task.startTime?.day ?? DateTime.now().day,
            0,
            0);

    // Se a data já passou, não agenda
    if (scheduledDate.isBefore(DateTime.now())) return;

    final int notificationId = task.id.hashCode.abs();

    await NotificationService.scheduleNotification(
      id: notificationId,
      title: 'Tarefa: ${task.title}',
      body: task.description ?? 'Hora de realizar sua tarefa!',
      scheduledDate: scheduledDate,
      payload: 'task_${task.id}',
      actions: [
        const fln.AndroidNotificationAction(
          'done',
          'concluído ✅',
          showsUserInterface: true,
        ),
        const fln.AndroidNotificationAction(
          'delete',
          'Apagar',
          showsUserInterface: true,
        ),
        const fln.AndroidNotificationAction(
          'postpone',
          'Adiar',
          showsUserInterface: true,
        ),
      ],
    );
  }

  Future<void> _cancelTaskNotification(String taskId) async {
    final int notificationId = taskId.hashCode.abs();
    await NotificationService.cancelNotification(notificationId);
  }

  /// Processa ações vindas das notificações
  Future<void> handleNotificationAction(String actionId, String payload) async {
    debugPrint(
        '🔔 ProcrastinationService: Processando ação $actionId com payload $payload');

    if (!payload.startsWith('task_')) return;
    final taskId = payload.replaceFirst('task_', '');

    // Encontra a tarefa e sua data
    DateTime? taskDay;
    for (var entry in _days.entries) {
      if (entry.value.tasks.any((t) => t.id == taskId)) {
        taskDay = DateTime.parse(entry.key);
        break;
      }
    }

    if (taskDay == null) {
      debugPrint('⚠️ Tarefa $taskId não encontrada para processar ação.');
      return;
    }

    if (actionId == 'done') {
      await toggleTaskCompletion(taskDay, taskId);
      debugPrint('✅ Tarefa $taskId marcada como concluída via notificação.');
    } else if (actionId == 'delete') {
      await removeTask(taskDay, taskId);
      debugPrint('🗑️ Tarefa $taskId removida via notificação.');
    }
  }
}
