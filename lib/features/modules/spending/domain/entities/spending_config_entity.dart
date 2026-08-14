import 'package:objectbox/objectbox.dart';

/// Entidade de configuração do módulo Spending
/// Persistida localmente via ObjectBox
@Entity()
class SpendingConfigEntity {
  @Id()
  int id = 0;

  @Unique()
  String userId;

  bool isModuleActive = false;
  double monthlyBudget = 0.0;
  String currency = 'R\$';
  bool enableNotifications = true;
  int reminderDay = 1; // Dia do mês para lembrete (1-31)

  // === APP LOCK (App Bloqueador de E-commerce) ===
  bool enableAppLock = false;
  List<String> monitoredApps = [];

  // === BLOQUEIO POR HORÁRIO ===
  bool enableTimeWindow = false;
  String allowedStartTime = '08:00'; // HH:MM
  String allowedEndTime = '22:00'; // HH:MM
  bool blockOnWeekends = false;
  String? weekendAllowedStartTime; // HH:MM
  String? weekendAllowedEndTime; // HH:MM

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  SpendingConfigEntity({
    required this.userId,
    this.isModuleActive = false,
    this.monthlyBudget = 0.0,
    this.currency = 'R\$',
    this.enableNotifications = true,
    this.reminderDay = 1,
    this.enableAppLock = false,
    this.enableTimeWindow = false,
    this.allowedStartTime = '08:00',
    this.allowedEndTime = '22:00',
    this.blockOnWeekends = false,
    this.weekendAllowedStartTime,
    this.weekendAllowedEndTime,
  });

  void touch() {
    updatedAt = DateTime.now();
  }

  SpendingConfigEntity copyWith({
    String? userId,
    bool? isModuleActive,
    double? monthlyBudget,
    String? currency,
    bool? enableNotifications,
    int? reminderDay,
    bool? enableAppLock,
    List<String>? monitoredApps,
    bool? enableTimeWindow,
    String? allowedStartTime,
    String? allowedEndTime,
    bool? blockOnWeekends,
    String? weekendAllowedStartTime,
    String? weekendAllowedEndTime,
  }) {
    final entity = SpendingConfigEntity(
      userId: userId ?? this.userId,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      currency: currency ?? this.currency,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderDay: reminderDay ?? this.reminderDay,
      enableAppLock: enableAppLock ?? this.enableAppLock,
      enableTimeWindow: enableTimeWindow ?? this.enableTimeWindow,
      allowedStartTime: allowedStartTime ?? this.allowedStartTime,
      allowedEndTime: allowedEndTime ?? this.allowedEndTime,
      blockOnWeekends: blockOnWeekends ?? this.blockOnWeekends,
      weekendAllowedStartTime: weekendAllowedStartTime ?? this.weekendAllowedStartTime,
      weekendAllowedEndTime: weekendAllowedEndTime ?? this.weekendAllowedEndTime,
    )
      ..id = id
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..monitoredApps = monitoredApps ?? List<String>.from(this.monitoredApps);
    return entity;
  }
}

