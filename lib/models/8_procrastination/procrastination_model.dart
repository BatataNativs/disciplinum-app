class ProcrastinationTask {
  final String id;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime; // Se null, é ponto único
  bool isCompleted;

  ProcrastinationTask({
    required this.id,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
  });

  ProcrastinationTask copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
  }) {
    return ProcrastinationTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
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
