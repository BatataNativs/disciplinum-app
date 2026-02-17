import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Status de uma refeição
enum MealStatus { done, missed, pending }

/// Registro de uma refeição individual
class MealRecord {
  final String time; // "HH:mm"
  final MealStatus status;

  const MealRecord({required this.time, required this.status});
}

/// Resumo de um dia
class DaySummary {
  final DateTime date;
  final int totalMeals;
  final int doneMeals;
  final int missedMeals;
  final bool isSuccessful; // true se <= 1 missed

  const DaySummary({
    required this.date,
    required this.totalMeals,
    required this.doneMeals,
    required this.missedMeals,
    required this.isSuccessful,
  });
}

class MealTrackingService {
  MealTrackingService._();
  static final MealTrackingService instance = MealTrackingService._();

  SupabaseClient get _supabase => Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Registra uma refeição como feita ou não feita (upsert)
  Future<void> recordMeal(String time, {required bool done}) async {
    if (_userId == null) return;

    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      await _supabase.from('user_meal_records').upsert(
        {
          'user_id': _userId,
          'date': dateStr,
          'time': time,
          'status': done ? 'done' : 'missed',
        },
        onConflict: 'user_id, date, time',
      );
      debugPrint(
          '🍽️ Refeição registrada: $time -> ${done ? "done" : "missed"}');
    } catch (e) {
      debugPrint('❌ Erro ao registrar refeição: $e');
    }
  }

  /// Busca os registros de refeições de hoje
  Future<List<MealRecord>> getTodayMeals(List<TimeOfDay> scheduledTimes) async {
    if (_userId == null) return [];

    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      final result = await _supabase
          .from('user_meal_records')
          .select()
          .eq('user_id', _userId!)
          .eq('date', dateStr);

      final Map<String, String> recorded = {};
      for (final row in result) {
        recorded[row['time'] as String] = row['status'] as String;
      }

      // Monta lista com todos os horários agendados
      return scheduledTimes.map((t) {
        final timeStr =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
        final status = recorded[timeStr];
        return MealRecord(
          time: timeStr,
          status: status == 'done'
              ? MealStatus.done
              : status == 'missed'
                  ? MealStatus.missed
                  : MealStatus.pending,
        );
      }).toList()
        ..sort((a, b) => a.time.compareTo(b.time));
    } catch (e) {
      debugPrint('❌ Erro ao buscar refeições de hoje: $e');
      return [];
    }
  }

  /// Busca resumo dos últimos N dias
  Future<List<DaySummary>> getHistory({int days = 7}) async {
    if (_userId == null) return [];

    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: days - 1));
    final startStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

    try {
      final result = await _supabase
          .from('user_meal_records')
          .select()
          .eq('user_id', _userId!)
          .gte('date', startStr)
          .order('date');

      // Agrupa por data
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final row in result) {
        final date = row['date'] as String;
        grouped.putIfAbsent(date, () => []).add(row);
      }

      final List<DaySummary> summaries = [];
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final records = grouped[dateStr] ?? [];

        if (records.isEmpty) continue;

        int doneCount = 0;
        int missedCount = 0;
        for (final r in records) {
          if (r['status'] == 'done') doneCount++;
          if (r['status'] == 'missed') missedCount++;
        }

        summaries.add(DaySummary(
          date: date,
          totalMeals: records.length,
          doneMeals: doneCount,
          missedMeals: missedCount,
          isSuccessful: missedCount <= 1, // Perdão: 1 falha permitida
        ));
      }

      return summaries;
    } catch (e) {
      debugPrint('❌ Erro ao buscar histórico: $e');
      return [];
    }
  }

  /// Calcula streak atual (dias consecutivos bem-sucedidos)
  Future<int> getCurrentStreak() async {
    final history = await getHistory(days: 30);
    if (history.isEmpty) return 0;

    // Percorre do mais recente para o mais antigo
    int streak = 0;
    final sortedDesc = history.reversed.toList();

    for (final day in sortedDesc) {
      if (day.isSuccessful) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
