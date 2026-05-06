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
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  SpendingConfigEntity({
    required this.userId,
    this.isModuleActive = false,
    this.monthlyBudget = 0.0,
    this.currency = 'R\$',
    this.enableNotifications = true,
    this.reminderDay = 1,
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
  }) {
    return SpendingConfigEntity(
      userId: userId ?? this.userId,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      currency: currency ?? this.currency,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderDay: reminderDay ?? this.reminderDay,
    )..id = id
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();
  }
}
