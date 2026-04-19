import 'package:disciplinum/features/modules/adult_content/data/repositories/adult_content_config_repository.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_config_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Configurações de controle de conteúdo adulto
class AdultContentConfig {
  final bool isModuleActive;
  final DateTime? blockedUntil;
  final String? blockReason;
  final int dailyLimitMinutes;
  final bool requirePassword;
  
  // AppLock Configuration
  final bool enableAppLock;
  final List<String> monitoredApps;
  final bool appLockRequirePassword;
  final String appLockMessage;
  final int appLockCooldownMinutes;

  const AdultContentConfig({
    required this.isModuleActive,
    this.blockedUntil,
    this.blockReason,
    this.dailyLimitMinutes = 60,
    this.requirePassword = false,
    this.enableAppLock = false,
    this.monitoredApps = const [],
    this.appLockRequirePassword = false,
    this.appLockMessage = "Pare! Você está tentando acessar conteúdo adulto durante seu período de controle.",
    this.appLockCooldownMinutes = 10,
  });

  Map<String, dynamic> toJson() => {
        'isModuleActive': isModuleActive,
        'blockedUntil': blockedUntil?.toIso8601String(),
        'blockReason': blockReason,
        'dailyLimitMinutes': dailyLimitMinutes,
        'requirePassword': requirePassword,
        'enableAppLock': enableAppLock,
        'monitoredApps': monitoredApps,
        'appLockRequirePassword': appLockRequirePassword,
        'appLockMessage': appLockMessage,
        'appLockCooldownMinutes': appLockCooldownMinutes,
      };

  factory AdultContentConfig.fromJson(Map<String, dynamic> json) => AdultContentConfig(
        isModuleActive: json['isModuleActive'] ?? json['isEnabled'] ?? false,
        blockedUntil: json['blockedUntil'] != null ? DateTime.parse(json['blockedUntil']) : null,
        blockReason: json['blockReason'],
        dailyLimitMinutes: json['dailyLimitMinutes'] ?? 60,
        requirePassword: json['requirePassword'] ?? false,
        enableAppLock: json['enableAppLock'] ?? false,
        monitoredApps: List<String>.from(json['monitoredApps'] ?? []),
        appLockRequirePassword: json['appLockRequirePassword'] ?? false,
        appLockMessage: json['appLockMessage'] ?? "Pare! Você está tentando acessar conteúdo adulto durante seu período de controle.",
        appLockCooldownMinutes: json['appLockCooldownMinutes'] ?? 10,
      );

  AdultContentConfig copyWith({
    bool? isModuleActive,
    DateTime? blockedUntil,
    String? blockReason,
    int? dailyLimitMinutes,
    bool? requirePassword,
    bool? enableAppLock,
    List<String>? monitoredApps,
    bool? appLockRequirePassword,
    String? appLockMessage,
    int? appLockCooldownMinutes,
  }) {
    return AdultContentConfig(
      isModuleActive: isModuleActive ?? this.isModuleActive,
      blockedUntil: blockedUntil ?? this.blockedUntil,
      blockReason: blockReason ?? this.blockReason,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      requirePassword: requirePassword ?? this.requirePassword,
      enableAppLock: enableAppLock ?? this.enableAppLock,
      monitoredApps: monitoredApps ?? this.monitoredApps,
      appLockRequirePassword: appLockRequirePassword ?? this.appLockRequirePassword,
      appLockMessage: appLockMessage ?? this.appLockMessage,
      appLockCooldownMinutes: appLockCooldownMinutes ?? this.appLockCooldownMinutes,
    );
  }
}

/// Service para Adult Content usando ObjectBox
class AdultContentServiceLocal {
  static AdultContentServiceLocal? _instance;
  static AdultContentServiceLocal get instance => _instance ??= AdultContentServiceLocal._internal();
  
  AdultContentServiceLocal._internal();

  final AdultContentConfigRepository _repository = AdultContentConfigRepository.instance;

  Future<AdultContentConfig> getConfig() async {
    try {
      final entity = await _repository.getConfig();
      
      if (entity == null) {
        // Configuração padrão
        final defaultConfig = AdultContentConfig(
          isModuleActive: false,
          dailyLimitMinutes: 60,
          requirePassword: false,
        );
        
        await saveConfig(defaultConfig);
        return defaultConfig;
      }
      
      return AdultContentConfig(
        isModuleActive: entity.isModuleActive,
        blockedUntil: entity.blockedUntil,
        blockReason: entity.blockReason,
        dailyLimitMinutes: entity.dailyLimitMinutes,
        requirePassword: entity.requirePassword,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Adult Content', error: e);
      rethrow;
    }
  }

  Future<void> saveConfig(AdultContentConfig config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      final entity = AdultContentConfigEntity(
        userId: userId,
      );
      
      entity.isModuleActive = config.isModuleActive;
      entity.blockedUntil = config.blockedUntil;
      entity.blockReason = config.blockReason;
      entity.dailyLimitMinutes = config.dailyLimitMinutes;
      entity.requirePassword = config.requirePassword;
      
      await _repository.saveConfig(entity);
      
      LoggerService.instance.i('Configuração do Adult Content salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Adult Content', error: e);
      rethrow;
    }
  }

  Future<void> blockContent({
    required String reason,
    DateTime? until,
  }) async {
    try {
      final currentConfig = await getConfig();
      
      final blockedConfig = currentConfig.copyWith(
        isModuleActive: false,
        blockReason: reason,
        blockedUntil: until,
      );
      
      await saveConfig(blockedConfig);
      
      LoggerService.instance.i('Conteúdo adulto bloqueado: $reason');
    } catch (e) {
      LoggerService.instance.e('Erro ao bloquear conteúdo adulto', error: e);
      rethrow;
    }
  }

  Future<void> unblockContent() async {
    try {
      final currentConfig = await getConfig();
      
      final unblockedConfig = currentConfig.copyWith(
        isModuleActive: true,
        blockReason: null,
        blockedUntil: null,
      );
      
      await saveConfig(unblockedConfig);
      
      LoggerService.instance.i('Conteúdo adulto desbloqueado');
    } catch (e) {
      LoggerService.instance.e('Erro ao desbloquear conteúdo adulto', error: e);
      rethrow;
    }
  }

  Future<void> updateDailyLimit(int minutes) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        dailyLimitMinutes: minutes,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Limite diário atualizado: $minutes minutos');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar limite diário', error: e);
      rethrow;
    }
  }

  Future<void> togglePasswordRequirement(bool requirePassword) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        requirePassword: requirePassword,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Requisição de senha atualizada: $requirePassword');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar requisição de senha', error: e);
      rethrow;
    }
  }

  // ============ MÉTODOS APPLOCK ============

  Future<void> updateAppLockSettings({
    required bool enableAppLock,
    List<String>? monitoredApps,
    bool? appLockRequirePassword,
    String? appLockMessage,
    int? appLockCooldownMinutes,
  }) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        enableAppLock: enableAppLock,
        monitoredApps: monitoredApps ?? currentConfig.monitoredApps,
        appLockRequirePassword: appLockRequirePassword ?? currentConfig.appLockRequirePassword,
        appLockMessage: appLockMessage ?? currentConfig.appLockMessage,
        appLockCooldownMinutes: appLockCooldownMinutes ?? currentConfig.appLockCooldownMinutes,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Configurações de AppLock atualizadas para Adult Content');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar configurações de AppLock', error: e);
      rethrow;
    }
  }

  Future<void> addMonitoredApp(String packageName) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedApps = List<String>.from(currentConfig.monitoredApps);
      if (!updatedApps.contains(packageName)) {
        updatedApps.add(packageName);
        
        final updatedConfig = currentConfig.copyWith(monitoredApps: updatedApps);
        await saveConfig(updatedConfig);
        
        LoggerService.instance.i('App monitorado adicionado: $packageName');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao adicionar app monitorado', error: e);
      rethrow;
    }
  }

  Future<void> removeMonitoredApp(String packageName) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedApps = List<String>.from(currentConfig.monitoredApps);
      updatedApps.remove(packageName);
      
      final updatedConfig = currentConfig.copyWith(monitoredApps: updatedApps);
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('App monitorado removido: $packageName');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover app monitorado', error: e);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _repository.clearAll();
      LoggerService.instance.i('Todos os dados do Adult Content foram limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar dados do Adult Content', error: e);
      rethrow;
    }
  }
}
