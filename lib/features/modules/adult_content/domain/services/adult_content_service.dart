import 'dart:convert';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';

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

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'blockedUntil': blockedUntil?.toIso8601String(),
        'blockReason': blockReason,
        'dailyLimitMinutes': dailyLimitMinutes,
        'requirePassword': requirePassword,
      };

  factory AdultContentConfig.fromJson(Map<String, dynamic> json) => AdultContentConfig(
        isEnabled: json['isEnabled'] ?? false,
        blockedUntil: json['blockedUntil'] != null ? DateTime.parse(json['blockedUntil']) : null,
        blockReason: json['blockReason'],
        dailyLimitMinutes: json['dailyLimitMinutes'] ?? 60,
        requirePassword: json['requirePassword'] ?? false,
      );

  AdultContentConfig copyWith({
    bool? isEnabled,
    DateTime? blockedUntil,
    String? blockReason,
    int? dailyLimitMinutes,
    bool? requirePassword,
  }) {
    return AdultContentConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      blockedUntil: blockedUntil ?? this.blockedUntil,
      blockReason: blockReason ?? this.blockReason,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      requirePassword: requirePassword ?? this.requirePassword,
    );
  }
}

/// Estatísticas de uso do conteúdo adulto
class AdultContentStats {
  final int totalBlockedAttempts;
  final int totalAccessAttempts;
  final Duration totalAccessTime;

  const AdultContentStats({
    required this.totalBlockedAttempts,
    required this.totalAccessAttempts,
    required this.totalAccessTime,
  });

  Map<String, dynamic> toJson() => {
        'totalBlockedAttempts': totalBlockedAttempts,
        'totalAccessAttempts': totalAccessAttempts,
        'totalAccessTime': totalAccessTime.inMilliseconds,
      };

  factory AdultContentStats.fromJson(Map<String, dynamic> json) => AdultContentStats(
        totalBlockedAttempts: json['totalBlockedAttempts'] ?? 0,
        totalAccessAttempts: json['totalAccessAttempts'] ?? 0,
        totalAccessTime: Duration(milliseconds: json['totalAccessTime'] ?? 0),
      );

  AdultContentStats copyWith({
    int? totalBlockedAttempts,
    int? totalAccessAttempts,
    Duration? totalAccessTime,
  }) {
    return AdultContentStats(
      totalBlockedAttempts: totalBlockedAttempts ?? this.totalBlockedAttempts,
      totalAccessAttempts: totalAccessAttempts ?? this.totalAccessAttempts,
      totalAccessTime: totalAccessTime ?? this.totalAccessTime,
    );
  }
}

/// Serviço principal para controle de conteúdo adulto - VERSÃO RIVERPOD
/// Service puro sem ChangeNotifier - estado gerenciado pelo controller
class AdultContentService {
  static const String _configKey = 'adult_content_config';
  static const String _statsKey = 'adult_content_stats';
  static const String _blockedAppsKey = 'blocked_adult_apps';

  final ObjectBoxPreferencesRepository _prefs;

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
        totalAccessTime: Duration.zero,
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
  }

  /// Desativa o bloqueio de conteúdo adulto
  Future<void> disableBlocking() async {
    final newConfig = AdultContentConfig(
      isEnabled: false,
      blockReason: null,
      blockedUntil: null,
      dailyLimitMinutes: 60,
      requirePassword: false,
    );

    await _saveConfig(newConfig);
    LoggerService.instance.i('Bloqueio de conteúdo adulto desativado');
  }

  /// Verifica se o acesso a um aplicativo deve ser bloqueado
  Future<bool> checkAccess(String packageName) async {
    if (!config.isEnabled) return true;

    // Verifica se está na lista de bloqueio
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
    }
  }

  /// Remove aplicativo da lista de bloqueio
  Future<void> unblockApp(String packageName) async {
    if (_blockedApps.remove(packageName)) {
      await _saveBlockedApps();
      LoggerService.instance.i('App desbloqueado: $packageName');
    }
  }

  /// Estende o bloqueio por mais tempo
  Future<void> extendBlocking(Duration extension, {String? reason}) async {
    if (config.blockedUntil == null) return;
    
    final newBlockedUntil = config.blockedUntil!.add(extension);
    final newConfig = config.copyWith(
      blockedUntil: newBlockedUntil,
      blockReason: reason ?? config.blockReason,
    );

    await _saveConfig(newConfig);
    LoggerService.instance.i('Bloqueio estendido por ${extension.inMinutes} minutos');
  }

  /// Reseta estatísticas de uso
  Future<void> resetStats() async {
    final newStats = AdultContentStats(
      totalBlockedAttempts: 0,
      totalAccessAttempts: 0,
      totalAccessTime: Duration.zero,
    );

    await _saveStats(newStats);
    LoggerService.instance.i('Estatísticas de conteúdo adulto resetadas');
  }

  /// Métodos privados de persistência
  Future<void> _loadConfig() async {
    try {
      final String? data = await _prefs.getString(_configKey);
      if (data != null) {
        final json = jsonDecode(data);
        _config = AdultContentConfig.fromJson(json);
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar config do adult content: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final String? data = await _prefs.getString(_statsKey);
      if (data != null) {
        final json = jsonDecode(data);
        _stats = AdultContentStats.fromJson(json);
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar stats do adult content: $e');
    }
  }

  Future<void> _loadBlockedApps() async {
    try {
      final String? data = await _prefs.getString(_blockedAppsKey);
      if (data != null) {
        final List<dynamic> json = jsonDecode(data);
        _blockedApps = json.cast<String>();
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar blocked apps: $e');
    }
  }

  Future<void> _saveConfig(AdultContentConfig config) async {
    try {
      _config = config;
      await _prefs.setString(_configKey, jsonEncode(config.toJson()));
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar config do adult content: $e');
    }
  }

  Future<void> _saveStats(AdultContentStats stats) async {
    try {
      _stats = stats;
      await _prefs.setString(_statsKey, jsonEncode(stats.toJson()));
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar stats do adult content: $e');
    }
  }

  Future<void> _saveBlockedApps() async {
    try {
      await _prefs.setString(_blockedAppsKey, jsonEncode(_blockedApps));
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar blocked apps: $e');
    }
  }

  /// Registra tentativa de acesso bloqueado
  Future<void> _recordBlockedAttempt(String packageName) async {
    final newStats = AdultContentStats(
      totalBlockedAttempts: _stats!.totalBlockedAttempts + 1,
      totalAccessAttempts: _stats!.totalAccessAttempts,
      totalAccessTime: _stats!.totalAccessTime,
    );

    await _saveStats(newStats);
    LoggerService.instance.w('Tentativa de acesso bloqueada: $packageName');
  }

  /// Registra tentativa de acesso permitido
  Future<void> _recordAccessAttempt(String packageName) async {
    final newStats = AdultContentStats(
      totalBlockedAttempts: _stats!.totalBlockedAttempts,
      totalAccessAttempts: _stats!.totalAccessAttempts + 1,
      totalAccessTime: _stats!.totalAccessTime,
    );

    await _saveStats(newStats);
    LoggerService.instance.i('Acesso permitido: $packageName');
  }

  /// Atualiza estatísticas (método público para uso externo)
  Future<void> updateStats(AdultContentStats newStats) async {
    await _saveStats(newStats);
  }
}
