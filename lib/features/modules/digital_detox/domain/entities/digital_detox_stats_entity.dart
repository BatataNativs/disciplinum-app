import 'package:objectbox/objectbox.dart';

/// Entidade de estatísticas agregadas diárias
/// Armazena resumo do uso de apps por dia para análises e gráficos
@Entity()
class DigitalDetoxStatsEntity {
  @Id()
  int id = 0;

  String userId;

  /// Data (sem hora) - indexada para queries rápidas
  @Index()
  DateTime date;

  /// Tempo total de tela no dia (em minutos)
  int totalScreenTimeMinutes = 0;

  /// Breakdown por app: {"com.instagram.android": 45, "com.tiktok": 30}
  String appBreakdownJson = "{}";

  /// Quantas vezes abriu apps monitorados
  int openCount = 0;

  /// Sessão mais longa do dia (em minutos)
  int longestSessionMinutes = 0;

  /// Número da semana (1-53) para queries semanais
  int weekNumber = 0;

  /// Número do mês (1-12) para queries mensais
  int monthNumber = 0;

  /// Ano
  int year = 0;

  /// Se foi um dia "disciplinado" (para streak de Quebra de Jejum)
  bool wasDisciplinedDay = false;

  /// Se usou Quebra de Jejum neste dia
  bool usedFastingBreak = false;

  DigitalDetoxStatsEntity({
    required this.userId,
    required this.date,
  }) : weekNumber = _getWeekNumber(date),
       monthNumber = date.month,
       year = date.year;

  DigitalDetoxStatsEntity copyWith({
    int? id,
    String? userId,
    DateTime? date,
    int? totalScreenTimeMinutes,
    String? appBreakdownJson,
    int? openCount,
    int? longestSessionMinutes,
    int? weekNumber,
    int? monthNumber,
    int? year,
    bool? wasDisciplinedDay,
    bool? usedFastingBreak,
  }) {
    final entity = DigitalDetoxStatsEntity(
      userId: userId ?? this.userId,
      date: date ?? this.date,
    );
    entity.id = id ?? this.id;
    entity.totalScreenTimeMinutes = totalScreenTimeMinutes ?? this.totalScreenTimeMinutes;
    entity.appBreakdownJson = appBreakdownJson ?? this.appBreakdownJson;
    entity.openCount = openCount ?? this.openCount;
    entity.longestSessionMinutes = longestSessionMinutes ?? this.longestSessionMinutes;
    entity.weekNumber = weekNumber ?? this.weekNumber;
    entity.monthNumber = monthNumber ?? this.monthNumber;
    entity.year = year ?? this.year;
    entity.wasDisciplinedDay = wasDisciplinedDay ?? this.wasDisciplinedDay;
    entity.usedFastingBreak = usedFastingBreak ?? this.usedFastingBreak;
    return entity;
  }

  static int _getWeekNumber(DateTime date) {
    final dayOfYear = int.parse("${date.difference(DateTime(date.year, 1, 1)).inDays}");
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
