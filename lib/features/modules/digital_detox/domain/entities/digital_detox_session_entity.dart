import 'package:objectbox/objectbox.dart';

/// Entidade de sessÃ£o de uso de app
/// Registra cada perÃ­odo em que o usuÃ¡rio usou um app monitorado
@Entity()
class DigitalDetoxSessionEntity {
  @Id()
  int id = 0;

  String userId;
  String appPackageName;
  String appName;

  DateTime sessionStart;
  DateTime? sessionEnd;

  /// DuraÃ§Ã£o em minutos (calculada ao finalizar)
  int durationMinutes = 0;

  /// Data apenas (para queries por dia) - sem hora
  DateTime date;

  /// Se a sessÃ£o terminou por bloqueio do AppLock
  bool wasBlocked = false;

  /// Tipo de sessÃ£o: livre ou controlada (FASE 6C)
  String sessionType = "free"; // "free" | "controlled"

  /// Se sessÃ£o controlada foi completada (usou todo o tempo)
  bool wasSessionCompleted = false;

  DigitalDetoxSessionEntity({
    required this.userId,
    required this.appPackageName,
    required this.appName,
    required this.sessionStart,
    required this.date,
  });

  /// Finaliza a sessÃ£o e calcula duraÃ§Ã£o
  void endSession({bool blocked = false, bool completed = false}) {
    sessionEnd = DateTime.now();
    wasBlocked = blocked;
    wasSessionCompleted = completed;
    durationMinutes = sessionEnd!.difference(sessionStart).inMinutes;
  }

  DigitalDetoxSessionEntity copyWith({
    int? id,
    String? userId,
    String? appPackageName,
    String? appName,
    DateTime? sessionStart,
    DateTime? sessionEnd,
    int? durationMinutes,
    DateTime? date,
    bool? wasBlocked,
    String? sessionType,
    bool? wasSessionCompleted,
  }) {
    final entity = DigitalDetoxSessionEntity(
      userId: userId ?? this.userId,
      appPackageName: appPackageName ?? this.appPackageName,
      appName: appName ?? this.appName,
      sessionStart: sessionStart ?? this.sessionStart,
      date: date ?? this.date,
    );
    entity.id = id ?? this.id;
    entity.sessionEnd = sessionEnd ?? this.sessionEnd;
    entity.durationMinutes = durationMinutes ?? this.durationMinutes;
    entity.wasBlocked = wasBlocked ?? this.wasBlocked;
    entity.sessionType = sessionType ?? this.sessionType;
    entity.wasSessionCompleted = wasSessionCompleted ?? this.wasSessionCompleted;
    return entity;
  }

  /// Verifica se a sessÃ£o estÃ¡ ativa (nÃ£o finalizada)
  bool get isActive => sessionEnd == null;
}
