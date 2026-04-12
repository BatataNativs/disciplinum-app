import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/shared/domain/models/time_of_day_range.dart';

@Entity()
class FocusIntervalEntity {
  @Id()
  int id = 0;

  int nicheId;
  int startHour;
  int startMinute;
  int endHour;
  int endMinute;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  FocusIntervalEntity({
    required this.nicheId,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  /// Cria entity a partir do model de domínio
  factory FocusIntervalEntity.fromDomain({
    required int nicheId,
    required TimeOfDayRange interval,
  }) {
    return FocusIntervalEntity(
      nicheId: nicheId,
      startHour: interval.start.hour,
      startMinute: interval.start.minute,
      endHour: interval.end.hour,
      endMinute: interval.end.minute,
    );
  }

  /// Converte para model de domínio
  TimeOfDayRange toDomain() {
    return TimeOfDayRange.fromHours(
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
    );
  }

  /// Cria uma cópia com novos valores
  FocusIntervalEntity copyWith({
    int? nicheId,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = FocusIntervalEntity(
      nicheId: nicheId ?? this.nicheId,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
    
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    
    return entity;
  }

  /// Atualiza timestamp de modificação
  void touch() {
    updatedAt = DateTime.now();
  }

  @override
  String toString() {
    return 'FocusIntervalEntity(nicheId: $nicheId, interval: ${toDomain()})';
  }
}
