class FixedExpenseModel {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final int dueDay;
  final bool isPaid;
  final DateTime? lastPaid;
  final bool notificationsEnabled;
  final int notificationDaysBefore;

  FixedExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.dueDay,
    this.isPaid = false,
    this.lastPaid,
    this.notificationsEnabled = true,
    this.notificationDaysBefore = 1,
  });

  factory FixedExpenseModel.fromJson(Map<String, dynamic> json) {
    return FixedExpenseModel(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      dueDay: json['dueDay'] as int,
      isPaid: json['isPaid'] ?? false,
      lastPaid:
          json['lastPaid'] != null ? DateTime.parse(json['lastPaid']) : null,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      notificationDaysBefore: json['notificationDaysBefore'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'currency': currency,
      'dueDay': dueDay,
      'isPaid': isPaid,
      'lastPaid': lastPaid?.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'notificationDaysBefore': notificationDaysBefore,
    };
  }

  FixedExpenseModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? currency,
    int? dueDay,
    bool? isPaid,
    DateTime? lastPaid,
    bool? notificationsEnabled,
    int? notificationDaysBefore,
  }) {
    return FixedExpenseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDay: dueDay ?? this.dueDay,
      isPaid: isPaid ?? this.isPaid,
      lastPaid: lastPaid ?? this.lastPaid,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationDaysBefore:
          notificationDaysBefore ?? this.notificationDaysBefore,
    );
  }
}
