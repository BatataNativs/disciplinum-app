import 'package:flutter/material.dart';

/// Modelo de domínio para representar um intervalo de tempo
/// Usado para configurar horários de foco, notificações, etc.
class TimeOfDayRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeOfDayRange({required this.start, required this.end});

  /// Cria um intervalo a partir de horas e minutos
  factory TimeOfDayRange.fromHours({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) {
    return TimeOfDayRange(
      start: TimeOfDay(hour: startHour, minute: startMinute),
      end: TimeOfDay(hour: endHour, minute: endMinute),
    );
  }

  /// Converte para JSON (para persistência)
  Map<String, dynamic> toJson() {
    return {
      'start_hour': start.hour,
      'start_minute': start.minute,
      'end_hour': end.hour,
      'end_minute': end.minute,
    };
  }

  /// Cria a partir do JSON
  factory TimeOfDayRange.fromJson(Map<String, dynamic> json) {
    return TimeOfDayRange(
      start: TimeOfDay(
        hour: json['start_hour'] as int,
        minute: json['start_minute'] as int,
      ),
      end: TimeOfDay(
        hour: json['end_hour'] as int,
        minute: json['end_minute'] as int,
      ),
    );
  }

  /// Verifica se um horário está dentro do intervalo
  bool contains(TimeOfDay time) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final timeMinutes = time.hour * 60 + time.minute;
    
    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  /// Verifica se um DateTime está dentro do intervalo
  bool containsDateTime(DateTime dateTime) {
    return contains(TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));
  }

  /// Duração do intervalo em minutos
  int get durationInMinutes {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes - startMinutes;
  }

  @override
  String toString() {
    return '${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDayRange &&
        other.start.hour == start.hour &&
        other.start.minute == start.minute &&
        other.end.hour == end.hour &&
        other.end.minute == end.minute;
  }

  @override
  int get hashCode {
    return start.hour ^ start.minute ^ end.hour ^ end.minute;
  }
}
