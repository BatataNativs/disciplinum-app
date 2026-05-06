import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_stats_entity.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'dart:convert';

/// Repository de estatísticas do Jejum Digital
/// Gerencia persistência de estatísticas agregadas usando ObjectBox
class DigitalDetoxStatsRepository {
  static DigitalDetoxStatsRepository? _instance;
  static DigitalDetoxStatsRepository get instance => _instance ??= DigitalDetoxStatsRepository._internal();

  DigitalDetoxStatsRepository._internal();

  Box<DigitalDetoxStatsEntity> get _box => ObjectBoxService.instance.store.box<DigitalDetoxStatsEntity>();

  /// Busca ou cria estatísticas do dia
  Future<DigitalDetoxStatsEntity> getOrCreateTodayStats(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final query = _box.query(
      DigitalDetoxStatsEntity_.userId.equals(userId)
        .and(DigitalDetoxStatsEntity_.date.equals(startOfDay.millisecondsSinceEpoch)),
    ).build();
    var stats = query.findFirst();
    query.close();

    if (stats == null) {
      stats = DigitalDetoxStatsEntity(userId: userId, date: startOfDay);
      _box.put(stats);
    }

    return stats;
  }

  /// Atualiza estatísticas do dia
  Future<void> updateTodayStats(
    String userId, {
    int? totalScreenTimeMinutes,
    Map<String, int>? appBreakdown,
    int? openCount,
    int? longestSessionMinutes,
    bool? wasDisciplinedDay,
    bool? usedFastingBreak,
  }) async {
    final stats = await getOrCreateTodayStats(userId);

    if (totalScreenTimeMinutes != null) {
      stats.totalScreenTimeMinutes = totalScreenTimeMinutes;
    }
    if (appBreakdown != null) {
      stats.appBreakdownJson = jsonEncode(appBreakdown);
    }
    if (openCount != null) {
      stats.openCount = openCount;
    }
    if (longestSessionMinutes != null) {
      stats.longestSessionMinutes = longestSessionMinutes;
    }
    if (wasDisciplinedDay != null) {
      stats.wasDisciplinedDay = wasDisciplinedDay;
    }
    if (usedFastingBreak != null) {
      stats.usedFastingBreak = usedFastingBreak;
    }

    _box.put(stats);
  }

  /// Busca estatísticas de uma data específica
  Future<DigitalDetoxStatsEntity?> getStatsForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final query = _box.query(
      DigitalDetoxStatsEntity_.userId.equals(userId)
        .and(DigitalDetoxStatsEntity_.date.equals(startOfDay.millisecondsSinceEpoch)),
    ).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  /// Busca estatísticas da semana
  Future<List<DigitalDetoxStatsEntity>> getStatsForWeek(String userId, int weekNumber, int year) async {
    final query = _box.query(
      DigitalDetoxStatsEntity_.userId.equals(userId)
        .and(DigitalDetoxStatsEntity_.weekNumber.equals(weekNumber))
        .and(DigitalDetoxStatsEntity_.year.equals(year)),
    ).order(DigitalDetoxStatsEntity_.date)
     .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Busca estatísticas do mês
  Future<List<DigitalDetoxStatsEntity>> getStatsForMonth(String userId, int month, int year) async {
    final query = _box.query(
      DigitalDetoxStatsEntity_.userId.equals(userId)
        .and(DigitalDetoxStatsEntity_.monthNumber.equals(month))
        .and(DigitalDetoxStatsEntity_.year.equals(year)),
    ).order(DigitalDetoxStatsEntity_.date)
     .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Busca todas as estatísticas
  Future<List<DigitalDetoxStatsEntity>> getAllStats(String userId) async {
    final query = _box.query(
      DigitalDetoxStatsEntity_.userId.equals(userId),
    ).order(DigitalDetoxStatsEntity_.date, flags: Order.descending)
     .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Calcula média de uso diário
  Future<double> getAverageDailyUsage(String userId) async {
    final stats = await getAllStats(userId);
    if (stats.isEmpty) return 0;

    final total = stats.fold(0, (sum, s) => sum + s.totalScreenTimeMinutes);
    return total / stats.length;
  }

  /// Busca apps mais usados (top N)
  Future<List<MapEntry<String, int>>> getMostUsedApps(String userId, {int limit = 5}) async {
    final stats = await getAllStats(userId);
    final Map<String, int> appTotals = {};

    for (final stat in stats) {
      final breakdown = jsonDecode(stat.appBreakdownJson) as Map<String, dynamic>?;
      if (breakdown != null) {
        for (final entry in breakdown.entries) {
          appTotals[entry.key] = (appTotals[entry.key] ?? 0) + (entry.value as int);
        }
      }
    }

    final sorted = appTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).toList();
  }

  /// Conta dias disciplinados consecutivos (streak)
  Future<int> calculateDisciplinedStreak(String userId) async {
    final stats = await getAllStats(userId);
    if (stats.isEmpty) return 0;

    // Ordenar do mais recente para o mais antigo
    stats.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final stat in stats) {
      if (stat.wasDisciplinedDay) {
        // Verificar se é dia consecutivo
        final expectedDate = today.subtract(Duration(days: streak));
        if (stat.date.year == expectedDate.year &&
            stat.date.month == expectedDate.month &&
            stat.date.day == expectedDate.day) {
          streak++;
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return streak;
  }
}
