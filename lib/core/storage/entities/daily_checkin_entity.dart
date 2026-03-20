import 'package:isar/isar.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

part 'daily_checkin_entity.g.dart';

/// Entidade para persistir check-ins diários (ex: Smoking, Binge Eating)
/// Substitui o uso de SharedPreferences para este fim.
@Collection()
class DailyCheckin {
  Id? id;

  @Index(composite: [CompositeIndex('dateStr')], unique: true)
  @enumerated
  late NicheId nicheId;

  @Index()
  late String dateStr; // Formato yyyy-MM-dd

  late DateTime createdAt;

  DailyCheckin({
    required this.nicheId,
    required this.dateStr,
  }) : createdAt = DateTime.now();
}
