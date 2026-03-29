import 'dart:convert';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';
import 'package:disciplinum/core/database/isar_service.dart';

/// Camada de abstração para storage local
/// Facilita testes e migrações futuras
abstract class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageServiceImpl();
  
  static Future<void> init() async {
    _instance = LocalStorageServiceImpl();
    await (_instance as LocalStorageServiceImpl)._init();
  }

  // Métodos básicos
  Future<void> save(String key, dynamic value);
  Future<T?> get<T>(String key, {T? defaultValue});
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
  Future<Set<String>> getKeys();
  
  // Métodos para JSON
  Future<Map<String, dynamic>?> getJson(String key);
  Future<void> saveJson(String key, Map<String, dynamic> value);
  
  // Métodos convenientes para tipos específicos
  Future<String?> getString(String key, {String? defaultValue});
}

/// Implementação concreta usando IsarPreferencesRepository
class LocalStorageServiceImpl implements LocalStorageService {
  late IsarPreferencesRepository _prefs;
  
  Future<void> _init() async {
    _prefs = IsarPreferencesRepository(IsarService.instance.database);
  }

  @override
  Future<void> save(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      // IsarPreferencesRepository não tem setDouble, converter para String
      await _prefs.setString(key, value.toString());
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      // Para objetos complexos, usar JSON
      await _prefs.setString(key, jsonEncode(value));
    }
  }

  @override
  Future<T?> get<T>(String key, {T? defaultValue}) async {
    final hasKey = await _prefs.getString(key) != null;
    if (!hasKey) {
      return defaultValue;
    }

    // Para double, precisamos converter da String salva
    if (T == double) {
      final value = await _prefs.getString(key);
      if (value != null) {
        return double.tryParse(value) as T? ?? defaultValue;
      }
    }
    
    // Para outros tipos, usar métodos diretos
    if (T == String) {
      return await _prefs.getString(key) as T? ?? defaultValue;
    } else if (T == int) {
      return await _prefs.getInt(key) as T? ?? defaultValue;
    } else if (T == bool) {
      return await _prefs.getBool(key) as T? ?? defaultValue;
    } else if (T == List && T.toString().contains('String')) {
      return await _prefs.getStringList(key) as T? ?? defaultValue;
    }
    
    return defaultValue;
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _prefs.getString(key) != null;
  }

  @override
  Future<Set<String>> getKeys() async {
    return await _prefs.getKeys();
  }

  // Métodos convenientes para tipos específicos
  @override
  Future<String?> getString(String key, {String? defaultValue}) async {
    return await _prefs.getString(key) ?? defaultValue;
  }

  Future<int?> getInt(String key, {int? defaultValue}) async {
    return await _prefs.getInt(key) ?? defaultValue;
  }

  Future<double?> getDouble(String key, {double? defaultValue}) async {
    final value = await _prefs.getString(key);
    if (value != null) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  Future<bool?> getBool(String key, {bool? defaultValue}) async {
    return await _prefs.getBool(key) ?? defaultValue;
  }

  Future<List<String>?> getStringList(String key, {List<String>? defaultValue}) async {
    return await _prefs.getStringList(key) ?? defaultValue;
  }

  // Métodos para JSON
  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await _prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }
}
