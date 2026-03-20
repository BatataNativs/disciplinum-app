import 'dart:convert';
import 'package:disciplinum/core/database/entities/app_preference.dart';
import 'package:isar/isar.dart';

/// Repositório para gerenciar preferências do app usando Isar
/// Substituto moderno para o SharedPreferences
class IsarPreferencesRepository {
  final Isar _isar;

  IsarPreferencesRepository(this._isar);

  IsarCollection<AppPreference> get _collection => _isar.appPreferences;

  Future<void> setString(String key, String value) async {
    await _isar.writeTxn(() async {
      final existing = await _collection.filter().keyEqualTo(key).findFirst();
      if (existing != null) {
        existing.value = value;
        await _collection.put(existing);
      } else {
        await _collection.put(AppPreference(key: key, value: value));
      }
    });
  }

  Future<String?> getString(String key) async {
    final pref = await _collection.filter().keyEqualTo(key).findFirst();
    return pref?.value;
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
    await _isar.writeTxn(() async {
      await _collection.filter().keyEqualTo(key).deleteFirst();
    });
  }

  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _collection.clear();
    });
  }
}
