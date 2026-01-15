import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/user_niche_app.dart';
import 'package:disciplinum/models/user_niche_time.dart';

class PreferencesService {
  static const String _appsKey = 'guest_user_niche_apps';
  static const String _timesKey = 'guest_user_niche_times';
  static const String _guestFlagKey = 'guest_mode_enabled';

  static Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();

  // ============================================================
  // ===================== GUEST MODE ============================
  // ============================================================

  Future<void> setGuestMode(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_guestFlagKey, value);
  }

  static Future<bool> isGuestMode() async {
    final prefs = await _prefs();
    return prefs.getBool(_guestFlagKey) ?? false;
  }

  // ============================================================
  // ========================  APPS  =============================
  // ============================================================

  static Future<void> addUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    final prefs = await _prefs();

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

      await prefs.setString(
        _appsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('❌ Erro ao salvar app local: $e');
    }
  }

  static Future<void> removeUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    final prefs = await _prefs();

    try {
      final current = await loadUserNicheApps(nicheId: nicheId);

      final updated = current.where((a) => a.appPackage != package).toList();

      await prefs.setString(
        _appsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('❌ Erro ao remover app local: $e');
    }
  }

  static Future<List<UserNicheApp>> loadUserNicheApps({
    required NicheId nicheId,
  }) async {
    final prefs = await _prefs();

    try {
      final jsonString = prefs.getString(_appsKey);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List;

      return list
          .map((e) => UserNicheApp.fromJson(e))
          .where((a) => a.nicheId == nicheId.id)
          .toList();
    } catch (e) {
      debugPrint('❌ Erro ao carregar apps locais: $e');
      return [];
    }
  }

  static Future<void> removeAllAppsForNiche({
    required NicheId nicheId,
  }) async {
    final prefs = await _prefs();

    try {
      final allJson = prefs.getString(_appsKey);
      if (allJson == null) return;

      final list = jsonDecode(allJson) as List;

      final filtered = list
          .map((e) => UserNicheApp.fromJson(e))
          .where((a) => a.nicheId != nicheId.id)
          .toList();

      await prefs.setString(
        _appsKey,
        jsonEncode(filtered.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('❌ Erro ao limpar apps locais: $e');
    }
  }

  // ============================================================
  // =======================  TIMES  ============================
  // ============================================================

  static Future<void> addUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
  }) async {
    final prefs = await _prefs();

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

      await prefs.setString(
        _timesKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('❌ Erro ao salvar horário local: $e');
    }
  }

  static Future<void> removeUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
  }) async {
    final prefs = await _prefs();

    try {
      final current = await loadUserNicheTimes(nicheId: nicheId);

      final updated = current
          .where((t) => !(t.hour == hour && t.minute == minute))
          .toList();

      await prefs.setString(
        _timesKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('❌ Erro ao remover horário local: $e');
    }
  }

  static Future<List<UserNicheTime>> loadUserNicheTimes({
    required int nicheId,
  }) async {
    final prefs = await _prefs();

    try {
      final jsonString = prefs.getString(_timesKey);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List;

      return list
          .map((e) => UserNicheTime.fromJson(e))
          .where((t) => t.nicheId == nicheId)
          .toList();
    } catch (e) {
      debugPrint('❌ Erro ao carregar horários locais: $e');
      return [];
    }
  }

  static Future<void> removeAllTimesForNiche({
    required int nicheId,
  }) async {
    final prefs = await _prefs();

    try {
      final jsonString = prefs.getString(_timesKey);
      if (jsonString == null) return;

      final list = jsonDecode(jsonString) as List;

      final filtered = list
          .map((e) => UserNicheTime.fromJson(e))
          .where((t) => t.nicheId != nicheId)
          .toList();

      await prefs.setString(
        _timesKey,
        jsonEncode(filtered.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('❌ Erro ao limpar horários locais: $e');
    }
  }

  // ============================================================
  // ================== EXPORT / CLEAR ===========================
  // ============================================================

  static Future<Map<String, dynamic>> exportAll() async {
    final prefs = await _prefs();

    try {
      final apps = prefs.getString(_appsKey);
      final times = prefs.getString(_timesKey);

      return {
        'apps': apps != null ? jsonDecode(apps) : [],
        'times': times != null ? jsonDecode(times) : [],
      };
    } catch (e) {
      debugPrint('❌ Erro ao exportar dados locais: $e');
      return {'apps': [], 'times': []};
    }
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs();
    await prefs.remove(_appsKey);
    await prefs.remove(_timesKey);
    await prefs.remove(_guestFlagKey);
  }
}
