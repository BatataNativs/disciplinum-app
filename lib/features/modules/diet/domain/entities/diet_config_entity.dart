import 'package:isar/isar.dart';

part 'diet_config_entity.g.dart';

@collection
class DietConfigEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String userId;

  // Metas nutricionais diárias
  int calories = 2000;
  double proteins = 150.0;
  double carbs = 250.0;
  double fats = 65.0;
  double fiber = 25.0;
  double water = 2000.0; // ml

  // Configurações
  bool enableNotifications = true;
  int reminderHour = 12;
  int reminderMinute = 0;
  
  // Estatísticas
  int streakDays = 0;
  DateTime? lastMealDate;
  double totalWeightLost = 0.0; // kg
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  DietConfigEntity({
    required this.userId,
  });

  DietConfigEntity copyWith({
    String? userId,
    int? calories,
    double? proteins,
    double? carbs,
    double? fats,
    double? fiber,
    double? water,
    bool? enableNotifications,
    int? reminderHour,
    int? reminderMinute,
    int? streakDays,
    DateTime? lastMealDate,
    double? totalWeightLost,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = DietConfigEntity(userId: userId ?? this.userId);
    entity.calories = calories ?? this.calories;
    entity.proteins = proteins ?? this.proteins;
    entity.carbs = carbs ?? this.carbs;
    entity.fats = fats ?? this.fats;
    entity.fiber = fiber ?? this.fiber;
    entity.water = water ?? this.water;
    entity.enableNotifications = enableNotifications ?? this.enableNotifications;
    entity.reminderHour = reminderHour ?? this.reminderHour;
    entity.reminderMinute = reminderMinute ?? this.reminderMinute;
    entity.streakDays = streakDays ?? this.streakDays;
    entity.lastMealDate = lastMealDate ?? this.lastMealDate;
    entity.totalWeightLost = totalWeightLost ?? this.totalWeightLost;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }
}
