import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:disciplinum/models/8_procrastination/procrastination_model.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

class ProcrastinationService extends ChangeNotifier {
  static const String _moduleId = 'procrastination';
  static const String _localKey = 'procrastination_data';
  static const String _listsKey = 'procrastination_lists';

  final GamificationService _gamificationService;
  final SharedPreferences _prefs;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Armazena todas as tarefas indexadas por listId
  Map<String, List<ProcrastinationTask>> _tasksByList = {};

  // Armazena as listas de tarefas
  List<TaskList> _lists = [];

  // Getter para as listas
  List<TaskList> get lists => List.unmodifiable(_lists);

  // Mantém compatibilidade com o sistema antigo de dias
  Map<String, ProcrastinationDay> _days = {};

  static ProcrastinationService? _instance;
  static ProcrastinationService get instance => _instance!;

  ProcrastinationService(this._gamificationService, this._prefs) {
    _instance = this;
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Carrega listas
    final String? listsData = _prefs.getString(_listsKey);
    if (listsData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(listsData);
        _lists = decoded.map((e) => TaskList.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Erro ao carregar listas: $e');
      }
    }

    // Se não há listas, cria a lista padrão
    if (_lists.isEmpty) {
      _lists = [
        TaskList(
          id: 'default',
          name: 'Nome da lista',
          createdAt: DateTime.now(),
          order: 0,
        ),
      ];
      await _saveLists();
    }

    // 2. Carrega dados locais primeiro (cache imediato)
    final String? localData = _prefs.getString(_localKey);
    if (localData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(localData);
        _days = decoded.map(
            (key, value) => MapEntry(key, ProcrastinationDay.fromJson(value)));

        // Migra tarefas antigas para o novo sistema
        _migrateTasksToLists();
        notifyListeners();
      } catch (e) {
        debugPrint('Erro ao carregar dados locais de procrastinação: $e');
      }
    }

    // 3. Tenta carregar da nuvem se estiver logado
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
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

        // Carrega listas da cloud
        if (decoded['lists'] != null) {
          _lists = (decoded['lists'] as List)
              .map((e) => TaskList.fromJson(e))
              .toList();
        }

        // Carrega tarefas por lista
        if (decoded['tasks_by_list'] != null) {
          _tasksByList = {};
          final tasksData = decoded['tasks_by_list'] as Map<String, dynamic>;
          tasksData.forEach((listId, tasks) {
            _tasksByList[listId] = (tasks as List)
                .map((e) => ProcrastinationTask.fromJson(e))
                .toList();
          });
        }

        // Mantém compatibilidade com sistema antigo
        if (decoded['days'] != null) {
          final daysData = decoded['days'] as Map<String, dynamic>;
          _days = daysData.map((key, value) =>
              MapEntry(key, ProcrastinationDay.fromJson(value)));
        }

        await _saveAllLocal();
        notifyListeners();
      }

      await _checkMidnightReset();
    } catch (e) {
      debugPrint('Erro ao sincronizar com nuvem (load): $e');
      await _checkMidnightReset();
    }
  }

  /// Migra tarefas do sistema antigo (por dia) para o novo sistema (por lista)
  void _migrateTasksToLists() {
    for (final day in _days.values) {
      for (final task in day.tasks) {
        final listId = task.listId;
        if (!_tasksByList.containsKey(listId)) {
          _tasksByList[listId] = [];
        }

        // Evita duplicatas
        if (!_tasksByList[listId]!.any((t) => t.id == task.id)) {
          // Atualiza a tarefa com a data agendada se não tiver
          final migratedTask = task.scheduledDate == null
              ? task.copyWith(scheduledDate: day.date)
              : task;
          _tasksByList[listId]!.add(migratedTask);
        }
      }
    }
  }

  /// Verifica se houve virada de dia e se dias anteriores foram cumpridos.
  Future<void> _checkMidnightReset() async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final lastCheckStr = _prefs.getString('procrastination_last_check');

    if (lastCheckStr == null) {
      await _prefs.setString('procrastination_last_check', todayKey);
      return;
    }

    if (lastCheckStr == todayKey) return;

    DateTime lastCheckDate = DateTime.parse(lastCheckStr);
    DateTime checkDate =
        DateTime(lastCheckDate.year, lastCheckDate.month, lastCheckDate.day);
    DateTime today = DateTime(now.year, now.month, now.day);

    bool resetTriggered = false;

    while (checkDate.isBefore(today)) {
      final key = _dateKey(checkDate);
      final day = _days[key];

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

  Future<void> _saveAllLocal() async {
    await _saveData();
    await _saveLists();
  }

  Future<void> _saveLists() async {
    final encoded = jsonEncode(_lists.map((l) => l.toJson()).toList());
    await _prefs.setString(_listsKey, encoded);
  }

  Future<void> _saveData() async {
    final jsonData = _days.map((key, value) => MapEntry(key, value.toJson()));
    final encoded = jsonEncode(jsonData);

    await _prefs.setString(_localKey, encoded);

    // Salva cloud
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final cloudData = {
        'days': jsonData,
        'lists': _lists.map((l) => l.toJson()).toList(),
        'tasks_by_list': _tasksByList.map(
          (key, value) => MapEntry(key, value.map((t) => t.toJson()).toList()),
        ),
      };

      await _supabase.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': cloudData,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, module_id');
    } catch (e) {
      debugPrint('Erro ao sincronizar com nuvem (save): $e');
    }
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // ===========================================
  // GERENCIAMENTO DE LISTAS
  // ===========================================

  /// Cria uma nova lista de tarefas
  Future<void> createList(String name) async {
    final newList = TaskList(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      order: _lists.length,
    );
    _lists.add(newList);
    await _saveAllLocal();
    notifyListeners();
  }

  /// Renomeia uma lista
  Future<void> renameList(String listId, String newName) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      _lists[index] = _lists[index].copyWith(name: newName);
      await _saveAllLocal();
      notifyListeners();
    }
  }

  /// Exclui uma lista e todas as suas tarefas
  Future<void> deleteList(String listId) async {
    if (listId == 'default' && _lists.length == 1) {
      // Não permite excluir a única lista
      return;
    }

    _lists.removeWhere((l) => l.id == listId);
    _tasksByList.remove(listId);

    // Remove tarefas dos dias
    for (final key in _days.keys.toList()) {
      final day = _days[key]!;
      final filteredTasks = day.tasks.where((t) => t.listId != listId).toList();
      if (filteredTasks.length != day.tasks.length) {
        _days[key] = day.copyWith(tasks: filteredTasks);
      }
    }

    await _saveAllLocal();
    notifyListeners();
  }

  /// Exclui todas as tarefas de uma lista (mantém a lista)
  Future<void> deleteAllTasksFromList(String listId) async {
    _tasksByList[listId] = [];

    // Remove das estruturas de dias também
    for (final key in _days.keys.toList()) {
      final day = _days[key]!;
      final filteredTasks = day.tasks.where((t) => t.listId != listId).toList();
      if (filteredTasks.length != day.tasks.length) {
        _days[key] = day.copyWith(tasks: filteredTasks);
      }
    }

    await _saveAllLocal();
    notifyListeners();
  }

  /// Retorna todas as listas ordenadas
  List<TaskList> getAllLists() {
    final sorted = List<TaskList>.from(_lists);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// Define o modo de ordenação de uma lista
  Future<void> setListSortMode(String listId, SortMode mode) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      _lists[index] = _lists[index].copyWith(sortMode: mode);
      await _saveAllLocal();
      notifyListeners();
    }
  }

  /// Retorna o modo de ordenação de uma lista
  SortMode getListSortMode(String listId) {
    final list = _lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => TaskList(
        id: listId,
        name: '',
        createdAt: DateTime.now(),
      ),
    );
    return list.sortMode;
  }

  // ===========================================
  // GERENCIAMENTO DE TAREFAS
  // ===========================================

  /// Retorna tarefas de uma lista específica
  List<ProcrastinationTask> getTasksForList(String listId,
      {SortMode? sortMode}) {
    final tasks = _tasksByList[listId] ?? [];
    final mode = sortMode ?? getListSortMode(listId);

    final sortedTasks = List<ProcrastinationTask>.from(tasks);

    if (mode == SortMode.custom) {
      sortedTasks.sort((a, b) => a.order.compareTo(b.order));
    } else {
      // Ordena por data (mais recentes primeiro)
      sortedTasks.sort((a, b) {
        final dateA = a.scheduledDate ?? a.startTime ?? DateTime(2099);
        final dateB = b.scheduledDate ?? b.startTime ?? DateTime(2099);
        return dateA.compareTo(dateB);
      });
    }

    return sortedTasks;
  }

  /// Retorna tarefas agrupadas por data (para modo "Data")
  Map<DateTime, List<ProcrastinationTask>> getTasksGroupedByDate(
      String listId) {
    final tasks = getTasksForList(listId, sortMode: SortMode.date);
    final Map<DateTime, List<ProcrastinationTask>> grouped = {};

    for (final task in tasks) {
      final date = task.scheduledDate ?? task.startTime;
      if (date != null) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        if (!grouped.containsKey(dateOnly)) {
          grouped[dateOnly] = [];
        }
        grouped[dateOnly]!.add(task);
      }
    }

    return grouped;
  }

  /// Adiciona uma tarefa a uma lista
  Future<void> addTaskToList(String listId, ProcrastinationTask task) async {
    if (!_tasksByList.containsKey(listId)) {
      _tasksByList[listId] = [];
    }

    // Define a ordem como última
    final taskWithOrder = task.copyWith(
      listId: listId,
      order: _tasksByList[listId]!.length,
    );

    _tasksByList[listId]!.add(taskWithOrder);

    // Também adiciona ao sistema de dias para compatibilidade
    if (task.scheduledDate != null) {
      final key = _dateKey(task.scheduledDate!);
      final day = _days[key] ??
          ProcrastinationDay(date: task.scheduledDate!, tasks: []);
      final updatedTasks = List<ProcrastinationTask>.from(day.tasks)
        ..add(taskWithOrder);
      _days[key] = day.copyWith(tasks: updatedTasks);
    }

    await _saveData();
    await _scheduleTaskNotification(taskWithOrder);
    notifyListeners();
  }

  /// Atualiza uma tarefa
  Future<void> updateTaskInList(
      String listId, ProcrastinationTask updatedTask) async {
    if (_tasksByList.containsKey(listId)) {
      final index =
          _tasksByList[listId]!.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasksByList[listId]![index] = updatedTask;
      }
    }

    // Atualiza nos dias também
    for (final key in _days.keys.toList()) {
      final day = _days[key]!;
      final taskIndex = day.tasks.indexWhere((t) => t.id == updatedTask.id);
      if (taskIndex != -1) {
        final updatedTasks = List<ProcrastinationTask>.from(day.tasks);
        updatedTasks[taskIndex] = updatedTask;
        _days[key] = day.copyWith(tasks: updatedTasks);
      }
    }

    await _saveData();
    await _scheduleTaskNotification(updatedTask);
    notifyListeners();
  }

  /// Remove uma tarefa de uma lista
  Future<void> removeTaskFromList(String listId, String taskId) async {
    if (_tasksByList.containsKey(listId)) {
      _tasksByList[listId]!.removeWhere((t) => t.id == taskId);
    }

    // Remove dos dias também
    for (final key in _days.keys.toList()) {
      final day = _days[key]!;
      final filteredTasks = day.tasks.where((t) => t.id != taskId).toList();
      if (filteredTasks.length != day.tasks.length) {
        _days[key] = day.copyWith(tasks: filteredTasks);
      }
    }

    await _saveData();
    await _cancelTaskNotification(taskId);
    notifyListeners();
  }

  /// Reordena as tarefas de uma lista
  Future<void> reorderTasks(String listId, List<String> taskIds) async {
    if (!_tasksByList.containsKey(listId)) return;

    final tasks = _tasksByList[listId]!;
    final reorderedTasks = <ProcrastinationTask>[];

    for (int i = 0; i < taskIds.length; i++) {
      final task = tasks.firstWhere((t) => t.id == taskIds[i]);
      reorderedTasks.add(task.copyWith(order: i));
    }

    _tasksByList[listId] = reorderedTasks;
    await _saveData();
    notifyListeners();
  }

  /// Toggle conclusão de uma tarefa
  Future<void> toggleTaskInList(String listId, String taskId) async {
    if (!_tasksByList.containsKey(listId)) return;

    final now = DateTime.now();
    final index = _tasksByList[listId]!.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasksByList[listId]![index];
    final newStatus = !task.isCompleted;

    ProcrastinationTask updatedTask;
    if (newStatus) {
      final urgency = task.startTime != null || task.endTime != null
          ? task.getUrgencyLevel(now)
          : task.scheduledDate != null
              ? ProcrastinationTask.getUrgencyForDate(task.scheduledDate!, now)
              : UrgencyLevel.green;

      updatedTask = task.copyWith(
        isCompleted: true,
        completedUrgencyLevel: urgency,
      );
    } else {
      updatedTask = ProcrastinationTask(
        id: task.id,
        title: task.title,
        description: task.description,
        scheduledDate: task.scheduledDate,
        startTime: task.startTime,
        endTime: task.endTime,
        isCompleted: false,
        listId: task.listId,
        order: task.order,
        repetition: task.repetition,
        repetitionConfig: task.repetitionConfig,
        completedUrgencyLevel: null,
      );
    }

    _tasksByList[listId]![index] = updatedTask;

    // Atualiza nos dias também
    for (final key in _days.keys.toList()) {
      final day = _days[key]!;
      final taskIndex = day.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        final updatedTasks = List<ProcrastinationTask>.from(day.tasks);
        updatedTasks[taskIndex] = updatedTask;
        _days[key] = day.copyWith(tasks: updatedTasks);
      }
    }

    if (updatedTask.isCompleted) {
      await _cancelTaskNotification(taskId);

      // Lógica de Repetição: Cria a próxima ocorrência se for uma tarefa repetitiva
      if (task.repetition != TaskRepetition.none) {
        await _handleTaskRepetition(listId, updatedTask);
      }
    } else {
      await _scheduleTaskNotification(updatedTask);
    }

    await _saveData();
    notifyListeners();

    // Verifica se completou a lista
    if (updatedTask.isCompleted) {
      await _checkListCompletion(listId);
    }
  }

  /// Gerencia a criação da próxima ocorrência de uma tarefa repetitiva
  Future<void> _handleTaskRepetition(
      String listId, ProcrastinationTask completedTask) async {
    final DateTime? currentBaseDate =
        completedTask.scheduledDate ?? completedTask.startTime;
    if (currentBaseDate == null) return;

    final nextDate = _calculateNextRepetitionDate(completedTask);
    if (nextDate == null) return;

    // Se houver limite de ocorrências, verifica
    if (completedTask.repetitionConfig?.occurrences != null) {
      // Aqui poderíamos rastrear o número da ocorrência, mas para simplificar
      // vamos apenas decrementar ou parar se chegar ao limite se tivéssemos esse campo.
      // Por enquanto, criamos a próxima se não ultrapassar a data de término.
    }

    if (completedTask.repetitionConfig?.endDate != null &&
        nextDate.isAfter(completedTask.repetitionConfig!.endDate!)) {
      return;
    }

    // Cria a nova tarefa baseada na atual
    final nextTask = ProcrastinationTask(
      id: const Uuid().v4(),
      title: completedTask.title,
      description: completedTask.description,
      scheduledDate: completedTask.scheduledDate != null ? nextDate : null,
      startTime: completedTask.startTime != null
          ? DateTime(
              nextDate.year,
              nextDate.month,
              nextDate.day,
              completedTask.startTime!.hour,
              completedTask.startTime!.minute,
            )
          : null,
      endTime: completedTask.endTime != null
          ? DateTime(
              nextDate.year,
              nextDate.month,
              nextDate.day,
              completedTask.endTime!.hour,
              completedTask.endTime!.minute,
            )
          : null,
      isCompleted: false,
      listId: listId,
      order: completedTask.order, // Mantém a mesma ordem
      repetition: completedTask.repetition,
      repetitionConfig: completedTask.repetitionConfig,
    );

    await addTaskToList(listId, nextTask);
  }

  DateTime? _calculateNextRepetitionDate(ProcrastinationTask task) {
    final baseDate = task.scheduledDate ?? task.startTime;
    if (baseDate == null) return null;

    final config = task.repetitionConfig;
    final interval = config?.interval ?? 1;

    switch (task.repetition) {
      case TaskRepetition.daily:
        return baseDate.add(Duration(days: interval));
      case TaskRepetition.weekly:
        // Se houver dias da semana específicos
        if (config?.weekDays != null && config!.weekDays!.isNotEmpty) {
          final sortedDays = List<int>.from(config.weekDays!)..sort();
          final currentDay = baseDate.weekday % 7; // 0=Dom

          // Encontra o próximo dia na lista após o atual
          int? nextDay;
          for (final d in sortedDays) {
            if (d > currentDay) {
              nextDay = d;
              break;
            }
          }

          if (nextDay != null) {
            return baseDate.add(Duration(days: nextDay - currentDay));
          } else {
            // Volta para o primeiro dia da próxima semana (intervalo)
            final daysToNextWeek = (7 - currentDay) + sortedDays.first;
            // Só aplica o intervalo de semanas se estivermos voltando para o início da lista de dias
            final totalDays = daysToNextWeek + (interval - 1) * 7;
            return baseDate.add(Duration(days: totalDays));
          }
        }
        return baseDate.add(Duration(days: 7 * interval));
      case TaskRepetition.monthly:
        return DateTime(baseDate.year, baseDate.month + interval, baseDate.day);
      case TaskRepetition.yearly:
        return DateTime(baseDate.year + interval, baseDate.month, baseDate.day);
      case TaskRepetition.custom:
        if (config?.unit == 'day') {
          return baseDate.add(Duration(days: interval));
        }
        if (config?.unit == 'week') {
          return baseDate.add(Duration(days: 7 * interval));
        }
        if (config?.unit == 'month') {
          return DateTime(
              baseDate.year, baseDate.month + interval, baseDate.day);
        }
        if (config?.unit == 'year') {
          return DateTime(
              baseDate.year + interval, baseDate.month, baseDate.day);
        }
        return baseDate.add(Duration(days: interval));
      case TaskRepetition.none:
        return null;
    }
  }

  /// Verifica se a lista foi 100% concluída sem atrasos
  Future<void> _checkListCompletion(String listId) async {
    final tasks = _tasksByList[listId] ?? [];
    if (tasks.isEmpty) return;

    final allCompleted = tasks.every((t) => t.isCompleted);
    if (!allCompleted) return;

    // Verifica se todas foram concluídas sem vermelho
    final hasLateTask = tasks.any(
        (t) => t.isCompleted && t.completedUrgencyLevel == UrgencyLevel.red);

    if (!hasLateTask) {
      // Lista concluída sem atrasos!
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1 && !_lists[index].isFullyCompleted) {
        _lists[index] = _lists[index].copyWith(
          isFullyCompleted: true,
          completedAt: DateTime.now(),
        );
        await _saveAllLocal();
      }
    }
  }

  /// Retorna listas que foram 100% concluídas sem atrasos
  List<TaskList> getFullyCompletedLists() {
    return _lists.where((l) => l.isFullyCompleted).toList();
  }

  // ===========================================
  // MÉTODOS LEGADOS (compatibilidade)
  // ===========================================

  List<ProcrastinationTask> getTasksForDay(DateTime date) {
    final key = _dateKey(date);
    final tasks = _days[key]?.tasks ?? [];

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

    final taskWithDate = task.copyWith(scheduledDate: date);
    final updatedTasks = List<ProcrastinationTask>.from(day.tasks)
      ..add(taskWithDate);

    _days[key] = day.copyWith(tasks: updatedTasks);

    // Adiciona à lista também
    await addTaskToList(task.listId, taskWithDate);
  }

  Future<void> updateTask(
      DateTime date, ProcrastinationTask updatedTask) async {
    final key = _dateKey(date);
    final day = _days[key];
    if (day == null) return;

    final updatedTasks =
        day.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
    _days[key] = day.copyWith(tasks: updatedTasks);

    await updateTaskInList(updatedTask.listId, updatedTask);
  }

  Future<void> toggleTaskCompletion(DateTime date, String taskId) async {
    final key = _dateKey(date);
    final day = _days[key];
    if (day == null) return;

    final task = day.tasks.firstWhere((t) => t.id == taskId);
    await toggleTaskInList(task.listId, taskId);
  }

  Future<void> removeTask(DateTime date, String taskId) async {
    final key = _dateKey(date);
    final day = _days[key];
    if (day == null) return;

    final task = day.tasks.firstWhere((t) => t.id == taskId);
    await removeTaskFromList(task.listId, taskId);
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

    if (day.isDayComplete && !allCompleted) {
      _days[key] = day.copyWith(isDayComplete: false);
      await _saveData();
      notifyListeners();
    }

    return false;
  }

  Future<void> deleteAllTasks() async {
    _days = {};
    _tasksByList = {};
    await _saveData();

    final todayKey = _dateKey(DateTime.now());
    await _prefs.setString('procrastination_last_check', todayKey);

    notifyListeners();
  }

  // ===========================================
  // NOTIFICAÇÕES
  // ===========================================

  Future<void> _scheduleTaskNotification(ProcrastinationTask task) async {
    if (task.isCompleted) {
      await _cancelTaskNotification(task.id);
      return;
    }

    final scheduledDate = task.startTime ??
        (task.scheduledDate != null
            ? DateTime(
                task.scheduledDate!.year,
                task.scheduledDate!.month,
                task.scheduledDate!.day,
                9,
                0,
              )
            : null);

    if (scheduledDate == null || scheduledDate.isBefore(DateTime.now())) return;

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
          cancelNotification: true,
        ),
        const fln.AndroidNotificationAction(
          'delete',
          'Apagar',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const fln.AndroidNotificationAction(
          'postpone',
          'Adiar',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );
  }

  Future<void> _cancelTaskNotification(String taskId) async {
    final int notificationId = taskId.hashCode.abs();
    await NotificationService.cancelNotification(notificationId);
  }

  Future<void> handleNotificationAction(String actionId, String payload) async {
    debugPrint(
        '🔔 ProcrastinationService: Processando ação $actionId com payload $payload');

    if (!payload.startsWith('task_')) return;
    final taskId = payload.replaceFirst('task_', '');

    // Encontra a tarefa e sua lista
    String? taskListId;
    for (var entry in _tasksByList.entries) {
      if (entry.value.any((t) => t.id == taskId)) {
        taskListId = entry.key;
        break;
      }
    }

    if (taskListId == null) {
      debugPrint('⚠️ Tarefa $taskId não encontrada para processar ação.');
      return;
    }

    if (actionId == 'done') {
      await toggleTaskInList(taskListId, taskId);
      debugPrint('✅ Tarefa $taskId marcada como concluída via notificação.');
    } else if (actionId == 'delete') {
      await removeTaskFromList(taskListId, taskId);
      debugPrint('🗑️ Tarefa $taskId removida via notificação.');
    }
  }

  // ===========================================
  // ESTATÍSTICAS DE DESPROCRASTINAÇÃO
  // ===========================================

  Map<String, dynamic> getCompletedTasksStats() {
    int greenCount = 0;
    int yellowCount = 0;
    int redCount = 0;
    int totalCompleted = 0;

    // Conta de todas as listas
    for (final tasks in _tasksByList.values) {
      for (final task in tasks) {
        if (task.isCompleted && task.completedUrgencyLevel != null) {
          totalCompleted++;
          switch (task.completedUrgencyLevel!) {
            case UrgencyLevel.green:
              greenCount++;
              break;
            case UrgencyLevel.yellow:
              yellowCount++;
              break;
            case UrgencyLevel.red:
              redCount++;
              break;
          }
        }
      }
    }

    // Também conta dos dias (compatibilidade)
    for (final day in _days.values) {
      for (final task in day.tasks) {
        if (task.isCompleted && task.completedUrgencyLevel != null) {
          // Evita contagem dupla
          bool alreadyCounted = false;
          for (final tasks in _tasksByList.values) {
            if (tasks.any((t) => t.id == task.id)) {
              alreadyCounted = true;
              break;
            }
          }
          if (alreadyCounted) continue;

          totalCompleted++;
          switch (task.completedUrgencyLevel!) {
            case UrgencyLevel.green:
              greenCount++;
              break;
            case UrgencyLevel.yellow:
              yellowCount++;
              break;
            case UrgencyLevel.red:
              redCount++;
              break;
          }
        }
      }
    }

    final greenPercent =
        totalCompleted > 0 ? (greenCount / totalCompleted * 100) : 0.0;
    final yellowPercent =
        totalCompleted > 0 ? (yellowCount / totalCompleted * 100) : 0.0;
    final redPercent =
        totalCompleted > 0 ? (redCount / totalCompleted * 100) : 0.0;

    String profile;
    String profileEmoji;
    String profileDescription;

    if (totalCompleted == 0) {
      profile = 'Sem dados';
      profileEmoji = '📊';
      profileDescription =
          'Complete algumas tarefas para ver seu perfil de desprocrastinação!';
    } else if (greenPercent >= 50) {
      profile = 'Zen';
      profileEmoji = '🧘';
      profileDescription =
          'Você é um planejador disciplinado! Resolve suas tarefas com antecedência.';
    } else if (redPercent >= 50) {
      profile = 'Adrenalina';
      profileEmoji = '⚡';
      profileDescription =
          'Você deixa tudo para última hora. Isso gera estresse desnecessário!';
    } else if (yellowPercent >= 40) {
      profile = 'Na Trave';
      profileEmoji = '⚽';
      profileDescription =
          'Você flerta com o prazo, mas entrega. Tente antecipar mais!';
    } else {
      profile = 'Equilibrado';
      profileEmoji = '⚖️';
      profileDescription =
          'Seu comportamento varia. Tente migrar para a zona verde!';
    }

    return {
      'totalCompleted': totalCompleted,
      'greenCount': greenCount,
      'yellowCount': yellowCount,
      'redCount': redCount,
      'greenPercent': greenPercent,
      'yellowPercent': yellowPercent,
      'redPercent': redPercent,
      'profile': profile,
      'profileEmoji': profileEmoji,
      'profileDescription': profileDescription,
    };
  }

  UrgencyLevel getTaskUrgency(ProcrastinationTask task, DateTime taskDate) {
    final now = DateTime.now();
    if (task.startTime != null || task.endTime != null) {
      return task.getUrgencyLevel(now);
    }
    return ProcrastinationTask.getUrgencyForDate(taskDate, now);
  }
}
