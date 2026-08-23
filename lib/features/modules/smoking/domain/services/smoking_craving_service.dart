import 'dart:convert';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_craving_record.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço para gerenciar registros de crises de fissura / SOS e análises de gatilhos
class SmokingCravingService {
  final PreferencesService _prefs;

  SmokingCravingService(this._prefs);

  static const String _storageKey = 'smoking_craving_records_v1';

  /// Carrega todos os registros de fissura ordenados por data desc
  Future<List<SmokingCravingRecord>> getAllRecords() async {
    try {
      final jsonStr = await _prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      final records = list
          .map((e) => SmokingCravingRecord.fromJson(e as Map<String, dynamic>))
          .toList();

      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return records;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar registros de fissura de smoking', error: e);
      return [];
    }
  }

  /// Adiciona um novo registro de fissura/SOS
  Future<void> saveRecord(SmokingCravingRecord record) async {
    try {
      final all = await getAllRecords();
      final index = all.indexWhere((r) => r.id == record.id);
      if (index >= 0) {
        all[index] = record;
      } else {
        all.insert(0, record);
      }

      final jsonStr = jsonEncode(all.map((e) => e.toJson()).toList());
      await _prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar registro de fissura de smoking', error: e);
    }
  }

  /// Retorna registros dentro de uma janela de dias (ex: 7, 30 ou 0 para todos)
  Future<List<SmokingCravingRecord>> getRecordsInDays(int days) async {
    final all = await getAllRecords();
    if (days <= 0) return all;

    final cutoff = DateTime.now().subtract(Duration(days: days));
    return all.where((r) => r.timestamp.isAfter(cutoff)).toList();
  }

  /// Estatísticas dos gatilhos para análise
  Future<Map<String, dynamic>> getTriggerAnalytics({int days = 30}) async {
    final records = await getRecordsInDays(days);
    final total = records.length;
    if (total == 0) {
      return {
        'total': 0,
        'overcomeCount': 0,
        'overcomeRate': 0.0,
        'triggerRanking': <String, int>{},
        'hourlyDistribution': <int, int>{},
        'topTrigger': null,
        'peakHourInterval': null,
      };
    }

    int overcomeCount = 0;
    final Map<String, int> triggerCount = {};
    final Map<int, int> hourlyCount = {};

    for (final r in records) {
      if (r.outcome == 'overcome') {
        overcomeCount++;
      }

      // Contagem por gatilho
      triggerCount[r.trigger] = (triggerCount[r.trigger] ?? 0) + 1;

      // Contagem por hora do dia (0..23)
      final hour = r.timestamp.hour;
      hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
    }

    // Ordenar ranking de gatilhos
    final sortedTriggers = Map.fromEntries(
      triggerCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    // Identificar hora de pico
    int? peakHour;
    int maxHourCount = 0;
    hourlyCount.forEach((hour, count) {
      if (count > maxHourCount) {
        maxHourCount = count;
        peakHour = hour;
      }
    });

    String? peakHourInterval;
    if (peakHour != null) {
      final nextHour = (peakHour! + 1) % 24;
      peakHourInterval =
          '${peakHour!.toString().padLeft(2, '0')}h - ${nextHour.toString().padLeft(2, '0')}h';
    }

    return {
      'total': total,
      'overcomeCount': overcomeCount,
      'overcomeRate': total > 0 ? (overcomeCount / total) : 0.0,
      'triggerRanking': sortedTriggers,
      'hourlyDistribution': hourlyCount,
      'topTrigger': sortedTriggers.isNotEmpty ? sortedTriggers.keys.first : null,
      'peakHourInterval': peakHourInterval,
    };
  }
}

