import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/procrastination/data/repositories/procrastination_config_repository.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_config_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Configurações de controle de procrastinação
class ProcrastinationConfig {
  final bool isEnabled;
  final int dailyFocusMinutes;
  final bool enableNotifications;
  final TimeOfDay reminderTime;
  final int streakDays;
  final DateTime? lastFocusDate;
  final int totalFocusMinutes;
  final int longestFocusSession;
  final bool enableAppBlocking;
  final List<String> blockedApps;
  final int blockDurationMinutes;

  const ProcrastinationConfig({
    required this.isEnabled,
    this.dailyFocusMinutes = 120,
    this.enableNotifications = true,
    this.reminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.streakDays = 0,
    this.lastFocusDate,
    this.totalFocusMinutes = 0,
    this.longestFocusSession = 0,
    this.enableAppBlocking = false,
    this.blockedApps = const [],
    this.blockDurationMinutes = 30,
  });

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'dailyFocusMinutes': dailyFocusMinutes,
        'enableNotifications': enableNotifications,
        'reminderHour': reminderTime.hour,
        'reminderMinute': reminderTime.minute,
        'streakDays': streakDays,
        'lastFocusDate': lastFocusDate?.toIso8601String(),
        'totalFocusMinutes': totalFocusMinutes,
        'longestFocusSession': longestFocusSession,
        'enableAppBlocking': enableAppBlocking,
        'blockedApps': blockedApps,
        'blockDurationMinutes': blockDurationMinutes,
      };

  factory ProcrastinationConfig.fromJson(Map<String, dynamic> json) => ProcrastinationConfig(
        isEnabled: json['isEnabled'] ?? false,
        dailyFocusMinutes: json['dailyFocusMinutes'] ?? 120,
        enableNotifications: json['enableNotifications'] ?? true,
        reminderTime: TimeOfDay(
          hour: json['reminderHour'] ?? 9,
          minute: json['reminderMinute'] ?? 0,
        ),
        streakDays: json['streakDays'] ?? 0,
        lastFocusDate: json['lastFocusDate'] != null ? DateTime.parse(json['lastFocusDate']) : null,
        totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
        longestFocusSession: json['longestFocusSession'] ?? 0,
        enableAppBlocking: json['enableAppBlocking'] ?? false,
        blockedApps: List<String>.from(json['blockedApps'] ?? []),
        blockDurationMinutes: json['blockDurationMinutes'] ?? 30,
      );

  ProcrastinationConfig copyWith({
    bool? isEnabled,
    int? dailyFocusMinutes,
    bool? enableNotifications,
    TimeOfDay? reminderTime,
    int? streakDays,
    DateTime? lastFocusDate,
    int? totalFocusMinutes,
    int? longestFocusSession,
    bool? enableAppBlocking,
    List<String>? blockedApps,
    int? blockDurationMinutes,
  }) {
    return ProcrastinationConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      dailyFocusMinutes: dailyFocusMinutes ?? this.dailyFocusMinutes,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
      streakDays: streakDays ?? this.streakDays,
      lastFocusDate: lastFocusDate ?? this.lastFocusDate,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      longestFocusSession: longestFocusSession ?? this.longestFocusSession,
      enableAppBlocking: enableAppBlocking ?? this.enableAppBlocking,
      blockedApps: blockedApps ?? this.blockedApps,
      blockDurationMinutes: blockDurationMinutes ?? this.blockDurationMinutes,
    );
  }
}

/// Service para Procrastination usando Isar puro (sem IsarPreferencesRepository)
class ProcrastinationServiceIsar {
  static ProcrastinationServiceIsar? _instance;
  static ProcrastinationServiceIsar get instance => _instance ??= ProcrastinationServiceIsar._internal();
  
  ProcrastinationServiceIsar._internal();

  final ProcrastinationConfigRepository _repository = ProcrastinationConfigRepository.instance;

  Future<ProcrastinationConfig> getConfig() async {
    try {
      final entity = await _repository.getConfig();
      
      if (entity == null) {
        // Configuração padrão
        final defaultConfig = const ProcrastinationConfig(
          isEnabled: false,
          dailyFocusMinutes: 120,
        );
        
        await saveConfig(defaultConfig);
        return defaultConfig;
      }
      
      return ProcrastinationConfig(
        isEnabled: entity.isEnabled,
        dailyFocusMinutes: entity.dailyFocusMinutes,
        enableNotifications: entity.enableNotifications,
        reminderTime: TimeOfDay(
          hour: entity.reminderHour,
          minute: entity.reminderMinute,
        ),
        streakDays: entity.streakDays,
        lastFocusDate: entity.lastFocusDate,
        totalFocusMinutes: entity.totalFocusMinutes,
        longestFocusSession: entity.longestFocusSession,
        enableAppBlocking: entity.enableAppBlocking,
        blockedApps: entity.blockedApps,
        blockDurationMinutes: entity.blockDurationMinutes,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Procrastination', error: e);
      rethrow;
    }
  }

  Future<void> saveConfig(ProcrastinationConfig config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      final entity = ProcrastinationConfigEntity(userId: userId);
      
      entity.isEnabled = config.isEnabled;
      entity.dailyFocusMinutes = config.dailyFocusMinutes;
      entity.enableNotifications = config.enableNotifications;
      entity.reminderHour = config.reminderTime.hour;
      entity.reminderMinute = config.reminderTime.minute;
      entity.streakDays = config.streakDays;
      entity.lastFocusDate = config.lastFocusDate;
      entity.totalFocusMinutes = config.totalFocusMinutes;
      entity.longestFocusSession = config.longestFocusSession;
      entity.enableAppBlocking = config.enableAppBlocking;
      entity.blockedApps = config.blockedApps;
      entity.blockDurationMinutes = config.blockDurationMinutes;
      
      await _repository.saveConfig(entity);
      
      LoggerService.instance.i('Configuração do Procrastination salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Procrastination', error: e);
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

  Future<void> updateFocusSettings({
    int? dailyFocusMinutes,
    bool? enableAppBlocking,
    List<String>? blockedApps,
    int? blockDurationMinutes,
  }) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        dailyFocusMinutes: dailyFocusMinutes ?? currentConfig.dailyFocusMinutes,
        enableAppBlocking: enableAppBlocking ?? currentConfig.enableAppBlocking,
        blockedApps: blockedApps ?? currentConfig.blockedApps,
        blockDurationMinutes: blockDurationMinutes ?? currentConfig.blockDurationMinutes,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Configurações de foco atualizadas');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar configurações de foco', error: e);
      rethrow;
    }
  }

  Future<void> recordFocusSession(int minutes) async {
    try {
      final currentConfig = await getConfig();
      final now = DateTime.now();
      
      // Calcular streak
      int newStreakDays = currentConfig.streakDays;
      DateTime? lastFocusDate = currentConfig.lastFocusDate;
      
      if (lastFocusDate != null) {
        final daysDiff = now.difference(lastFocusDate).inDays;
        if (daysDiff == 1) {
          // Continuou o streak
          newStreakDays++;
        } else if (daysDiff > 1) {
          // Quebrou o streak
          newStreakDays = 1;
        }
        // Se daysDiff == 0, mesma dia, não incrementa
      } else {
        // Primeira sessão
        newStreakDays = 1;
      }
      
      // Atualizar estatísticas
      final newTotalMinutes = currentConfig.totalFocusMinutes + minutes;
      final newLongestSession = minutes > currentConfig.longestFocusSession ? minutes : currentConfig.longestFocusSession;
      
      final updatedConfig = currentConfig.copyWith(
        streakDays: newStreakDays,
        lastFocusDate: now,
        totalFocusMinutes: newTotalMinutes,
        longestFocusSession: newLongestSession,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Sessão de foco registrada: $minutes minutos, streak: $newStreakDays dias');
    } catch (e) {
      LoggerService.instance.e('Erro ao registrar sessão de foco', error: e);
      rethrow;
    }
  }

  Future<void> addBlockedApp(String packageName) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedApps = List<String>.from(currentConfig.blockedApps);
      if (!updatedApps.contains(packageName)) {
        updatedApps.add(packageName);
        
        final updatedConfig = currentConfig.copyWith(blockedApps: updatedApps);
        await saveConfig(updatedConfig);
        
        LoggerService.instance.i('App bloqueado adicionado: $packageName');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao adicionar app bloqueado', error: e);
      rethrow;
    }
  }

  Future<void> removeBlockedApp(String packageName) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedApps = List<String>.from(currentConfig.blockedApps);
      updatedApps.remove(packageName);
      
      final updatedConfig = currentConfig.copyWith(blockedApps: updatedApps);
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('App bloqueado removido: $packageName');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover app bloqueado', error: e);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _repository.clearAll();
      LoggerService.instance.i('Todos os dados do Procrastination foram limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar dados do Procrastination', error: e);
      rethrow;
    }
  }
}
