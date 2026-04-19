import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/reading/data/repositories/reading_config_repository.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configurações do Reading
class ReadingConfig {
  final bool enableNotifications;
  final TimeOfDay reminderTime;
  final bool enableDailyReminder;
  final bool enableStreakReminder;
  final bool isModuleActive;
  final int currentStreak;
  final DateTime? lastReadingDate;
  final DateTime? longestStreakStart;
  final DateTime? longestStreakEnd;
  final int longestStreakDays;
  final int dailyPagesGoal;
  final int weeklyBooksGoal;
  final DateTime createdAt;

  ReadingConfig({
    this.enableNotifications = true,
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.enableDailyReminder = true,
    this.enableStreakReminder = true,
    this.isModuleActive = false,
    this.currentStreak = 0,
    this.lastReadingDate,
    this.longestStreakStart,
    this.longestStreakEnd,
    this.longestStreakDays = 0,
    this.dailyPagesGoal = 20,
    this.weeklyBooksGoal = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'enableNotifications': enableNotifications,
        'reminderHour': reminderTime.hour,
        'reminderMinute': reminderTime.minute,
        'enableDailyReminder': enableDailyReminder,
        'enableStreakReminder': enableStreakReminder,
        'isModuleActive': isModuleActive,
        'currentStreak': currentStreak,
        'lastReadingDate': lastReadingDate?.toIso8601String(),
        'longestStreakStart': longestStreakStart?.toIso8601String(),
        'longestStreakEnd': longestStreakEnd?.toIso8601String(),
        'longestStreakDays': longestStreakDays,
        'dailyPagesGoal': dailyPagesGoal,
        'weeklyBooksGoal': weeklyBooksGoal,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReadingConfig.fromJson(Map<String, dynamic> json) => ReadingConfig(
        enableNotifications: json['enableNotifications'] ?? true,
        reminderTime: TimeOfDay(
          hour: json['reminderHour'] ?? 20,
          minute: json['reminderMinute'] ?? 0,
        ),
        enableDailyReminder: json['enableDailyReminder'] ?? true,
        enableStreakReminder: json['enableStreakReminder'] ?? true,
        isModuleActive: json['isModuleActive'] ?? false,
        currentStreak: json['currentStreak'] ?? 0,
        lastReadingDate: json['lastReadingDate'] != null ? DateTime.parse(json['lastReadingDate']) : null,
        longestStreakStart: json['longestStreakStart'] != null ? DateTime.parse(json['longestStreakStart']) : null,
        longestStreakEnd: json['longestStreakEnd'] != null ? DateTime.parse(json['longestStreakEnd']) : null,
        longestStreakDays: json['longestStreakDays'] ?? 0,
        dailyPagesGoal: json['dailyPagesGoal'] ?? 20,
        weeklyBooksGoal: json['weeklyBooksGoal'] ?? 1,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      );

  ReadingConfig copyWith({
    bool? enableNotifications,
    TimeOfDay? reminderTime,
    bool? enableDailyReminder,
    bool? enableStreakReminder,
    bool? isModuleActive,
    int? currentStreak,
    DateTime? lastReadingDate,
    DateTime? longestStreakStart,
    DateTime? longestStreakEnd,
    int? longestStreakDays,
    int? dailyPagesGoal,
    int? weeklyBooksGoal,
    DateTime? createdAt,
  }) {
    return ReadingConfig(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
      enableDailyReminder: enableDailyReminder ?? this.enableDailyReminder,
      enableStreakReminder: enableStreakReminder ?? this.enableStreakReminder,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      currentStreak: currentStreak ?? this.currentStreak,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      longestStreakStart: longestStreakStart ?? this.longestStreakStart,
      longestStreakEnd: longestStreakEnd ?? this.longestStreakEnd,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      dailyPagesGoal: dailyPagesGoal ?? this.dailyPagesGoal,
      weeklyBooksGoal: weeklyBooksGoal ?? this.weeklyBooksGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Service para Reading usando ObjectBox
class ReadingServiceLocal {
  static ReadingServiceLocal? _instance;
  static ReadingServiceLocal get instance => _instance ??= ReadingServiceLocal._internal();
  
  ReadingServiceLocal._internal();

  final ReadingConfigRepository _repository = ReadingConfigRepository.instance;

  Future<ReadingConfig> getConfig() async {
    try {
      final entity = await _repository.getConfig();
      
      if (entity == null) {
        // Configuração padrão
        final defaultConfig = ReadingConfig(
          enableNotifications: true,
          dailyPagesGoal: 20,
          weeklyBooksGoal: 1,
        );
        
        await saveConfig(defaultConfig);
        return defaultConfig;
      }
      
      return ReadingConfig(
        enableNotifications: entity.enableNotifications,
        reminderTime: TimeOfDay(
          hour: entity.reminderHour,
          minute: entity.reminderMinute,
        ),
        enableDailyReminder: entity.enableDailyReminder,
        enableStreakReminder: entity.enableStreakReminder,
        isModuleActive: entity.isModuleActive,
        currentStreak: entity.currentStreak,
        lastReadingDate: entity.lastReadingDate,
        longestStreakStart: entity.longestStreakStart,
        longestStreakEnd: entity.longestStreakEnd,
        longestStreakDays: entity.longestStreakDays,
        dailyPagesGoal: entity.dailyPagesGoal,
        weeklyBooksGoal: entity.weeklyBooksGoal,
        createdAt: entity.createdAt,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Reading', error: e);
      rethrow;
    }
  }

  Future<void> saveConfig(ReadingConfig config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      final entity = ReadingConfigEntity(userId: userId);
      
      entity.enableNotifications = config.enableNotifications;
      entity.reminderHour = config.reminderTime.hour;
      entity.reminderMinute = config.reminderTime.minute;
      entity.enableDailyReminder = config.enableDailyReminder;
      entity.enableStreakReminder = config.enableStreakReminder;
      entity.isModuleActive = config.isModuleActive;
      entity.currentStreak = config.currentStreak;
      entity.lastReadingDate = config.lastReadingDate;
      entity.longestStreakStart = config.longestStreakStart;
      entity.longestStreakEnd = config.longestStreakEnd;
      entity.longestStreakDays = config.longestStreakDays;
      entity.dailyPagesGoal = config.dailyPagesGoal;
      entity.weeklyBooksGoal = config.weeklyBooksGoal;
      entity.createdAt = config.createdAt;
      
      await _repository.saveConfig(entity);
      
      LoggerService.instance.i('Configuração do Reading salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Reading', error: e);
      rethrow;
    }
  }

  Future<void> setModuleActive(bool isActive) async {
    try {
      final currentConfig = await getConfig();
      final updatedConfig = currentConfig.copyWith(isModuleActive: isActive);
      await saveConfig(updatedConfig);
      LoggerService.instance.i('Estado do módulo Reading atualizado para: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado do módulo Reading', error: e);
      rethrow;
    }
  }

  Future<void> updateNotificationSettings({
    required bool enableNotifications,
    TimeOfDay? reminderTime,
    bool? enableDailyReminder,
    bool? enableStreakReminder,
  }) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        enableNotifications: enableNotifications,
        reminderTime: reminderTime ?? currentConfig.reminderTime,
        enableDailyReminder: enableDailyReminder ?? currentConfig.enableDailyReminder,
        enableStreakReminder: enableStreakReminder ?? currentConfig.enableStreakReminder,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Configurações de notificação atualizadas');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar configurações de notificação', error: e);
      rethrow;
    }
  }

  Future<void> updateGoals({
    int? dailyPagesGoal,
    int? weeklyBooksGoal,
  }) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        dailyPagesGoal: dailyPagesGoal ?? currentConfig.dailyPagesGoal,
        weeklyBooksGoal: weeklyBooksGoal ?? currentConfig.weeklyBooksGoal,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Metas atualizadas');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar metas', error: e);
      rethrow;
    }
  }

  Future<void> recordReadingSession() async {
    try {
      final currentConfig = await getConfig();
      final now = DateTime.now();
      
      // Calcular streak
      int newStreak = currentConfig.currentStreak;
      DateTime? lastReading = currentConfig.lastReadingDate;
      
      if (lastReading != null) {
        final daysDiff = now.difference(lastReading).inDays;
        if (daysDiff == 1) {
          // Continuou o streak
          newStreak++;
        } else if (daysDiff > 1) {
          // Quebrou o streak
          newStreak = 1;
        }
        // Se daysDiff == 0, mesma dia, não incrementa
      } else {
        // Primeira leitura
        newStreak = 1;
      }
      
      // Verificar se é o maior streak
      int longestStreakDays = currentConfig.longestStreakDays;
      DateTime? longestStreakStart = currentConfig.longestStreakStart;
      DateTime? longestStreakEnd = currentConfig.longestStreakEnd;
      
      if (newStreak > longestStreakDays) {
        longestStreakDays = newStreak;
        // Calcular data de início do novo streak
        longestStreakStart = now.subtract(Duration(days: newStreak - 1));
        longestStreakEnd = now;
      }
      
      final updatedConfig = currentConfig.copyWith(
        currentStreak: newStreak,
        lastReadingDate: now,
        longestStreakDays: longestStreakDays,
        longestStreakStart: longestStreakStart,
        longestStreakEnd: longestStreakEnd,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Sessão de leitura registrada: streak=$newStreak dias');
    } catch (e) {
      LoggerService.instance.e('Erro ao registrar sessão de leitura', error: e);
      rethrow;
    }
  }

  Future<void> resetStreak() async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        currentStreak: 0,
        lastReadingDate: null,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Streak resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar streak', error: e);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      await _repository.deleteConfig(userId);
      LoggerService.instance.i('Todos os dados do Reading foram limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar dados do Reading', error: e);
      rethrow;
    }
  }

  /// Verifica se precisa notificar sobre streak
  bool shouldNotifyStreak(ReadingConfig config) {
    if (!config.enableNotifications || !config.enableStreakReminder) {
      return false;
    }
    return true;
  }

  /// Obtém o horário de notificação salvo
  Future<TimeOfDay> getSavedNotificationTime() async {
    final config = await getConfig();
    return config.reminderTime;
  }

  /// Agenda lembrete diário
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    try {
      await updateNotificationSettings(
        enableNotifications: true,
        reminderTime: time,
        enableDailyReminder: true,
      );
      LoggerService.instance.i('Lembrete diário de leitura agendado para ${time.hour}:${time.minute.toString().padLeft(2, '0')}');
    } catch (e) {
      LoggerService.instance.e('Erro ao agendar lembrete diário: $e');
      rethrow;
    }
  }

  /// Cancela lembrete diário
  Future<void> cancelDailyReminder() async {
    try {
      await updateNotificationSettings(
        enableNotifications: true,
        enableDailyReminder: false,
      );
      LoggerService.instance.i('Lembrete diário de leitura cancelado');
    } catch (e) {
      LoggerService.instance.e('Erro ao cancelar lembrete diário: $e');
      rethrow;
    }
  }
}
