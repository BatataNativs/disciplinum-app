import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';
import 'package:disciplinum/misc/system_stuff/preferences_service.dart';

class SmokingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Carregar configurações do usuário
  Future<SmokingSettingsModel?> getSettings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return await PreferencesService.getSmokingSettings();
      }

      final response = await _supabase
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', 'smoking')
          .maybeSingle(); // Retorna null se não achar nada

      if (response == null) return null;

      return SmokingSettingsModel.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao carregar settings: $e');
      return null;
    }
  }

  // Salvar ou Atualizar configurações
  Future<void> saveSettings(SmokingSettingsModel settings) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      await PreferencesService.saveSmokingSettings(settings);
      return;
    }

    // Prepara o JSON para o banco
    final data = {
      'user_id': userId,
      'module_id': 'smoking',
      'smoking_pack_price': settings.packPrice,
      'smoking_packs_per_day': settings.packsPerDay,
      'smoking_quit_date': settings.quitDate.toUtc().toIso8601String(),
      'smoking_currency': settings.currency,
      'last_pack_price': settings.lastPackPrice,
      'last_packs_per_day': settings.lastPacksPerDay,
      'last_quit_date': settings.lastQuitDate?.toIso8601String(),
      'last_currency': settings.lastCurrency,
      'last_saved_total': settings.lastSavedTotal,
      'last_end_date': settings.lastEndDate?.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    // Upsert com tratamento de conflito
    await _supabase.from('user_module_settings').upsert(
          data,
          onConflict: 'user_id, module_id',
        );
  }

  // Novo método para arquivar a tentativa atual e resetar
  Future<void> archiveAndReset() async {
    final current = await getSettings();
    if (current == null) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Move os dados atuais para os campos de "last"
    final archivedData = {
      'user_id': userId,
      'module_id': 'smoking',
      // Novos valores de histórico baseados no que era o "atual"
      'last_pack_price': current.packPrice,
      'last_packs_per_day': current.packsPerDay,
      'last_quit_date': current.quitDate.toIso8601String(),
      'last_currency': current.currency,
      'last_saved_total': current.moneySavedTotal,
      'last_end_date': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    await _supabase.from('user_module_settings').upsert(
          archivedData,
          onConflict: 'user_id, module_id',
        );
  }

  // Deletar configurações (Resetar módulo para estado inicial)
  Future<void> deleteSettings() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('user_module_settings')
          .delete()
          .eq('user_id', userId)
          .eq('module_id', 'smoking');
    } catch (e) {
      debugPrint('Erro ao deletar settings: $e');
      throw Exception('Falha ao resetar dados');
    }
  }
}
