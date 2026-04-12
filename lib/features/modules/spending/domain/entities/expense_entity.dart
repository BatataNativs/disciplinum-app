import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/fixed_expense_model.dart';

@Entity()
class ExpenseEntity {
  @Id()
  int id = 0;

  @Unique()
  late String uuid;

  late String name;
  late double amount;
  late String currency;
  late int dueDay;
  bool isPaid = false;
  DateTime? lastPaid;
  bool notificationsEnabled = true;
  int notificationDaysBefore = 1;

  FixedExpenseModel toDomain() {
    return FixedExpenseModel(
      id: uuid,
      name: name,
      amount: amount,
      currency: currency,
      dueDay: dueDay,
      isPaid: isPaid,
      lastPaid: lastPaid,
      notificationsEnabled: notificationsEnabled,
      notificationDaysBefore: notificationDaysBefore,
    );
  }

  static ExpenseEntity fromDomain(FixedExpenseModel model) {
    return ExpenseEntity()
      ..uuid = model.id
      ..name = model.name
      ..amount = model.amount
      ..currency = model.currency
      ..dueDay = model.dueDay
      ..isPaid = model.isPaid
      ..lastPaid = model.lastPaid
      ..notificationsEnabled = model.notificationsEnabled
      ..notificationDaysBefore = model.notificationDaysBefore;
  }
}
