import 'dart:convert';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/user_niche_app.dart';
import 'package:disciplinum/shared/models/user_niche_time.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';

class PreferencesService {
  final IsarPreferencesRepository _prefsRepo;

  PreferencesService(this._prefsRepo);

  static const String _appsKey = 'guest_user_niche_apps';
  static const String _timesKey = 'guest_user_niche_times';
  static const String _smokingKey = 'guest_smoking_settings';
  static const String _guestFlagKey = 'guest_mode_enabled';

  // ============================================================
  // ===================== GUEST MODE ============================

  Future<void> clearSmokingSettings() async {
    try {
      await _prefsRepo.deleteByKey(_smokingKey);
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar settings do smoking: $e');
    }
  }
  // ============================================================

  Future<void> setGuestMode(bool value) async {
    await _prefsRepo.setBool(_guestFlagKey, value);
  }

  Future<bool> isGuestMode() async {
    return await _prefsRepo.getBool(_guestFlagKey) ?? false;
  }

  // ============================================================
  // ========================  APPS  =============================
  // ============================================================

  Future<void> addUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    try {
      final current = await loadUserNicheApps(nicheId: nicheId);
      if (current.any((a) => a.appPackage == package)) return;

      final updated = [
        ...current,
        UserNicheApp(
          userId: 'guest',
          nicheId: nicheId.id,
          appPackage: package,
        ),
      ];

      await _prefsRepo.setString(
        _appsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar app local', error: e);
    }
  }

  Future<void> removeUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    try {
      final current = await loadUserNicheApps(nicheId: nicheId);

      final updated = current.where((a) => a.appPackage != package).toList();

      await _prefsRepo.setString(
        _appsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao remover app local', error: e);
    }
  }

  Future<List<UserNicheApp>> loadUserNicheApps({
    required NicheId nicheId,
  }) async {
    try {
      final jsonString = await _prefsRepo.getString(_appsKey);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List;

      return list
          .map((e) => UserNicheApp.fromJson(e))
          .where((a) => a.nicheId == nicheId.id)
          .toList();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar apps locais', error: e);
      return [];
    }
  }

  Future<void> removeAllAppsForNiche({
    required NicheId nicheId,
  }) async {
    try {
      final allJson = await _prefsRepo.getString(_appsKey);
      if (allJson == null) return;

      final list = jsonDecode(allJson) as List;

      final filtered = list
          .map((e) => UserNicheApp.fromJson(e))
          .where((a) => a.nicheId != nicheId.id)
          .toList();

      await _prefsRepo.setString(
        _appsKey,
        jsonEncode(filtered.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar apps locais', error: e);
    }
  }

  // ============================================================
  // =======================  TIMES  ============================
  // ============================================================

  Future<void> addUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
  }) async {
    try {
      final current = await loadUserNicheTimes(nicheId: nicheId);

      if (current.any((t) => t.hour == hour && t.minute == minute)) return;

      final updated = [
        ...current,
        UserNicheTime(
          userId: 'guest',
          nicheId: nicheId,
          hour: hour,
          minute: minute,
        ),
      ];

      await _prefsRepo.setString(
        _timesKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar horário local', error: e);
    }
  }

  Future<void> removeUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
  }) async {
    try {
      final current = await loadUserNicheTimes(nicheId: nicheId);

      final updated = current
          .where((t) => !(t.hour == hour && t.minute == minute))
          .toList();

      await _prefsRepo.setString(
        _timesKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao remover horário local', error: e);
    }
  }

  Future<List<UserNicheTime>> loadUserNicheTimes({
    required int nicheId,
  }) async {
    try {
      final jsonString = await _prefsRepo.getString(_timesKey);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List;

      return list
          .map((e) => UserNicheTime.fromJson(e))
          .where((t) => t.nicheId == nicheId)
          .toList();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar horários locais', error: e);
      return [];
    }
  }

  Future<void> removeAllTimesForNiche({
    required int nicheId,
  }) async {
    try {
      final jsonString = await _prefsRepo.getString(_timesKey);
      if (jsonString == null) return;

      final list = jsonDecode(jsonString) as List;

      final filtered = list
          .map((e) => UserNicheTime.fromJson(e))
          .where((t) => t.nicheId != nicheId)
          .toList();

      await _prefsRepo.setString(
        _timesKey,
        jsonEncode(filtered.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar horários locais', error: e);
    }
  }

  // ============================================================
  // ======================  SMOKING  ===========================
  // ============================================================

  Future<void> saveSmokingSettings(SmokingSettingsModel settings) async {
    try {
      await _prefsRepo.setString(_smokingKey, jsonEncode(settings.toJson()));
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configurações de cigarro locais', error: e);
    }
  }

  Future<SmokingSettingsModel?> getSmokingSettings() async {
    try {
      final jsonString = await _prefsRepo.getString(_smokingKey);
      if (jsonString == null) return null;
      return SmokingSettingsModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configurações de cigarro locais', error: e);
      return null;
    }
  }

  Future<void> removeSmokingSettings() async {
    await _prefsRepo.remove(_smokingKey);
  }

  // ============================================================
  // ================== EXPORT / CLEAR ===========================
  // ============================================================

  Future<Map<String, dynamic>> exportAll() async {
    try {
      final apps = await _prefsRepo.getString(_appsKey);
      final times = await _prefsRepo.getString(_timesKey);
      final smoking = await _prefsRepo.getString(_smokingKey);

      return {
        'apps': apps != null ? jsonDecode(apps) : [],
        'times': times != null ? jsonDecode(times) : [],
        'smoking': smoking != null ? jsonDecode(smoking) : null,
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao exportar dados locais', error: e);
      return {'apps': [], 'times': [], 'smoking': null};
    }
  }

  Future<void> clearAll() async {
    await _prefsRepo.remove(_appsKey);
    await _prefsRepo.remove(_timesKey);
    await _prefsRepo.remove(_smokingKey);
    await _prefsRepo.remove(_guestFlagKey);
  }
}
