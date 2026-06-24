import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_session_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repository de sessÃµes de uso do Jejum Digital
/// Gerencia persistÃªncia de sessÃµes usando ObjectBox
class DigitalDetoxSessionRepository {
  static DigitalDetoxSessionRepository? _instance;
  static DigitalDetoxSessionRepository get instance => _instance ??= DigitalDetoxSessionRepository._internal();

  DigitalDetoxSessionRepository._internal();

  Box<DigitalDetoxSessionEntity> get _box => ObjectBoxService.instance.store.box<DigitalDetoxSessionEntity>();

  /// Inicia uma nova sessÃ£o
  Future<DigitalDetoxSessionEntity> startSession({
    required String userId,
    required String appPackage,
    required String appName,
    String sessionType = "free",
  }) async {
    final now = DateTime.now();
    final session = DigitalDetoxSessionEntity(
      userId: userId,
      appPackageName: appPackage,
      appName: appName,
      sessionStart: now,
      date: DateTime(now.year, now.month, now.day),
    );
    session.sessionType = sessionType;
    session.id = _box.put(session);
    return session;
  }

  /// Finaliza uma sessÃ£o
  Future<void> endSession(int sessionId, {bool blocked = false, bool completed = false}) async {
    final session = _box.get(sessionId);
    if (session != null) {
      session.endSession(blocked: blocked, completed: completed);
      _box.put(session);
    }
  }

  /// Busca sessÃ£o ativa (nÃ£o finalizada)
  Future<DigitalDetoxSessionEntity?> getActiveSession(String userId) async {
    final query = _box.query(
      DigitalDetoxSessionEntity_.userId.equals(userId)
        .and(DigitalDetoxSessionEntity_.sessionEnd.isNull()),
    ).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  /// Busca sessÃµes de hoje
  Future<List<DigitalDetoxSessionEntity>> getTodaySessions(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final query = _box.query(
      DigitalDetoxSessionEntity_.userId.equals(userId)
        .and(DigitalDetoxSessionEntity_.date.equals(startOfDay.millisecondsSinceEpoch)),
    ).order(DigitalDetoxSessionEntity_.sessionStart, flags: Order.descending)
     .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Calcula tempo total usado hoje (em minutos)
  Future<int> getTodayTotalMinutes(String userId) async {
    final sessions = await getTodaySessions(userId);
    return sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Calcula tempo usado por app hoje
  Future<Map<String, int>> getTodayAppUsage(String userId) async {
    final sessions = await getTodaySessions(userId);
    final Map<String, int> appUsage = {};

    for (final session in sessions) {
      appUsage[session.appPackageName] = (appUsage[session.appPackageName] ?? 0) + session.durationMinutes;
    }

    return appUsage;
  }

  /// Conta sessÃµes de hoje
  Future<int> getTodaySessionCount(String userId) async {
    final sessions = await getTodaySessions(userId);
    return sessions.length;
  }

  /// Conta sessÃµes controladas de hoje
  Future<int> getTodayControlledSessionCount(String userId) async {
    final sessions = await getTodaySessions(userId);
    return sessions.where((s) => s.sessionType == "controlled" && s.wasSessionCompleted).length;
  }

  /// Busca Ãºltima sessÃ£o
  Future<DigitalDetoxSessionEntity?> getLastSession(String userId) async {
    final query = _box.query(
      DigitalDetoxSessionEntity_.userId.equals(userId),
    ).order(DigitalDetoxSessionEntity_.sessionStart, flags: Order.descending)
     .build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  /// Verifica se estÃ¡ em cooldown (Ãºltima sessÃ£o controlada terminou hÃ¡ menos de X horas)
  Future<bool> isInCooldown(String userId, int cooldownHours) async {
    final lastSession = await getLastSession(userId);
    if (lastSession == null) return false;
    if (lastSession.sessionType != "controlled") return false;

    final now = DateTime.now();
    final sessionEnd = lastSession.sessionEnd;
    if (sessionEnd == null) return false;

    final hoursSince = now.difference(sessionEnd).inHours;
    return hoursSince < cooldownHours;
  }

  /// Minutos restantes de cooldown
  Future<int> getCooldownRemainingMinutes(String userId, int cooldownHours) async {
    final lastSession = await getLastSession(userId);
    if (lastSession == null) return 0;
    if (lastSession.sessionType != "controlled") return 0;

    final sessionEnd = lastSession.sessionEnd;
    if (sessionEnd == null) return 0;

    final nextSessionTime = sessionEnd.add(Duration(hours: cooldownHours));
    final now = DateTime.now();

    if (now.isAfter(nextSessionTime)) return 0;
    return nextSessionTime.difference(now).inMinutes;
  }
}
