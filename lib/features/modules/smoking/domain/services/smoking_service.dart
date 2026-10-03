import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class SmokingService {
  final PreferencesService _prefs;

  SmokingService(this._prefs);

  // Carregar configurações do usuário
  Future<SmokingSettingsModel?> getSettings() async {
    try {
      return await _prefs.getSmokingSettings();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar settings', error: e);
      return null;
    }
  }

  // Salvar ou Atualizar configurações
  Future<void> saveSettings(SmokingSettingsModel settings) async {
    await _prefs.saveSmokingSettings(settings);
  }

  // Arquiva a tentativa atual E reseta os dados vigentes para um estado "limpo"
  Future<void> archiveAndReset() async {
    final current = await getSettings();
    if (current == null) return;

    final now = DateTime.now();

    final archivedSettings = current.copyWith(
      lastPackPrice: current.packPrice,
      lastPacksPerDay: current.packsPerDay,
      lastQuitDate: current.quitDate,
      lastCurrency: current.currency,
      lastSavedTotal: current.moneySavedTotal.toDouble(),
      lastEndDate: now,
      quitDate: now,
    );

    await _prefs.saveSmokingSettings(archivedSettings);
  }

  // Deletar configurações (Resetar módulo para estado inicial absoluto)
  Future<void> deleteSettings() async {
    try {
      await _prefs.removeSmokingSettings();
    } catch (e) {
      LoggerService.instance.e('Erro ao deletar settings', error: e);
      throw Exception('Falha ao resetar dados');
    }
  }

  // Deletar configurações (Resetar módulo para estado inicial absoluto)
  Future<void> resetAllData() async {
    try {
      await _prefs.removeSmokingSettings();
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar dados do smoking: $e');
      throw Exception('Falha ao resetar dados');
    }
  }
}

