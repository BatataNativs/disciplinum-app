import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/diet/data/repositories/diet_config_repository.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_config_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Metas nutricionais diárias
class DailyNutritionGoals {
  final int calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double fiber;
  final double water; // ml

  const DailyNutritionGoals({
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.fiber = 25.0,
    this.water = 2000.0,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'fats': fats,
        'fiber': fiber,
        'water': water,
      };

  factory DailyNutritionGoals.fromJson(Map<String, dynamic> json) => DailyNutritionGoals(
        calories: json['calories'] ?? 2000,
        proteins: (json['proteins'] ?? 150.0).toDouble(),
        carbs: (json['carbs'] ?? 250.0).toDouble(),
        fats: (json['fats'] ?? 65.0).toDouble(),
        fiber: (json['fiber'] ?? 25.0).toDouble(),
        water: (json['water'] ?? 2000.0).toDouble(),
      );

  DailyNutritionGoals copyWith({
    int? calories,
    double? proteins,
    double? carbs,
    double? fats,
    double? fiber,
    double? water,
  }) {
    return DailyNutritionGoals(
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      water: water ?? this.water,
    );
  }
}

/// Configurações do Diet
class DietConfig {
  final DailyNutritionGoals goals;
  final bool enableNotifications;
  final TimeOfDay reminderTime;
  final int streakDays;
  final DateTime? lastMealDate;
  final double totalWeightLost; // kg

  const DietConfig({
    required this.goals,
    this.enableNotifications = true,
    this.reminderTime = const TimeOfDay(hour: 12, minute: 0),
    this.streakDays = 0,
    this.lastMealDate,
    this.totalWeightLost = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'goals': goals.toJson(),
        'enableNotifications': enableNotifications,
        'reminderHour': reminderTime.hour,
        'reminderMinute': reminderTime.minute,
        'streakDays': streakDays,
        'lastMealDate': lastMealDate?.toIso8601String(),
        'totalWeightLost': totalWeightLost,
      };

  factory DietConfig.fromJson(Map<String, dynamic> json) => DietConfig(
        goals: DailyNutritionGoals.fromJson(json['goals'] ?? {}),
        enableNotifications: json['enableNotifications'] ?? true,
        reminderTime: TimeOfDay(
          hour: json['reminderHour'] ?? 12,
          minute: json['reminderMinute'] ?? 0,
        ),
        streakDays: json['streakDays'] ?? 0,
        lastMealDate: json['lastMealDate'] != null ? DateTime.parse(json['lastMealDate']) : null,
        totalWeightLost: (json['totalWeightLost'] ?? 0.0).toDouble(),
      );

  DietConfig copyWith({
    DailyNutritionGoals? goals,
    bool? enableNotifications,
    TimeOfDay? reminderTime,
    int? streakDays,
    DateTime? lastMealDate,
    double? totalWeightLost,
  }) {
    return DietConfig(
      goals: goals ?? this.goals,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
      streakDays: streakDays ?? this.streakDays,
      lastMealDate: lastMealDate ?? this.lastMealDate,
      totalWeightLost: totalWeightLost ?? this.totalWeightLost,
    );
  }
}

/// Service para Diet usando Isar puro (sem IsarPreferencesRepository)
class DietServiceIsar {
  static DietServiceIsar? _instance;
  static DietServiceIsar get instance => _instance ??= DietServiceIsar._internal();
  
  DietServiceIsar._internal();

  final DietConfigRepository _repository = DietConfigRepository.instance;

  Future<DietConfig> getConfig() async {
    try {
      final entity = await _repository.getConfig();
      
      if (entity == null) {
        // Configuração padrão
        final defaultConfig = DietConfig(
          goals: const DailyNutritionGoals(
            calories: 2000,
            proteins: 150.0,
            carbs: 250.0,
            fats: 65.0,
          ),
          enableNotifications: true,
        );
        
        await saveConfig(defaultConfig);
        return defaultConfig;
      }
      
      return DietConfig(
        goals: DailyNutritionGoals(
          calories: entity.calories,
          proteins: entity.proteins,
          carbs: entity.carbs,
          fats: entity.fats,
          fiber: entity.fiber,
          water: entity.water,
        ),
        enableNotifications: entity.enableNotifications,
        reminderTime: TimeOfDay(
          hour: entity.reminderHour,
          minute: entity.reminderMinute,
        ),
        streakDays: entity.streakDays,
        lastMealDate: entity.lastMealDate,
        totalWeightLost: entity.totalWeightLost,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Diet', error: e);
      rethrow;
    }
  }

  Future<void> saveConfig(DietConfig config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      final entity = DietConfigEntity(
        userId: userId,
      );
      
      entity.calories = config.goals.calories;
      entity.proteins = config.goals.proteins;
      entity.carbs = config.goals.carbs;
      entity.fats = config.goals.fats;
      entity.fiber = config.goals.fiber;
      entity.water = config.goals.water;
      entity.enableNotifications = config.enableNotifications;
      entity.reminderHour = config.reminderTime.hour;
      entity.reminderMinute = config.reminderTime.minute;
      entity.streakDays = config.streakDays;
      entity.lastMealDate = config.lastMealDate;
      entity.totalWeightLost = config.totalWeightLost;
      
      await _repository.saveConfig(entity);
      
      LoggerService.instance.i('Configuração do Diet salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Diet', error: e);
      rethrow;
    }
  }

  Future<void> updateGoals(DailyNutritionGoals goals) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        goals: goals,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Metas nutricionais atualizadas');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar metas nutricionais', error: e);
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

  Future<void> incrementStreak() async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        streakDays: currentConfig.streakDays + 1,
        lastMealDate: DateTime.now(),
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
        lastMealDate: null,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Streak resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar streak', error: e);
      rethrow;
    }
  }

  Future<void> addWeightLost(double weightKg) async {
    try {
      final currentConfig = await getConfig();
      
      final updatedConfig = currentConfig.copyWith(
        totalWeightLost: currentConfig.totalWeightLost + weightKg,
      );
      
      await saveConfig(updatedConfig);
      
      LoggerService.instance.i('Peso perdido registrado: +${weightKg}kg (total: ${updatedConfig.totalWeightLost}kg)');
    } catch (e) {
      LoggerService.instance.e('Erro ao registrar peso perdido', error: e);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _repository.clearAll();
      LoggerService.instance.i('Todos os dados do Diet foram limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar dados do Diet', error: e);
      rethrow;
    }
  }
}
