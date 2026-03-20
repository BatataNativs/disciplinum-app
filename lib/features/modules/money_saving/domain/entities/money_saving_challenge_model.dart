/// Entidade que representa o Desafio da Poupança
class MoneySavingChallengeModel {
  final String id;
  final String title;
  final double targetAmount;
  final int periodValue; // 1=daily, 7=weekly, 30=monthly
  final String periodType;
  final double minValue;
  final double maxValue;
  final DateTime startDate;
  final DateTime? endDate;
  final double currentAmount;
  final List<double> cellValues; // Valores de cada célula do grid
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MoneySavingChallengeModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.periodValue,
    required this.periodType,
    required this.minValue,
    required this.maxValue,
    required this.startDate,
    this.endDate,
    this.currentAmount = 0.0,
    this.cellValues = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory MoneySavingChallengeModel.fromJson(Map<String, dynamic> json) {
    return MoneySavingChallengeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      periodValue: (json['periodValue'] as num?)?.toInt() ?? 30,
      periodType: json['periodType']?.toString() ?? 'monthly',
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0.0,
      maxValue: (json['maxValue'] as num?)?.toDouble() ?? 1000.0,
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null 
          ? DateTime.tryParse(json['endDate']?.toString() ?? '') 
          : null,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      cellValues: (json['cellValues'] as List?)?.map((e) => (e as num?)?.toDouble() ?? 0.0).toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']?.toString() ?? '') 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'periodValue': periodValue,
      'periodType': periodType,
      'minValue': minValue,
      'maxValue': maxValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'currentAmount': currentAmount,
      'cellValues': cellValues,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  MoneySavingChallengeModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    int? periodValue,
    String? periodType,
    double? minValue,
    double? maxValue,
    DateTime? startDate,
    DateTime? endDate,
    double? currentAmount,
    List<double>? cellValues,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return MoneySavingChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      periodValue: periodValue ?? this.periodValue,
      periodType: periodType ?? this.periodType,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentAmount: currentAmount ?? this.currentAmount,
      cellValues: cellValues ?? this.cellValues,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt
    );
  }
}
