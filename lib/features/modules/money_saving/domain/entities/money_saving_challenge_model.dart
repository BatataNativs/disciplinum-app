/// Modelo de dados para o Desafio da Poupança
class MoneySavingChallengeModel {
  final String id;
  final String title;
  final double targetAmount;
  final int periodValue;
  final String periodType; // 'dias', 'meses', 'anos', 'indeterminado'
  final int gridSize;
  final double minValue;
  final double maxValue;
  final List<int> markedCells;
  final List<double> cellValues;
  final DateTime createdAt;
  final String currency;
  final bool isActive;

  MoneySavingChallengeModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.periodValue,
    required this.periodType,
    required this.gridSize,
    required this.minValue,
    required this.maxValue,
    required this.markedCells,
    required this.cellValues,
    required this.createdAt,
    this.currency = 'R\$',
    this.isActive = false,
    this.notifFrequency =
        'disabled', // 'diario', 'semanal', 'mensal', 'disabled'
    this.notifTime = '09:00',
    this.notifDayOfWeek = 1, // 1 (Segunda) a 7 (Domingo)
    this.notifDayOfMonth = 1, // 1 a 31
  });

  final String notifFrequency;
  final String notifTime;
  final int notifDayOfWeek;
  final int notifDayOfMonth;

  /// Calcula o total já guardado (soma dos valores das células marcadas)
  double get totalSaved {
    double sum = 0;
    for (final index in markedCells) {
      if (index >= 0 && index < cellValues.length) {
        sum += cellValues[index];
      }
    }
    return sum;
  }

  /// Calcula o progresso como percentual
  double get progressPercent {
    if (targetAmount <= 0) return 0;
    return (totalSaved / targetAmount).clamp(0.0, 1.0);
  }

  /// Número total de células no grid
  int get totalCells => cellValues.length;

  /// Verifica se o desafio foi concluído (progresso atingiu 100%)
  bool get isComplete => progressPercent >= 1.0;

  /// Cria uma cópia com célula marcada/desmarcada
  MoneySavingChallengeModel toggleCell(int index) {
    final newMarked = List<int>.from(markedCells);
    if (newMarked.contains(index)) {
      newMarked.remove(index);
    } else {
      newMarked.add(index);
    }
    return copyWith(markedCells: newMarked);
  }

  MoneySavingChallengeModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    int? periodValue,
    String? periodType,
    int? gridSize,
    double? minValue,
    double? maxValue,
    List<int>? markedCells,
    List<double>? cellValues,
    DateTime? createdAt,
    String? currency,
    String? notifFrequency,
    String? notifTime,
    int? notifDayOfWeek,
    int? notifDayOfMonth,
    bool? isActive,
  }) {
    return MoneySavingChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      periodValue: periodValue ?? this.periodValue,
      periodType: periodType ?? this.periodType,
      gridSize: gridSize ?? this.gridSize,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      markedCells: markedCells ?? this.markedCells,
      cellValues: cellValues ?? this.cellValues,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
      notifFrequency: notifFrequency ?? this.notifFrequency,
      notifTime: notifTime ?? this.notifTime,
      notifDayOfWeek: notifDayOfWeek ?? this.notifDayOfWeek,
      notifDayOfMonth: notifDayOfMonth ?? this.notifDayOfMonth,
      isActive: isActive ?? this.isActive,
    );
  }

  static List<double> generateCellValues({
    required double minValue,
    required double maxValue,
    required double targetAmount,
  }) {
    if (targetAmount <= 0) return [];

    double avgAporte = (minValue + maxValue) / 2.0;
    if (avgAporte <= 0) avgAporte = 1.0;

    int totalCellsCount = (targetAmount / avgAporte).ceil();
    if (totalCellsCount < 1) totalCellsCount = 1;
    if (totalCellsCount > 500) {
      totalCellsCount = 500; // Proteção contra loops gigantes
    }

    // 1. Definimos o mínimo real respeitando a média
    final averagePerCell = targetAmount / totalCellsCount;
    double actualMin = minValue;
    if (actualMin > averagePerCell) {
      actualMin =
          averagePerCell * 0.8; // Se o min for impossível, usamos 80% da média
    }
    if (actualMin < 0.01) {
      actualMin = 0.01;
    }

    // 2. Preenchemos todas as células com o valor mínimo inicial
    final values = List<double>.filled(totalCellsCount, actualMin);
    double currentSum = actualMin * totalCellsCount;

    // 3. Distribuímos o restante (targetAmount - currentSum)
    double remainingToDistribute = targetAmount - currentSum;

    if (remainingToDistribute > 0) {
      // Usamos uma distribuição ponderada (linear crescente) para dar variedade
      final double totalWeight = (totalCellsCount * (totalCellsCount - 1)) / 2;

      for (int i = 0; i < totalCellsCount; i++) {
        double weight = i.toDouble();
        double share = (weight / totalWeight) * remainingToDistribute;

        // Somamos a parte desta célula e arredondamos
        double newValue = values[i] + share;
        double roundedValue = _roundToNiceValue(newValue);

        // Não podemos exceder o targetAmount aqui
        double diff = roundedValue - values[i];
        if (currentSum + diff > targetAmount) {
          diff = targetAmount - currentSum;
          roundedValue = values[i] + diff;
        }

        values[i] = double.parse(roundedValue.toStringAsFixed(2));
        currentSum += diff;
      }
    }

    // 4. Ajuste fino final caso tenha sobrado algum centavo de arredondamento
    double finalDiff = targetAmount - currentSum;
    if (finalDiff.abs() > 0.001) {
      values[totalCellsCount - 1] = double.parse(
          (values[totalCellsCount - 1] + finalDiff).toStringAsFixed(2));
    }

    // 5. Embaralha para ficar visualmente interessante
    values.shuffle();

    return values;
  }

  /// Arredonda para valores mais "bonitos" (múltiplos de 5, 10, 25, 50, 100)
  static double _roundToNiceValue(double value) {
    if (value <= 0) return 0.01; // Mínimo de 1 centavo
    if (value < 10) {
      return double.parse(value.toStringAsFixed(2));
    } else if (value < 50) {
      return (value / 5).round() * 5.0;
    } else if (value < 100) {
      return (value / 10).round() * 10.0;
    } else if (value < 500) {
      return (value / 25).round() * 25.0;
    } else {
      return (value / 50).round() * 50.0;
    }
  }

  /// Serializa para JSON (Supabase e SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'period_value': periodValue,
      'period_type': periodType,
      'grid_size': gridSize,
      'min_value': minValue,
      'max_value': maxValue,
      'marked_cells': markedCells,
      'cell_values': cellValues,
      'created_at': createdAt.toIso8601String(),
      'currency': currency,
      'notif_frequency': notifFrequency,
      'notif_time': notifTime,
      'notif_day_of_week': notifDayOfWeek,
      'notif_day_of_month': notifDayOfMonth,
      'is_active': isActive,
    };
  }

  /// Deserializa do JSON
  factory MoneySavingChallengeModel.fromJson(Map<String, dynamic> json) {
    return MoneySavingChallengeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Desafio',
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0,
      periodValue: json['period_value'] as int? ?? 0,
      periodType: json['period_type'] as String? ?? 'indeterminado',
      gridSize: json['grid_size'] as int? ?? 10,
      minValue: (json['min_value'] as num?)?.toDouble() ?? 0,
      maxValue: (json['max_value'] as num?)?.toDouble() ?? 0,
      markedCells:
          (json['marked_cells'] as List?)?.map((e) => e as int).toList() ?? [],
      cellValues: (json['cell_values'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      currency: json['currency'] as String? ?? 'R\$',
      notifFrequency: json['notif_frequency'] as String? ?? 'disabled',
      notifTime: json['notif_time'] as String? ?? '09:00',
      notifDayOfWeek: json['notif_day_of_week'] as int? ?? 1,
      notifDayOfMonth: json['notif_day_of_month'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
