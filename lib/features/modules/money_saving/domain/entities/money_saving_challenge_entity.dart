import 'package:isar/isar.dart';

part 'money_saving_challenge_entity.g.dart';

@collection
class MoneySavingChallengeEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String challengeId; // UUID do desafio

  String userId;
  String title;
  double targetAmount;
  int periodValue;
  String periodType; // 'dias', 'meses', 'anos', 'indeterminado'
  int gridSize;
  double minValue;
  double maxValue;
  String currency = 'R\$';
  bool isActive = false;
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  MoneySavingChallengeEntity({
    required this.challengeId,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.periodValue,
    required this.periodType,
    required this.gridSize,
    required this.minValue,
    required this.maxValue,
  });

  MoneySavingChallengeEntity copyWith({
    String? challengeId,
    String? userId,
    String? title,
    double? targetAmount,
    int? periodValue,
    String? periodType,
    int? gridSize,
    double? minValue,
    double? maxValue,
    String? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = MoneySavingChallengeEntity(
      challengeId: challengeId ?? this.challengeId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      periodValue: periodValue ?? this.periodValue,
      periodType: periodType ?? this.periodType,
      gridSize: gridSize ?? this.gridSize,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
    
    entity.currency = currency ?? this.currency;
    entity.isActive = isActive ?? this.isActive;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }

  /// Calcula o total economizado baseado nas células marcadas
  double calculateTotalSaved(List<int> markedCells, List<double> cellValues) {
    double total = 0.0;
    for (final cellIndex in markedCells) {
      if (cellIndex >= 0 && cellIndex < cellValues.length) {
        total += cellValues[cellIndex];
      }
    }
    return total;
  }

  /// Calcula o progresso (0.0 a 1.0)
  double calculateProgress(List<int> markedCells, int gridSize) {
    if (gridSize == 0) return 0.0;
    return markedCells.length / gridSize;
  }

  @override
  String toString() {
    return 'MoneySavingChallengeEntity(id: $challengeId, title: $title, target: $targetAmount)';
  }
}

/// Entidade separada para os valores das células do grid
@collection
class MoneySavingGridCellEntity {
  Id id = Isar.autoIncrement;

  String challengeId;
  int cellIndex;
  double value;
  bool isMarked = false;
  DateTime? markedAt;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  MoneySavingGridCellEntity({
    required this.challengeId,
    required this.cellIndex,
    required this.value,
  });

  MoneySavingGridCellEntity copyWith({
    String? challengeId,
    int? cellIndex,
    double? value,
    bool? isMarked,
    DateTime? markedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = MoneySavingGridCellEntity(
      challengeId: challengeId ?? this.challengeId,
      cellIndex: cellIndex ?? this.cellIndex,
      value: value ?? this.value,
    );
    
    entity.isMarked = isMarked ?? this.isMarked;
    entity.markedAt = markedAt ?? this.markedAt;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    
    return entity;
  }

  void mark() {
    isMarked = true;
    markedAt = DateTime.now();
    touch();
  }

  void unmark() {
    isMarked = false;
    markedAt = null;
    touch();
  }

  void touch() {
    updatedAt = DateTime.now();
  }

  @override
  String toString() {
    return 'MoneySavingGridCellEntity(challengeId: $challengeId, index: $cellIndex, value: $value, marked: $isMarked)';
  }
}
