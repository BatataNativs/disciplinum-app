import 'dart:convert';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_diary_entry.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço responsável por persistir o diário pessoal de ansiedade / pensamentos de forma 100% local e privada
class SmokingDiaryService {
  final PreferencesService _prefs;

  SmokingDiaryService(this._prefs);

  static const String _storageKey = 'smoking_diary_entries_v1';

  /// Carrega todas as entradas ordenadas por data desc
  Future<List<SmokingDiaryEntry>> getAllEntries() async {
    try {
      final jsonStr = await _prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      final entries = list
          .map((e) => SmokingDiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar entradas do diário de smoking', error: e);
      return [];
    }
  }

  /// Busca uma entrada específica pela chave de data (yyyy-MM-dd)
  Future<SmokingDiaryEntry?> getEntryForDate(String dateKey) async {
    final all = await getAllEntries();
    try {
      return all.firstWhere((e) => e.dateKey == dateKey);
    } catch (_) {
      return null;
    }
  }

  /// Retorna o conjunto de todas as chaves de data (yyyy-MM-dd) que possuem anotações
  Future<Set<String>> getDatesWithEntries() async {
    final all = await getAllEntries();
    return all.where((e) => e.text.trim().isNotEmpty).map((e) => e.dateKey).toSet();
  }

  /// Salva ou atualiza a entrada de um dia específico
  Future<void> saveEntry({
    required String dateKey,
    required String text,
    String? mood,
  }) async {
    try {
      final all = await getAllEntries();
      final index = all.indexWhere((e) => e.dateKey == dateKey);

      final now = DateTime.now();
      if (index >= 0) {
        if (text.trim().isEmpty) {
          // Remove se estiver em branco
          all.removeAt(index);
        } else {
          all[index] = all[index].copyWith(
            text: text,
            updatedAt: now,
            mood: mood ?? all[index].mood,
          );
        }
      } else {
        if (text.trim().isNotEmpty) {
          all.add(
            SmokingDiaryEntry(
              id: 'diary_${now.millisecondsSinceEpoch}',
              dateKey: dateKey,
              text: text,
              createdAt: now,
              mood: mood,
            ),
          );
        }
      }

      final jsonStr = jsonEncode(all.map((e) => e.toJson()).toList());
      await _prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar entrada no diário de smoking', error: e);
    }
  }

  /// Exclui uma entrada
  Future<void> deleteEntry(String dateKey) async {
    try {
      final all = await getAllEntries();
      all.removeWhere((e) => e.dateKey == dateKey);
      final jsonStr = jsonEncode(all.map((e) => e.toJson()).toList());
      await _prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      LoggerService.instance.e('Erro ao excluir entrada do diário de smoking', error: e);
    }
  }
}

