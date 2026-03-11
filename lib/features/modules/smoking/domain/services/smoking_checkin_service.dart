import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço responsável por registrar e carregar os check-ins diários
/// do módulo Parar de Fumar (resposta "Sim" na notificação diária).
class SmokingCheckinService {
  static const String _prefsKey = 'smoking_checkin_dates';
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton
  static final SmokingCheckinService _instance =
      SmokingCheckinService._internal();
  factory SmokingCheckinService() => _instance;
  SmokingCheckinService._internal();

  /// Formata DateTime como string de data (yyyy-MM-dd)
  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Registra check-in do dia atual (ou de [date] se fornecida).
  /// Idempotente — não duplica se chamado mais de uma vez no mesmo dia.
  Future<void> recordCheckin({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final dateStr = _dateKey(target);

    // 1. Persiste localmente
    await _saveLocalCheckin(dateStr);

    // 2. Persiste no Supabase
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('smoking_daily_checkins').upsert(
        {
          'user_id': userId,
          'check_date': dateStr,
        },
        onConflict: 'user_id, check_date',
        ignoreDuplicates: true,
      );
      debugPrint('✅ Check-in registrado para $dateStr');
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar check-in no Supabase: $e');
      // Não lança — o local já foi salvo como fallback
    }
  }

  /// Carrega todas as datas de check-in.
  /// Tenta Supabase primeiro, com fallback local.
  Future<List<DateTime>> loadCheckins() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final result = await _supabase
            .from('smoking_daily_checkins')
            .select('check_date')
            .eq('user_id', userId)
            .order('check_date', ascending: true);

        final dates = (result as List)
            .map((row) => DateTime.parse(row['check_date'] as String))
            .toList();

        // Atualiza cache local com dados da nuvem
        await _syncLocalFromCloud(dates);
        return dates;
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar check-ins do Supabase: $e');
    }

    // Fallback: dados locais
    return _loadLocalCheckins();
  }

  /// Apaga todos os check-ins do usuário (usado no reset de módulo).
  Future<void> clearAllCheckins() async {
    // Limpa local
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);

    // Limpa Supabase
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      await _supabase
          .from('smoking_daily_checkins')
          .delete()
          .eq('user_id', userId);
      debugPrint('🗑️ Todos os check-ins apagados.');
    } catch (e) {
      debugPrint('⚠️ Erro ao apagar check-ins no Supabase: $e');
    }
  }

  // --- Helpers privados ---

  Future<void> _saveLocalCheckin(String dateStr) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_prefsKey) ?? [];
    if (!existing.contains(dateStr)) {
      existing.add(dateStr);
      await prefs.setStringList(_prefsKey, existing);
    }
  }

  Future<List<DateTime>> _loadLocalCheckins() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? [];
    return stored.map((s) => DateTime.parse(s)).toList();
  }

  Future<void> _syncLocalFromCloud(List<DateTime> cloudDates) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStrings = cloudDates.map(_dateKey).toList();
    await prefs.setStringList(_prefsKey, dateStrings);
  }
}
