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
        return const Color(0xFF4CAF50); // Verde
      case UrgencyLevel.yellow:
        return const Color(0xFFFFC107); // Amarelo
      case UrgencyLevel.red:
        return const Color(0xFFF44336); // Vermelho
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

class ProcrastinationTask {
  final String id;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime; // Se null, é ponto único
  bool isCompleted;

  /// Nível de urgência no momento em que a tarefa foi concluída.
  /// Null se ainda não foi concluída.
  final UrgencyLevel? completedUrgencyLevel;

  ProcrastinationTask({
    required this.id,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
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
    } else {
      // Tarefa sem horário - considera fim do dia (23:59)
      // Usa o dia atual pois a tarefa está associada a uma data específica
      // O código de chamada deve passar a data correta
      return UrgencyLevel.red; // Fallback - será corrigido pelo caller
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
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    UrgencyLevel? completedUrgencyLevel,
  }) {
    return ProcrastinationTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedUrgencyLevel:
          completedUrgencyLevel ?? this.completedUrgencyLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_completed': isCompleted,
      'completed_urgency_level': completedUrgencyLevel?.name,
    };
  }

  factory ProcrastinationTask.fromJson(Map<String, dynamic> json) {
    return ProcrastinationTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      isCompleted: json['is_completed'] ?? false,
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
