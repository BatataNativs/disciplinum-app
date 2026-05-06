import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_fasting_break_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repository de Quebras de Jejum
/// Gerencia persistência de recompensas concedidas ao usuário
class DigitalDetoxFastingBreakRepository {
  static DigitalDetoxFastingBreakRepository? _instance;
  static DigitalDetoxFastingBreakRepository get instance => _instance ??= DigitalDetoxFastingBreakRepository._internal();

  DigitalDetoxFastingBreakRepository._internal();

  Box<DigitalDetoxFastingBreakEntity> get _box => ObjectBoxService.instance.store.box<DigitalDetoxFastingBreakEntity>();

  /// Concede uma nova quebra de jejum
  Future<DigitalDetoxFastingBreakEntity> awardFastingBreak({
    required String userId,
    required int daysDisciplined,
    int validityDays = 30,
  }) async {
    final now = DateTime.now();
    final expiresAt = validityDays > 0 ? now.add(Duration(days: validityDays)) : null;

    final fastingBreak = DigitalDetoxFastingBreakEntity(
      userId: userId,
      earnedAt: now,
      expiresAt: expiresAt,
      daysDisciplinedCount: daysDisciplined,
    );

    fastingBreak.id = _box.put(fastingBreak);
    return fastingBreak;
  }

  /// Busca todas as quebras do usuário
  Future<List<DigitalDetoxFastingBreakEntity>> getAllFastingBreaks(String userId) async {
    final query = _box.query(
      DigitalDetoxFastingBreakEntity_.userId.equals(userId),
    ).order(DigitalDetoxFastingBreakEntity_.earnedAt, flags: Order.descending)
     .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Busca quebras disponíveis (não usadas e não expiradas)
  Future<List<DigitalDetoxFastingBreakEntity>> getAvailableFastingBreaks(String userId) async {
    final now = DateTime.now();

    final query = _box.query(
      DigitalDetoxFastingBreakEntity_.userId.equals(userId)
        .and(DigitalDetoxFastingBreakEntity_.isUsed.equals(false))
        .and(
          DigitalDetoxFastingBreakEntity_.expiresAt.isNull()
            .or(DigitalDetoxFastingBreakEntity_.expiresAt.greaterThan(now.millisecondsSinceEpoch))
        ),
    ).order(DigitalDetoxFastingBreakEntity_.earnedAt)
     .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Conta quebras disponíveis
  Future<int> countAvailableFastingBreaks(String userId) async {
    final available = await getAvailableFastingBreaks(userId);
    return available.length;
  }

  /// Usa uma quebra de jejum
  Future<bool> useFastingBreak(String userId) async {
    final available = await getAvailableFastingBreaks(userId);
    if (available.isEmpty) return false;

    final fastingBreak = available.first;
    fastingBreak.use();
    _box.put(fastingBreak);
    return true;
  }

  /// Verifica se há uma quebra ativa hoje
  Future<bool> hasActiveFastingBreakToday(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final query = _box.query(
      DigitalDetoxFastingBreakEntity_.userId.equals(userId)
        .and(DigitalDetoxFastingBreakEntity_.isUsed.equals(true))
        .and(DigitalDetoxFastingBreakEntity_.usedAt.greaterOrEqual(today.millisecondsSinceEpoch)),
    ).build();
    final result = query.findFirst();
    query.close();
    return result != null;
  }

  /// Busca quebras usadas
  Future<List<DigitalDetoxFastingBreakEntity>> getUsedFastingBreaks(String userId) async {
    final query = _box.query(
      DigitalDetoxFastingBreakEntity_.userId.equals(userId)
        .and(DigitalDetoxFastingBreakEntity_.isUsed.equals(true)),
    ).order(DigitalDetoxFastingBreakEntity_.usedAt, flags: Order.descending)
     .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Busca quebras expiradas não usadas
  Future<List<DigitalDetoxFastingBreakEntity>> getExpiredFastingBreaks(String userId) async {
    final now = DateTime.now();

    final query = _box.query(
      DigitalDetoxFastingBreakEntity_.userId.equals(userId)
        .and(DigitalDetoxFastingBreakEntity_.isUsed.equals(false))
        .and(DigitalDetoxFastingBreakEntity_.expiresAt.lessThan(now.millisecondsSinceEpoch)),
    ).build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Limpa quebras expiradas antigas
  Future<int> cleanupExpiredFastingBreaks(String userId) async {
    final expired = await getExpiredFastingBreaks(userId);
    final ids = expired.map((e) => e.id).toList();
    if (ids.isNotEmpty) {
      _box.removeMany(ids);
    }
    return ids.length;
  }

  /// Busca a quebra mais antiga disponível
  Future<DigitalDetoxFastingBreakEntity?> getOldestAvailableFastingBreak(String userId) async {
    final available = await getAvailableFastingBreaks(userId);
    return available.isNotEmpty ? available.first : null;
  }

  /// Calcula dias até a próxima expiração
  Future<int?> getDaysUntilNextExpiry(String userId) async {
    final available = await getAvailableFastingBreaks(userId);
    if (available.isEmpty) return null;

    DateTime? earliestExpiry;
    for (final fb in available) {
      if (fb.expiresAt != null) {
        if (earliestExpiry == null || fb.expiresAt!.isBefore(earliestExpiry)) {
          earliestExpiry = fb.expiresAt;
        }
      }
    }

    if (earliestExpiry == null) return null;
    return earliestExpiry.difference(DateTime.now()).inDays;
  }
}
