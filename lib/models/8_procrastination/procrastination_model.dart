import 'package:flutter/material.dart';

/// Níveis de urgência dinâmica baseados no tempo restante até a tarefa
enum UrgencyLevel {
  green, // Tranquilo - tempo de sobra
  yellow, // Atenção - prazo se aproximando
  red, // Crítico - urgente
}

extension UrgencyLevelExtension on UrgencyLevel {
  Color get color {
    switch (this) {
      case UrgencyLevel.green:
        return const Color(0xFF2E7D32); // Verde mais escuro/saturado
      case UrgencyLevel.yellow:
        return const Color(0xFFF9A825); // Amarelo/Laranja mais visível
      case UrgencyLevel.red:
        return const Color(0xFFC62828); // Vermelho mais profundo
    }
  }

  String get label {
    switch (this) {
      case UrgencyLevel.green:
        return 'Tranquilo';
      case UrgencyLevel.yellow:
        return 'Atenção';
      case UrgencyLevel.red:
        return 'Urgente';
    }
  }

  String get emoji {
    switch (this) {
      case UrgencyLevel.green:
        return '🟢';
      case UrgencyLevel.yellow:
        return '🟡';
      case UrgencyLevel.red:
        return '🔴';
    }
  }

  static UrgencyLevel? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'green':
        return UrgencyLevel.green;
      case 'yellow':
        return UrgencyLevel.yellow;
      case 'red':
        return UrgencyLevel.red;
      default:
        return null;
    }
  }
}

/// Opções de repetição para tarefas
enum TaskRepetition {
  none, // Sem repetição
  daily, // Diariamente
  weekly, // Semanalmente
  monthly, // Mensalmente
  yearly, // Anualmente
  custom, // Personalizado
}

extension TaskRepetitionExtension on TaskRepetition {
  String get label {
    switch (this) {
      case TaskRepetition.none:
        return 'Não repetir';
      case TaskRepetition.daily:
        return 'Diariamente';
      case TaskRepetition.weekly:
        return 'Semanalmente';
      case TaskRepetition.monthly:
        return 'Mensalmente';
      case TaskRepetition.yearly:
        return 'Anualmente';
      case TaskRepetition.custom:
        return 'Personalizado';
    }
  }

  static TaskRepetition fromString(String? value) {
    if (value == null) return TaskRepetition.none;
    switch (value) {
      case 'daily':
        return TaskRepetition.daily;
      case 'weekly':
        return TaskRepetition.weekly;
      case 'monthly':
        return TaskRepetition.monthly;
      case 'yearly':
        return TaskRepetition.yearly;
      case 'custom':
        return TaskRepetition.custom;
      default:
        return TaskRepetition.none;
    }
  }
}

/// Modo de ordenação das tarefas em uma lista
enum SortMode {
  custom, // Ordem personalizada pelo usuário
  date, // Agrupado por data
}

extension SortModeExtension on SortMode {
  String get label {
    switch (this) {
      case SortMode.custom:
        return 'Personalizado';
      case SortMode.date:
        return 'Data';
    }
  }

  static SortMode fromString(String? value) {
    if (value == null) return SortMode.custom;
    switch (value) {
      case 'date':
        return SortMode.date;
      default:
        return SortMode.custom;
    }
  }
}

/// Lista de tarefas (aba superior no estilo Google Tasks)
class TaskList {
  final String id;
  String name;
  final DateTime createdAt;
  int order;
  SortMode sortMode;

  // Rastreia se a lista foi 100% concluída sem atrasos
  bool isFullyCompleted;
  DateTime? completedAt;

  TaskList({
    required this.id,
    required this.name,
    required this.createdAt,
    this.order = 0,
    this.sortMode = SortMode.custom,
    this.isFullyCompleted = false,
    this.completedAt,
  });

  TaskList copyWith({
    String? name,
    int? order,
    SortMode? sortMode,
    bool? isFullyCompleted,
    DateTime? completedAt,
  }) {
    return TaskList(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      order: order ?? this.order,
      sortMode: sortMode ?? this.sortMode,
      isFullyCompleted: isFullyCompleted ?? this.isFullyCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'order': order,
      'sort_mode': sortMode.name,
      'is_fully_completed': isFullyCompleted,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      order: json['order'] ?? 0,
      sortMode: SortModeExtension.fromString(json['sort_mode']),
      isFullyCompleted: json['is_fully_completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }
}

/// Configuração de repetição personalizada
class RepetitionConfig {
  final int interval; // A cada X (dias, semanas, meses, anos)
  final String unit; // 'day', 'week', 'month', 'year'
  final List<int>? weekDays; // Para repetição semanal (0=Dom, 1=Seg, etc)
  final DateTime? startDate;
  final DateTime? endDate; // Termina em data específica
  final int? occurrences; // Termina após X ocorrências

  RepetitionConfig({
    this.interval = 1,
    this.unit = 'day',
    this.weekDays,
    this.startDate,
    this.endDate,
    this.occurrences,
  });

  Map<String, dynamic> toJson() {
    return {
      'interval': interval,
      'unit': unit,
      'week_days': weekDays,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'occurrences': occurrences,
    };
  }

  factory RepetitionConfig.fromJson(Map<String, dynamic> json) {
    return RepetitionConfig(
      interval: json['interval'] ?? 1,
      unit: json['unit'] ?? 'day',
      weekDays:
          json['week_days'] != null ? List<int>.from(json['week_days']) : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      occurrences: json['occurrences'],
    );
  }
}

class ProcrastinationTask {
  final String id;
  final String title;
  final String? description;
  final DateTime? scheduledDate; // Data da tarefa (sem hora)
  final DateTime? startTime; // Hora de início
  final DateTime? endTime; // Hora de fim (se null, é ponto único)
  bool isCompleted;

  // ID da lista à qual pertence
  final String listId;

  // Ordem personalizada na lista
  int order;

  // Configuração de repetição
  final TaskRepetition repetition;
  final RepetitionConfig? repetitionConfig;

  /// Nível de urgência no momento em que a tarefa foi concluída.
  /// Null se ainda não foi concluída.
  final UrgencyLevel? completedUrgencyLevel;

  ProcrastinationTask({
    required this.id,
    required this.title,
    this.description,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.listId = 'default',
    this.order = 0,
    this.repetition = TaskRepetition.none,
    this.repetitionConfig,
    this.completedUrgencyLevel,
  });

  /// Calcula o nível de urgência atual baseado no tempo restante.
  ///
  /// Para tarefas SEM horário (apenas data):
  /// - Verde: > 48 horas (2+ dias)
  /// - Amarelo: 24-48 horas (amanhã)
  /// - Vermelho: < 24 horas (hoje)
  ///
  /// Para tarefas COM horário:
  /// - Verde: > 5 horas
  /// - Amarelo: 1-5 horas
  /// - Vermelho: < 1 hora
  UrgencyLevel getUrgencyLevel(DateTime now) {
    final DateTime targetDateTime;
    final bool hasTime;

    if (startTime != null) {
      targetDateTime = startTime!;
      hasTime = true;
    } else if (endTime != null) {
      targetDateTime = endTime!;
      hasTime = true;
    } else if (scheduledDate != null) {
      // Tarefa sem horário - considera fim do dia (23:59)
      targetDateTime = DateTime(
        scheduledDate!.year,
        scheduledDate!.month,
        scheduledDate!.day,
        23,
        59,
        59,
      );
      hasTime = false;
    } else {
      return UrgencyLevel.red; // Fallback
    }

    final difference = targetDateTime.difference(now);
    final hoursRemaining = difference.inHours;

    if (hasTime) {
      // Tarefa COM horário
      if (hoursRemaining > 5) {
        return UrgencyLevel.green;
      } else if (hoursRemaining >= 1) {
        return UrgencyLevel.yellow;
      } else {
        return UrgencyLevel.red;
      }
    } else {
      // Tarefa SEM horário (baseada em dias)
      if (hoursRemaining > 48) {
        return UrgencyLevel.green;
      } else if (hoursRemaining > 24) {
        return UrgencyLevel.yellow;
      } else {
        return UrgencyLevel.red;
      }
    }
  }

  /// Calcula urgência para uma tarefa associada a uma data específica (sem horário próprio)
  static UrgencyLevel getUrgencyForDate(DateTime taskDate, DateTime now) {
    // Considera o deadline como 23:59:59 do dia da tarefa
    final deadline =
        DateTime(taskDate.year, taskDate.month, taskDate.day, 23, 59, 59);
    final difference = deadline.difference(now);
    final hoursRemaining = difference.inHours;

    if (hoursRemaining > 48) {
      return UrgencyLevel.green;
    } else if (hoursRemaining > 24) {
      return UrgencyLevel.yellow;
    } else {
      return UrgencyLevel.red;
    }
  }

  ProcrastinationTask copyWith({
    String? title,
    String? description,
    DateTime? scheduledDate,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    String? listId,
    int? order,
    TaskRepetition? repetition,
    RepetitionConfig? repetitionConfig,
    UrgencyLevel? completedUrgencyLevel,
  }) {
    return ProcrastinationTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      listId: listId ?? this.listId,
      order: order ?? this.order,
      repetition: repetition ?? this.repetition,
      repetitionConfig: repetitionConfig ?? this.repetitionConfig,
      completedUrgencyLevel:
          completedUrgencyLevel ?? this.completedUrgencyLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_completed': isCompleted,
      'list_id': listId,
      'order': order,
      'repetition': repetition.name,
      'repetition_config': repetitionConfig?.toJson(),
      'completed_urgency_level': completedUrgencyLevel?.name,
    };
  }

  factory ProcrastinationTask.fromJson(Map<String, dynamic> json) {
    return ProcrastinationTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'])
          : null,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      isCompleted: json['is_completed'] ?? false,
      listId: json['list_id'] ?? 'default',
      order: json['order'] ?? 0,
      repetition: TaskRepetitionExtension.fromString(json['repetition']),
      repetitionConfig: json['repetition_config'] != null
          ? RepetitionConfig.fromJson(json['repetition_config'])
          : null,
      completedUrgencyLevel:
          UrgencyLevelExtension.fromString(json['completed_urgency_level']),
    );
  }
}

class ProcrastinationDay {
  final DateTime date;
  final List<ProcrastinationTask> tasks;
  final bool isDayComplete; // Se todas as tarefas foram feitas
  final bool isDayFailed; // Se o dia passou e não cumpriu

  ProcrastinationDay({
    required this.date,
    required this.tasks,
    this.isDayComplete = false,
    this.isDayFailed = false,
  });

  bool get allTasksCompleted =>
      tasks.isNotEmpty && tasks.every((t) => t.isCompleted);

  ProcrastinationDay copyWith({
    List<ProcrastinationTask>? tasks,
    bool? isDayComplete,
    bool? isDayFailed,
  }) {
    return ProcrastinationDay(
      date: date,
      tasks: tasks ?? this.tasks,
      isDayComplete: isDayComplete ?? this.isDayComplete,
      isDayFailed: isDayFailed ?? this.isDayFailed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'is_day_complete': isDayComplete,
      'is_day_failed': isDayFailed,
    };
  }

  factory ProcrastinationDay.fromJson(Map<String, dynamic> json) {
    return ProcrastinationDay(
      date: DateTime.parse(json['date']),
      tasks: (json['tasks'] as List?)
              ?.map((e) => ProcrastinationTask.fromJson(e))
              .toList() ??
          [],
      isDayComplete: json['is_day_complete'] ?? false,
      isDayFailed: json['is_day_failed'] ?? false,
    );
  }
}
