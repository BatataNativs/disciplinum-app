import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Implementação concreta usando SharedPreferences
class LocalStorageServiceImpl implements LocalStorageService {
  late SharedPreferences _prefs;
  
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> save(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
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
    if (!_prefs.containsKey(key)) {
      return defaultValue;
    }

    final value = _prefs.get(key);
    
    if (value is T) {
      return value;
    }
    
    // Tentar converter para o tipo esperado
    if (T == String && value != null) {
      return value.toString() as T;
    } else if (T == int && value is int) {
      return value as T;
    } else if (T == double && value is double) {
      return value as T;
    } else if (T == bool && value is bool) {
      return value as T;
    } else if (T == List && value is List<String>) {
      return value as T;
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
    return _prefs.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    return _prefs.getKeys();
  }

  // Métodos convenientes para tipos específicos
  @override
  Future<String?> getString(String key, {String? defaultValue}) async {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<int?> getInt(String key, {int? defaultValue}) async {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<double?> getDouble(String key, {double? defaultValue}) async {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  Future<bool?> getBool(String key, {bool? defaultValue}) async {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<List<String>?> getStringList(String key, {List<String>? defaultValue}) async {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  // Métodos para JSON
  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = _prefs.getString(key);
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
