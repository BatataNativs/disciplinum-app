import 'package:objectbox/objectbox.dart';

/// Entidade de Quebra de Jejum
/// Registra cada recompensa de "dia livre" concedida ao usuÃ¡rio disciplinado
@Entity()
class DigitalDetoxFastingBreakEntity {
  @Id()
  int id = 0;

  String userId;

  /// Quando a quebra foi concedida (ganhou)
  DateTime earnedAt;

  /// Quando expira (null = nunca expira)
  DateTime? expiresAt;

  /// Quando foi usada (null = ainda nÃ£o usada)
  DateTime? usedAt;

  /// Se jÃ¡ foi usada
  bool isUsed = false;

  /// Quantos dias disciplinados para ganhar esta quebra
  int daysDisciplinedCount = 7;

  /// Identificador da semana (para referÃªncia)
  int weekNumber = 0;

  /// Ano de referÃªncia
  int year = 0;

  DigitalDetoxFastingBreakEntity({
    required this.userId,
    required this.earnedAt,
    this.expiresAt,
    this.daysDisciplinedCount = 7,
  }) : weekNumber = _getWeekNumber(earnedAt),
       year = earnedAt.year;

  /// Marca a quebra como usada
  void use() {
    isUsed = true;
    usedAt = DateTime.now();
  }

  /// Verifica se a quebra estÃ¡ disponÃ­vel (nÃ£o usada e nÃ£o expirada)
  bool get isAvailable {
    if (isUsed) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Verifica se estÃ¡ expirada
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Dias restantes atÃ© expirar (null se nÃ£o expira)
  int? get daysUntilExpiry {
    if (expiresAt == null) return null;
    if (isUsed) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  DigitalDetoxFastingBreakEntity copyWith({
    int? id,
    String? userId,
    DateTime? earnedAt,
    DateTime? expiresAt,
    DateTime? usedAt,
    bool? isUsed,
    int? daysDisciplinedCount,
    int? weekNumber,
    int? year,
  }) {
    final entity = DigitalDetoxFastingBreakEntity(
      userId: userId ?? this.userId,
      earnedAt: earnedAt ?? this.earnedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      daysDisciplinedCount: daysDisciplinedCount ?? this.daysDisciplinedCount,
    );
    entity.id = id ?? this.id;
    entity.usedAt = usedAt ?? this.usedAt;
    entity.isUsed = isUsed ?? this.isUsed;
    entity.weekNumber = weekNumber ?? this.weekNumber;
    entity.year = year ?? this.year;
    return entity;
  }

  static int _getWeekNumber(DateTime date) {
    final dayOfYear = int.parse("${date.difference(DateTime(date.year, 1, 1)).inDays}");
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
