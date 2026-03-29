import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/binge_eating/data/repositories/binge_eating_config_repository.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_config_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Configurações de controle de compulsão alimentar
class BingeEatingConfig {
  final bool isEnabled;
  final DateTime? blockedUntil;
  final String? blockReason;
  final int dailyLimitMinutes;
  final bool requirePassword;
  final List<String> triggerFoods;
  final List<String> copingStrategies;
  final bool enableNotifications;
  final TimeOfDay reminderTime;
  
  // AppLock Configuration
  final bool enableAppLock;
  final List<String> monitoredApps;
  final bool appLockRequirePassword;
  final String appLockMessage;
  final int appLockCooldownMinutes;

  const BingeEatingConfig({
    required this.isEnabled,
    this.blockedUntil,
    this.blockReason,
    this.dailyLimitMinutes = 60,
    this.requirePassword = false,
    this.triggerFoods = const [],
    this.copingStrategies = const [],
    this.enableNotifications = true,
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.enableAppLock = false,
    this.monitoredApps = const [],
    this.appLockRequirePassword = false,
    this.appLockMessage = "Pare! Você está tentando acessar um app durante seu momento de controle alimentar.",
    this.appLockCooldownMinutes = 5,
  });

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'blockedUntil': blockedUntil?.toIso8601String(),
        'blockReason': blockReason,
        'dailyLimitMinutes': dailyLimitMinutes,
        'requirePassword': requirePassword,
        'triggerFoods': triggerFoods,
        'copingStrategies': copingStrategies,
        'enableNotifications': enableNotifications,
        'reminderHour': reminderTime.hour,
        'reminderMinute': reminderTime.minute,
        'enableAppLock': enableAppLock,
        'monitoredApps': monitoredApps,
        'appLockRequirePassword': appLockRequirePassword,
        'appLockMessage': appLockMessage,
        'appLockCooldownMinutes': appLockCooldownMinutes,
      };

  factory BingeEatingConfig.fromJson(Map<String, dynamic> json) => BingeEatingConfig(
        isEnabled: json['isEnabled'] ?? false,
        blockedUntil: json['blockedUntil'] != null ? DateTime.parse(json['blockedUntil']) : null,
        blockReason: json['blockReason'],
        dailyLimitMinutes: json['dailyLimitMinutes'] ?? 60,
        requirePassword: json['requirePassword'] ?? false,
        triggerFoods: List<String>.from(json['triggerFoods'] ?? []),
        copingStrategies: List<String>.from(json['copingStrategies'] ?? []),
        enableNotifications: json['enableNotifications'] ?? true,
        reminderTime: TimeOfDay(
          hour: json['reminderHour'] ?? 20,
          minute: json['reminderMinute'] ?? 0,
        ),
        enableAppLock: json['enableAppLock'] ?? false,
        monitoredApps: List<String>.from(json['monitoredApps'] ?? []),
        appLockRequirePassword: json['appLockRequirePassword'] ?? false,
        appLockMessage: json['appLockMessage'] ?? "Pare! Você está tentando acessar um app durante seu momento de controle alimentar.",
        appLockCooldownMinutes: json['appLockCooldownMinutes'] ?? 5,
      );

  BingeEatingConfig copyWith({
    bool? isEnabled,
    DateTime? blockedUntil,
    String? blockReason,
    int? dailyLimitMinutes,
    bool? requirePassword,
    List<String>? triggerFoods,
    List<String>? copingStrategies,
    bool? enableNotifications,
    TimeOfDay? reminderTime,
    bool? enableAppLock,
    List<String>? monitoredApps,
    bool? appLockRequirePassword,
    String? appLockMessage,
    int? appLockCooldownMinutes,
  }) {
    return BingeEatingConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      blockedUntil: blockedUntil ?? this.blockedUntil,
      blockReason: blockReason ?? this.blockReason,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      requirePassword: requirePassword ?? this.requirePassword,
      triggerFoods: triggerFoods ?? this.triggerFoods,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
      enableAppLock: enableAppLock ?? this.enableAppLock,
      monitoredApps: monitoredApps ?? this.monitoredApps,
      appLockRequirePassword: appLockRequirePassword ?? this.appLockRequirePassword,
      appLockMessage: appLockMessage ?? this.appLockMessage,
      appLockCooldownMinutes: appLockCooldownMinutes ?? this.appLockCooldownMinutes,
    );
  }
}

/// Service para BingeEating usando Isar puro (sem IsarPreferencesRepository)
class BingeEatingServiceIsar {
  static BingeEatingServiceIsar? _instance;
  static BingeEatingServiceIsar get instance => _instance ??= BingeEatingServiceIsar._internal();
  
  BingeEatingServiceIsar._internal();

  final BingeEatingConfigRepository _repository = BingeEatingConfigRepository.instance;

  Future<BingeEatingConfig> getConfig() async {
    try {
      final entity = await _repository.getConfig();
      
      if (entity == null) {
        // Configuração padrão
        final defaultConfig = BingeEatingConfig(
          isEnabled: false,
          dailyLimitMinutes: 60,
          requirePassword: false,
          enableNotifications: true,
        );
        
        await saveConfig(defaultConfig);
        return defaultConfig;
      }
      
      return BingeEatingConfig(
        isEnabled: entity.isEnabled,
        blockedUntil: entity.blockedUntil,
        blockReason: entity.blockReason,
        dailyLimitMinutes: entity.dailyLimitMinutes,
        requirePassword: entity.requirePassword,
        triggerFoods: entity.triggerFoods,
        copingStrategies: entity.copingStrategies,
        enableNotifications: entity.enableNotifications,
        reminderTime: TimeOfDay(
          hour: entity.reminderHour,
          minute: entity.reminderMinute,
        ),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do BingeEating', error: e);
      rethrow;
    }
  }

  Future<void> saveConfig(BingeEatingConfig config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      final entity = BingeEatingConfigEntity(
        userId: userId,
      );
      
      entity.isEnabled = config.isEnabled;
      entity.blockedUntil = config.blockedUntil;
      entity.blockReason = config.blockReason;
      entity.dailyLimitMinutes = config.dailyLimitMinutes;
      entity.requirePassword = config.requirePassword;
      entity.triggerFoods = config.triggerFoods;
      entity.copingStrategies = config.copingStrategies;
      entity.enableNotifications = config.enableNotifications;
      entity.reminderHour = config.reminderTime.hour;
      entity.reminderMinute = config.reminderTime.minute;
      
      await _repository.saveConfig(entity);
      
      LoggerService.instance.i('Configuração do BingeEating salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do BingeEating', error: e);
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
        isEnabled: false,
        blockReason: reason,
        blockedUntil: until,
      );
      
      await saveConfig(blockedConfig);
      
      LoggerService.instance.i('Conteúdo de compulsão alimentar bloqueado: $reason');
    } catch (e) {
      LoggerService.instance.e('Erro ao bloquear conteúdo de compulsão alimentar', error: e);
      rethrow;
    }
  }

  Future<void> unblockContent() async {
    try {
      final currentConfig = await getConfig();
      
      final unblockedConfig = currentConfig.copyWith(
        isEnabled: true,
        blockReason: null,
        blockedUntil: null,
      );
      
      await saveConfig(unblockedConfig);
      
      LoggerService.instance.i('Conteúdo de compulsão alimentar desbloqueado');
    } catch (e) {
      LoggerService.instance.e('Erro ao desbloquear conteúdo de compulsão alimentar', error: e);
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

  Future<void> updateTriggerFoods(List<String> foods) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        triggerFoods: foods,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Alimentos gatilho atualizados: ${foods.length} itens');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar alimentos gatilho', error: e);
      rethrow;
    }
  }

  Future<void> updateCopingStrategies(List<String> strategies) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        copingStrategies: strategies,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Estratégias de enfrentamento atualizadas: ${strategies.length} itens');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estratégias de enfrentamento', error: e);
      rethrow;
    }
  }

  Future<void> updateNotificationSettings({
    required bool enableNotifications,
    TimeOfDay? reminderTime,
  }) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        enableNotifications: enableNotifications,
        reminderTime: reminderTime ?? currentConfig.reminderTime,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Configurações de notificação atualizadas');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar configurações de notificação', error: e);
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
      
      LoggerService.instance.i('Configurações de AppLock atualizadas');
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
      LoggerService.instance.i('Todos os dados do BingeEating foram limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar dados do BingeEating', error: e);
      rethrow;
    }
  }
}
