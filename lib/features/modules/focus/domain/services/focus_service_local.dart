import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/focus/data/repositories/focus_config_repository.dart';
import 'package:disciplinum/features/modules/focus/data/repositories/focus_interval_repository.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_config_entity.dart';
import 'package:disciplinum/shared/domain/models/time_of_day_range.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configurações do Focus
class FocusConfig {
  final bool isModuleActive;
  final bool enableNotifications;
  final int dailyGoalMinutes;
  final TimeOfDay reminderTime;
  final int streakDays;
  final DateTime? lastFocusDate;
  final int totalFocusMinutes;
  final int longestFocusSession;

  const FocusConfig({
    required this.isModuleActive,
    this.enableNotifications = true,
    this.dailyGoalMinutes = 120,
    this.reminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.streakDays = 0,
    this.lastFocusDate,
    this.totalFocusMinutes = 0,
    this.longestFocusSession = 0,
  });

  Map<String, dynamic> toJson() => {
        'isModuleActive': isModuleActive,
        'enableNotifications': enableNotifications,
        'dailyGoalMinutes': dailyGoalMinutes,
        'reminderHour': reminderTime.hour,
        'reminderMinute': reminderTime.minute,
        'streakDays': streakDays,
        'lastFocusDate': lastFocusDate?.toIso8601String(),
        'totalFocusMinutes': totalFocusMinutes,
        'longestFocusSession': longestFocusSession,
      };

  factory FocusConfig.fromJson(Map<String, dynamic> json) => FocusConfig(
        isModuleActive: json['isModuleActive'] ?? json['isEnabled'] ?? false,
        enableNotifications: json['enableNotifications'] ?? true,
        dailyGoalMinutes: json['dailyGoalMinutes'] ?? 120,
        reminderTime: TimeOfDay(
          hour: json['reminderHour'] ?? 9,
          minute: json['reminderMinute'] ?? 0,
        ),
        streakDays: json['streakDays'] ?? 0,
        lastFocusDate: json['lastFocusDate'] != null ? DateTime.parse(json['lastFocusDate']) : null,
        totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
        longestFocusSession: json['longestFocusSession'] ?? 0,
      );

  FocusConfig copyWith({
    bool? isModuleActive,
    bool? enableNotifications,
    int? dailyGoalMinutes,
    TimeOfDay? reminderTime,
    int? streakDays,
    DateTime? lastFocusDate,
    int? totalFocusMinutes,
    int? longestFocusSession,
  }) {
    return FocusConfig(
      isModuleActive: isModuleActive ?? this.isModuleActive,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      reminderTime: reminderTime ?? this.reminderTime,
      streakDays: streakDays ?? this.streakDays,
      lastFocusDate: lastFocusDate ?? this.lastFocusDate,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      longestFocusSession: longestFocusSession ?? this.longestFocusSession,
    );
  }
}

/// Service para Focus usando ObjectBox
class FocusServiceLocal {
  static FocusServiceLocal? _instance;
  static FocusServiceLocal get instance => _instance ??= FocusServiceLocal._internal();
  
  FocusServiceLocal._internal();

  final FocusConfigRepository _configRepository = FocusConfigRepository.instance;
  final FocusIntervalRepository _intervalRepository = FocusIntervalRepository.instance;

  Future<FocusConfig> getConfig() async {
    try {
      final entity = await _configRepository.getConfig();
      
      if (entity == null) {
        // Configuração padrão
        final defaultConfig = FocusConfig(
          isModuleActive: false,
          dailyGoalMinutes: 120,
          enableNotifications: true,
        );
        
        await saveConfig(defaultConfig);
        return defaultConfig;
      }
      
      return FocusConfig(
        isModuleActive: entity.isModuleActive,
        enableNotifications: entity.enableNotifications,
        dailyGoalMinutes: entity.dailyGoalMinutes,
        reminderTime: TimeOfDay(
          hour: entity.reminderHour,
          minute: entity.reminderMinute,
        ),
        streakDays: entity.streakDays,
        lastFocusDate: entity.lastFocusDate,
        totalFocusMinutes: entity.totalFocusMinutes,
        longestFocusSession: entity.longestFocusSession,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Focus', error: e);
      rethrow;
    }
  }

  Future<void> saveConfig(FocusConfig config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      final entity = FocusConfigEntity(userId: userId);
      
      entity.isModuleActive = config.isModuleActive;
      entity.enableNotifications = config.enableNotifications;
      entity.dailyGoalMinutes = config.dailyGoalMinutes;
      entity.reminderHour = config.reminderTime.hour;
      entity.reminderMinute = config.reminderTime.minute;
      entity.streakDays = config.streakDays;
      entity.lastFocusDate = config.lastFocusDate;
      entity.totalFocusMinutes = config.totalFocusMinutes;
      entity.longestFocusSession = config.longestFocusSession;
      
      await _configRepository.saveConfig(entity);
      
      LoggerService.instance.i('Configuração do Focus salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Focus', error: e);
      rethrow;
    }
  }

  Future<void> setModuleActive(bool isActive) async {
    try {
      final config = await getConfig();
      final updated = config.copyWith(isModuleActive: isActive);
      await saveConfig(updated);
      
      if (isActive) {
        await incrementStreak();
      } else {
        await resetStreak();
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao alternar ativação do Focus', error: e);
      rethrow;
    }
  }

  Future<void> updateDailyGoal(int minutes) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        dailyGoalMinutes: minutes,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Meta diária atualizada: $minutes minutos');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar meta diária', error: e);
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

  Future<void> recordFocusSession({
    required int minutes,
    required int nicheId,
  }) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        lastFocusDate: DateTime.now(),
        totalFocusMinutes: currentConfig.totalFocusMinutes + minutes,
        longestFocusSession: minutes > currentConfig.longestFocusSession 
            ? minutes 
            : currentConfig.longestFocusSession,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Sessão de foco registrada: $minutes minutos (total: ${updatedConfig.totalFocusMinutes})');
    } catch (e) {
      LoggerService.instance.e('Erro ao registrar sessão de foco', error: e);
      rethrow;
    }
  }

  Future<void> incrementStreak() async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        streakDays: currentConfig.streakDays + 1,
        lastFocusDate: DateTime.now(),
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Streak incrementado: ${updatedConfig.streakDays} dias');
    } catch (e) {
      LoggerService.instance.e('Erro ao incrementar streak', error: e);
      rethrow;
    }
  }

  Future<void> resetStreak() async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        streakDays: 0,
        lastFocusDate: null,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Streak resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar streak', error: e);
      rethrow;
    }
  }

  // Métodos para gerenciar intervalos de foco
  Future<void> saveFocusInterval({
    required int nicheId,
    required TimeOfDayRange interval,
  }) async {
    try {
      await _intervalRepository.saveInterval(
        nicheId: nicheId,
        interval: interval,
      );
      
      LoggerService.instance.i('Intervalo de foco salvo: nicheId=$nicheId');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar intervalo de foco', error: e);
      rethrow;
    }
  }

  Future<TimeOfDayRange?> getFocusInterval(int nicheId) async {
    try {
      return await _intervalRepository.getInterval(nicheId);
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar intervalo de foco', error: e);
      return null;
    }
  }

  Future<Map<int, TimeOfDayRange>> getAllFocusIntervals() async {
    try {
      return await _intervalRepository.getAllIntervals();
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar todos os intervalos de foco', error: e);
      return {};
    }
  }

  Future<void> removeFocusInterval(int nicheId) async {
    try {
      await _intervalRepository.removeInterval(nicheId);
      LoggerService.instance.i('Intervalo de foco removido: nicheId=$nicheId');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover intervalo de foco', error: e);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _configRepository.clearAll();
      await _intervalRepository.clearAll();
      LoggerService.instance.i('Todos os dados do Focus foram limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar dados do Focus', error: e);
      rethrow;
    }
  }
}
