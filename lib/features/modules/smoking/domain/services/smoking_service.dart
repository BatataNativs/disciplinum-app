import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

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
      LoggerService.instance.e('Erro ao carregar settings', error: e);
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
      'smoking_quit_date': settings.quitDate?.toIso8601String(),
      'smoking_currency': settings.currency,
      // Preserva o histórico ao salvar novas configurações
      'last_pack_price': settings.lastPackPrice,
      'last_packs_per_day': settings.lastPacksPerDay,
      'last_quit_date': settings.lastQuitDate?.toIso8601String(),
      'last_currency': settings.lastCurrency,
      'last_saved_total': settings.lastSavedTotal,
      'last_end_date': settings.lastEndDate?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('user_module_settings').upsert(
          data,
          onConflict: 'user_id, module_id',
        );
  }

  // --- CORREÇÃO IMPORTANTE AQUI ---
  // Arquiva a tentativa atual E reseta os dados vigentes para um estado "limpo"
  Future<void> archiveAndReset() async {
    final current = await getSettings();
    if (current == null) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Data de "agora" para ser o novo início (zerado)
    final now = DateTime.now();

    final archivedData = {
      'user_id': userId,
      'module_id': 'smoking',

      // 1. Move dados para o histórico (LAST)
      'last_pack_price': current.packPrice,
      'last_packs_per_day': current.packsPerDay,
      'last_quit_date': current.quitDate?.toIso8601String(),
      'last_currency': current.currency,
      'last_saved_total':
          current.moneySavedTotal, // Calcula o total economizado até agora
      'last_end_date': now.toIso8601String(), // Data do reset

      // 2. RESETA os dados atuais para o padrão (para não puxar velharia na tela)
      // Mantemos preço e maços para facilitar nova tentativa, mas a data vira "agora"
      // Se quiser forçar o usuário a redigitar tudo, pode zerar preço/maços também.
      'smoking_quit_date':
          now.toIso8601String(), // Reseta o contador de dias para 0

      // Opcional: Se quiser zerar inputs, descomente:
      // 'smoking_pack_price': 0.0,
      // 'smoking_packs_per_day': 0,

      'updated_at': now.toIso8601String(),
    };

    await _supabase.from('user_module_settings').upsert(
          archivedData,
          onConflict: 'user_id, module_id',
        );
  }

  // Deletar configurações (Resetar módulo para estado inicial absoluto)
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
      LoggerService.instance.e('Erro ao deletar settings', error: e);
      throw Exception('Falha ao resetar dados');
    }
  }
}
