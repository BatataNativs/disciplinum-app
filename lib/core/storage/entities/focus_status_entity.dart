import 'package:objectbox/objectbox.dart';

@Entity()
class FocusStatusEntity {
  @Id()
  int id = 0;

  @Unique()
  late String userId;

  int respectedPeriods = 0;
  List<String> earnedInsigniaNames = [];

  int? startHour;
  int? startMinute;
  int? endHour;
  int? endMinute;

  DateTime lastUpdated = DateTime.now();
}
