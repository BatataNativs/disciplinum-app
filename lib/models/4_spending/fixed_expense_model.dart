import 'package:flutter/material.dart';

/// Níveis de urgência baseados na proximidade do vencimento
enum UrgencyLevel {
  green, // Tranquilo - faltando mais de 5 dias
  yellow, // Atenção - de 5 a 2 dias
  red, // Crítico - de 2 dias até o vencimento
}

extension UrgencyLevelExtension on UrgencyLevel {
  Color get color {
    switch (this) {
      case UrgencyLevel.green:
        return const Color(0xFF2E7D32); // Verde mais escuro/saturado
      case UrgencyLevel.yellow:
        return const Color(0xFFF9A825); // Amarelo/Laranja mais visível
      case UrgencyLevel.red:
        return const Color(0xFFC62828); // Vermelho mais profundo
    }
  }

  String get label {
    switch (this) {
      case UrgencyLevel.green:
        return 'Tranquilo';
      case UrgencyLevel.yellow:
        return 'Atenção';
      case UrgencyLevel.red:
        return 'Urgente';
    }
  }

  String get emoji {
    switch (this) {
      case UrgencyLevel.green:
        return '🟢';
      case UrgencyLevel.yellow:
        return '🟡';
      case UrgencyLevel.red:
        return '🔴';
    }
  }

  static UrgencyLevel? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'green':
        return UrgencyLevel.green;
      case 'yellow':
        return UrgencyLevel.yellow;
      case 'red':
        return UrgencyLevel.red;
      default:
        return null;
    }
  }
}

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

  /// Calcula o nível de urgência baseado nos dias restantes até o vencimento
  /// - Verde: > 5 dias
  /// - Amarelo: 5 a 2 dias
  /// - Vermelho: 2 dias ou menos
  UrgencyLevel getUrgencyLevel() {
    if (isPaid) return UrgencyLevel.green;
    
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    // Data de vencimento deste mês
    DateTime dueDate = DateTime(currentYear, currentMonth, dueDay);
    
    // Se a data de vencimento já passou, considera o próximo mês
    if (dueDate.isBefore(now)) {
      if (currentMonth == 12) {
        dueDate = DateTime(currentYear + 1, 1, dueDay);
      } else {
        dueDate = DateTime(currentYear, currentMonth + 1, dueDay);
      }
    }
    
    final difference = dueDate.difference(now);
    final daysRemaining = difference.inDays;
    
    if (daysRemaining > 5) {
      return UrgencyLevel.green;
    } else if (daysRemaining >= 2) {
      return UrgencyLevel.yellow;
    } else {
      return UrgencyLevel.red;
    }
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
