import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';

/// Configurações de controle de conteúdo adulto
class AdultContentConfig {
  final bool isEnabled;
  final DateTime? blockedUntil;
  final String? blockReason;
  final int dailyLimitMinutes;
  final bool requirePassword;

  const AdultContentConfig({
    required this.isEnabled,
    this.blockedUntil,
    this.blockReason,
    this.dailyLimitMinutes = 60,
    this.requirePassword = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'blockedUntil': blockedUntil?.toIso8601String(),
      'blockReason': blockReason,
      'dailyLimitMinutes': dailyLimitMinutes,
      'requirePassword': requirePassword,
    };
  }

  factory AdultContentConfig.fromJson(Map<String, dynamic> json) {
    return AdultContentConfig(
      isEnabled: json['isEnabled'] ?? false,
      blockedUntil: json['blockedUntil'] != null 
          ? DateTime.parse(json['blockedUntil']) 
          : null,
      blockReason: json['blockReason'],
      dailyLimitMinutes: json['dailyLimitMinutes'] ?? 60,
      requirePassword: json['requirePassword'] ?? false,
    );
  }
}

/// Estatísticas de uso de conteúdo adulto
class AdultContentStats {
  final int totalBlockedAttempts;
  final int totalAccessAttempts;
  final DateTime? lastAccessAttempt;
  final Duration totalBlockedTime;
  final Duration totalAccessTime;

  const AdultContentStats({
    required this.totalBlockedAttempts,
    required this.totalAccessAttempts,
    this.lastAccessAttempt,
    this.totalBlockedTime = Duration.zero,
    this.totalAccessTime = Duration.zero,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalBlockedAttempts': totalBlockedAttempts,
      'totalAccessAttempts': totalAccessAttempts,
      'lastAccessAttempt': lastAccessAttempt?.toIso8601String(),
      'totalBlockedTime': totalBlockedTime.inMilliseconds,
      'totalAccessTime': totalAccessTime.inMilliseconds,
    };
  }

  factory AdultContentStats.fromJson(Map<String, dynamic> json) {
    return AdultContentStats(
      totalBlockedAttempts: json['totalBlockedAttempts'] ?? 0,
      totalAccessAttempts: json['totalAccessAttempts'] ?? 0,
      lastAccessAttempt: json['lastAccessAttempt'] != null
          ? DateTime.parse(json['lastAccessAttempt'])
          : null,
      totalBlockedTime: Duration(milliseconds: json['totalBlockedTime'] ?? 0),
      totalAccessTime: Duration(milliseconds: json['totalAccessTime'] ?? 0),
    );
  }
}

/// Serviço principal para controle de conteúdo adulto - VERSÃO FINAL LIMPA
class AdultContentService extends ChangeNotifier {
  static const String _configKey = 'adult_content_config';
  static const String _statsKey = 'adult_content_stats';
  static const String _blockedAppsKey = 'blocked_adult_apps';

  final IsarPreferencesRepository _prefs;

  AdultContentConfig? _config;
  AdultContentStats? _stats;
  List<String> _blockedApps = [];

  AdultContentService(this._prefs) {
    _loadConfig();
    _loadStats();
    _loadBlockedApps();
  }

  /// Configuração atual de controle
  AdultContentConfig get config => _config ?? AdultContentConfig(isEnabled: false);

  /// Estatísticas atuais de uso
  AdultContentStats get stats => _stats ?? AdultContentStats(
        totalBlockedAttempts: 0,
        totalAccessAttempts: 0,
      );

  /// Lista de aplicativos bloqueados
  List<String> get blockedApps => List.unmodifiable(_blockedApps);

  /// Ativa o bloqueio de conteúdo adulto
  Future<void> enableBlocking({
    required String reason,
    DateTime? blockedUntil,
    int? dailyLimitMinutes,
    bool requirePassword = false,
  }) async {
    final newConfig = AdultContentConfig(
      isEnabled: true,
      blockReason: reason,
      blockedUntil: blockedUntil,
      dailyLimitMinutes: dailyLimitMinutes ?? 60,
      requirePassword: requirePassword,
    );

    await _saveConfig(newConfig);
    LoggerService.instance.i('Bloqueio de conteúdo adulto ativado: $reason');
    notifyListeners();
  }

  /// Desativa o bloqueio de conteúdo adulto
  Future<void> disableBlocking({String? reason}) async {
    final newConfig = AdultContentConfig(
      isEnabled: false,
      blockReason: reason,
    );

    await _saveConfig(newConfig);
    LoggerService.instance.i('Bloqueio de conteúdo adulto desativado: ${reason ?? "User request"}');
    notifyListeners();
  }

  /// Verifica se o acesso é permitido
  Future<bool> isAccessAllowed(String packageName) async {
    if (!_config!.isEnabled) return true;
    
    if (_blockedApps.contains(packageName)) {
      await _recordBlockedAttempt(packageName);
      return false;
    }

    await _recordAccessAttempt(packageName);
    return true;
  }

  /// Adiciona aplicativo à lista de bloqueio
  Future<void> blockApp(String packageName, {String? reason}) async {
    if (!_blockedApps.contains(packageName)) {
      _blockedApps.add(packageName);
      await _saveBlockedApps();
      LoggerService.instance.i('App bloqueado: $packageName');
      notifyListeners();
    }
  }

  /// Remove aplicativo da lista de bloqueio
  Future<void> unblockApp(String packageName) async {
    if (_blockedApps.remove(packageName)) {
      await _saveBlockedApps();
      LoggerService.instance.i('App desbloqueado: $packageName');
      notifyListeners();
    }
  }

  /// Estende o bloqueio por mais tempo
  Future<void> extendBlocking(Duration extension, {String? reason}) async {
    if (_config?.blockedUntil == null) return;
    
    final newBlockedUntil = _config!.blockedUntil!.add(extension);
    final newConfig = AdultContentConfig(
      isEnabled: _config!.isEnabled,
      blockReason: reason ?? _config!.blockReason,
      blockedUntil: newBlockedUntil,
      dailyLimitMinutes: _config!.dailyLimitMinutes,
      requirePassword: _config!.requirePassword,
    );

    await _saveConfig(newConfig);
    LoggerService.instance.i('Bloqueio estendido por ${extension.inMinutes} minutos');
    notifyListeners();
  }

  /// Reseta estatísticas de uso
  Future<void> resetStats() async {
    final newStats = AdultContentStats(
      totalBlockedAttempts: 0,
      totalAccessAttempts: 0,
      lastAccessAttempt: DateTime.now(),
    );

    await _saveStats(newStats);
    LoggerService.instance.i('Estatísticas de conteúdo adulto resetadas');
    notifyListeners();
  }

  /// Limpa todos os dados do serviço
  Future<void> clearAllData() async {
    _config = AdultContentConfig(isEnabled: false);
    _stats = AdultContentStats(
      totalBlockedAttempts: 0,
      totalAccessAttempts: 0,
    );
    _blockedApps.clear();
    
    LoggerService.instance.i('Dados de conteúdo adulto limpos');
    notifyListeners();
  }

  /// Carrega configuração do armazenamento local
  Future<void> _loadConfig() async {
    final configJson = await _prefs.getString(_configKey);
    if (configJson != null) {
      final Map<String, dynamic> configMap = jsonDecode(configJson);
      _config = AdultContentConfig.fromJson(configMap);
    } else {
      _config = AdultContentConfig(isEnabled: false);
    }
  }

  /// Salva configuração no armazenamento local
  Future<void> _saveConfig(AdultContentConfig config) async {
    _config = config;
    await _prefs.setString(_configKey, jsonEncode(config.toJson()));
  }

  /// Carrega estatísticas do armazenamento local
  Future<void> _loadStats() async {
    final statsJson = await _prefs.getString(_statsKey);
    if (statsJson != null) {
      final Map<String, dynamic> statsMap = jsonDecode(statsJson);
      _stats = AdultContentStats.fromJson(statsMap);
    } else {
      _stats = AdultContentStats(
        totalBlockedAttempts: 0,
        totalAccessAttempts: 0,
      );
    }
  }

  /// Salva estatísticas no armazenamento local
  Future<void> _saveStats(AdultContentStats stats) async {
    _stats = stats;
    await _prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  /// Atualiza estatísticas (método público para uso externo)
  Future<void> updateStats(AdultContentStats newStats) async {
    await _saveStats(newStats);
    notifyListeners();
  }

  /// Carrega lista de apps bloqueados
  Future<void> _loadBlockedApps() async {
    final appsJson = await _prefs.getString(_blockedAppsKey);
    if (appsJson != null) {
      final List<dynamic> appsList = jsonDecode(appsJson);
      _blockedApps = appsList.cast<String>();
    } else {
      _blockedApps = [];
    }
  }

  /// Salva lista de apps bloqueados
  Future<void> _saveBlockedApps() async {
    await _prefs.setString(_blockedAppsKey, jsonEncode(_blockedApps));
  }

  /// Registra tentativa de acesso bloqueado
  Future<void> _recordBlockedAttempt(String packageName) async {
    final newStats = AdultContentStats(
      totalBlockedAttempts: _stats!.totalBlockedAttempts + 1,
      totalAccessAttempts: _stats!.totalAccessAttempts,
      lastAccessAttempt: DateTime.now(),
      totalBlockedTime: _stats!.totalBlockedTime,
      totalAccessTime: _stats!.totalAccessTime,
    );

    await _saveStats(newStats);
    LoggerService.instance.i('Tentativa de acesso bloqueado registrada');
  }

  /// Registra tentativa de acesso permitido
  Future<void> _recordAccessAttempt(String packageName) async {
    final newStats = AdultContentStats(
      totalBlockedAttempts: _stats!.totalBlockedAttempts,
      totalAccessAttempts: _stats!.totalAccessAttempts + 1,
      lastAccessAttempt: DateTime.now(),
      totalBlockedTime: _stats!.totalBlockedTime,
      totalAccessTime: _stats!.totalAccessTime,
    );

    await _saveStats(newStats);
    LoggerService.instance.i('Tentativa de acesso permitido registrada');
  }
}
