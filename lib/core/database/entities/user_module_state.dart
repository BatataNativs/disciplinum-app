import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

@Entity()
class UserModuleState {
  @Id()
  int id = 0;

  late String userId;
  late int nicheId;
  late bool isActive;
  late int consecutiveDays;
  @Property(type: PropertyType.date)
  late DateTime lastAccessDate;
  @Property(type: PropertyType.date)
  late DateTime createdAt;
  @Property(type: PropertyType.date)
  late DateTime updatedAt;
  int focusPeriodsRespected = 0;
  String? maxMedal;
  String? additionalData;

  UserModuleState()
      : userId = '',
        nicheId = 0,
        isActive = false,
        consecutiveDays = 0,
        lastAccessDate = DateTime.now(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  factory UserModuleState.create({
    required String userId,
    required int nicheId,
    bool isActive = false,
  }) {
    final now = DateTime.now();
    final entity = UserModuleState();
    entity.userId = userId;
    entity.nicheId = nicheId;
    entity.isActive = isActive;
    entity.consecutiveDays = 0;
    entity.lastAccessDate = now;
    entity.createdAt = now;
    entity.updatedAt = now;
    return entity;
  }

  NicheId get niche => NicheId.values.firstWhere(
        (id) => id.id == nicheId,
        orElse: () => NicheId.reading,
      );

  UserModuleState copyWith({
    String? userId,
    int? nicheId,
    bool? isActive,
    int? consecutiveDays,
    DateTime? lastAccessDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? focusPeriodsRespected,
    String? maxMedal,
    String? additionalData,
  }) {
    final entity = UserModuleState();
    entity.id = id;
    entity.userId = userId ?? this.userId;
    entity.nicheId = nicheId ?? this.nicheId;
    entity.isActive = isActive ?? this.isActive;
    entity.consecutiveDays = consecutiveDays ?? this.consecutiveDays;
    entity.lastAccessDate = lastAccessDate ?? this.lastAccessDate;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    entity.focusPeriodsRespected = focusPeriodsRespected ?? this.focusPeriodsRespected;
    entity.maxMedal = maxMedal ?? this.maxMedal;
    entity.additionalData = additionalData ?? this.additionalData;
    return entity;
  }
}
