import 'package:isar/isar.dart';

part 'focus_status_entity.g.dart';

@collection
class FocusStatusEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  int respectedPeriods = 0;
  List<String> earnedInsigniaNames = [];

  // Intervalo de foco (horas e minutos)
  int? startHour;
  int? startMinute;
  int? endHour;
  int? endMinute;

  DateTime lastUpdated = DateTime.now();
}
