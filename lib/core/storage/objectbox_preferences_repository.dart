import 'dart:convert';

import 'package:disciplinum/core/database/entities/app_preference.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório para gerenciar preferências do app usando ObjectBox
/// Substituto moderno para o SharedPreferences e IsarPreferencesRepository
class ObjectBoxPreferencesRepository {
  final Store _store;

  ObjectBoxPreferencesRepository(this._store);

  Box<AppPreference> get _box => _store.box<AppPreference>();

  Future<void> setString(String key, String value) async {
    final existing = _box.query(AppPreference_.key.equals(key)).build().findFirst();
    if (existing != null) {
      existing.value = value;
      _box.put(existing);
    } else {
      _box.put(AppPreference(key: key, value: value));
    }
  }

  Future<String?> getString(String key) async {
    final pref = _box.query(AppPreference_.key.equals(key)).build().findFirst();
    return pref?.value;
  }

  Future<void> deleteByKey(String key) async {
    final existing = _box.query(AppPreference_.key.equals(key)).build().findFirst();
    if (existing != null) {
      _box.remove(existing.id);
    }
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await setString(key, jsonEncode(value));
  }

  Future<List<String>?> getStringList(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    try {
      return (jsonDecode(value) as List).cast<String>();
    } catch (e) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    final existing = _box.query(AppPreference_.key.equals(key)).build().findFirst();
    if (existing != null) {
      _box.remove(existing.id);
    }
  }

  Future<void> clear() async {
    _box.removeAll();
  }

  Future<Set<String>> getKeys() async {
    final preferences = _box.getAll();
    return preferences.map((p) => p.key).toSet();
  }
}
