import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Diet usando ObjectBox
class DietConfigRepository {
  static DietConfigRepository? _instance;
  static DietConfigRepository get instance => _instance ??= DietConfigRepository._internal();
  
  DietConfigRepository._internal();

  Box<DietConfigEntity> get _box => ObjectBoxService.instance.store.box<DietConfigEntity>();

  Future<DietConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return _box.query(DietConfigEntity_.userId.equals(userId)).build().findFirst();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Diet', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(DietConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Diet salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Diet', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }
      LoggerService.instance.i('Configuração do Diet removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Diet', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Diet foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Diet', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(DietConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'diet',
        'is_module_active': true, // Diet sempre ativo se tem config
        'calories': config.calories,
        'proteins': config.proteins,
        'carbs': config.carbs,
        'fats': config.fats,
        'fiber': config.fiber,
        'water': config.water,
        'enable_notifications': config.enableNotifications,
        'reminder_hour': config.reminderHour,
        'reminder_minute': config.reminderMinute,
        'meal_times': config.mealTimes,
        'streak_days': config.streakDays,
        'last_meal_date': config.lastMealDate?.toIso8601String(),
        'total_weight_lost': config.totalWeightLost,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração Diet sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Diet com Supabase', error: e);
    }
  }

  Future<DietConfigEntity?> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado');
        return null;
      }

      final response = await Supabase.instance.client
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', 'diet')
          .maybeSingle();

      if (response == null) return null;

      final entity = DietConfigEntity(userId: userId);
      entity.calories = response['calories'] ?? 2000;
      entity.proteins = response['proteins']?.toDouble() ?? 150.0;
      entity.carbs = response['carbs']?.toDouble() ?? 250.0;
      entity.fats = response['fats']?.toDouble() ?? 65.0;
      entity.fiber = response['fiber']?.toDouble() ?? 25.0;
      entity.water = response['water']?.toDouble() ?? 2000.0;
      entity.enableNotifications = response['enable_notifications'] ?? true;
      entity.reminderHour = response['reminder_hour'] ?? 12;
      entity.reminderMinute = response['reminder_minute'] ?? 0;
      entity.mealTimes = (response['meal_times'] as List<dynamic>?)?.cast<String>() ?? ['08:00', '12:00', '18:00'];
      entity.streakDays = response['streak_days'] ?? 0;
      entity.lastMealDate = response['last_meal_date'] != null ? DateTime.parse(response['last_meal_date']) : null;
      entity.totalWeightLost = response['total_weight_lost']?.toDouble() ?? 0.0;
      entity.createdAt = response['created_at'] != null ? DateTime.parse(response['created_at']) : DateTime.now();
      entity.updatedAt = response['updated_at'] != null ? DateTime.parse(response['updated_at']) : DateTime.now();
      
      return entity;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar Diet do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<DietConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      DietConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      DietConfigEntity? localConfig = await getConfig();
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = DietConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Diet', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return DietConfigEntity(userId: userId);
    }
  }
}
