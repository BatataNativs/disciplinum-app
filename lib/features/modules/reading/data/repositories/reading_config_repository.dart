import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Reading usando ObjectBox
class ReadingConfigRepository {
  static ReadingConfigRepository? _instance;
  static ReadingConfigRepository get instance => _instance ??= ReadingConfigRepository._internal();
  
  ReadingConfigRepository._internal();

  Box<ReadingConfigEntity> get _box => ObjectBoxService.instance.store.box<ReadingConfigEntity>();

  Future<ReadingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      return _box.query(ReadingConfigEntity_.userId.equals(userId)).build().findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Reading', error: e);
      return null;
    }
  }

  Future<void> saveConfig(ReadingConfigEntity config) async {
    try {
      // Verificar se já existe uma configuração com o mesmo userId
      final existingConfig = _box.query(ReadingConfigEntity_.userId.equals(config.userId)).build().findFirst();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      _box.put(config);
      LoggerService.instance.i('Configuração do Reading salva');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Reading', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig(String userId) async {
    try {
      final existing = _box.query(ReadingConfigEntity_.userId.equals(userId)).build().findFirst();
      if (existing != null) {
        _box.remove(existing.id);
        LoggerService.instance.i('Configuração do Reading deletada');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao deletar configuração do Reading', error: e);
      rethrow;
    }
  }

  Future<List<ReadingConfigEntity>> getAllConfigs() async {
    try {
      return _box.getAll();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar todas as configurações do Reading', error: e);
      return [];
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getConfig();
      if (config != null) {
        final updatedConfig = config.copyWith(isModuleActive: isActive);
        await saveConfig(updatedConfig);
      } else {
        final newConfig = ReadingConfigEntity(userId: userId, isModuleActive: isActive);
        await saveConfig(newConfig);
      }
      LoggerService.instance.i('Estado do módulo Reading atualizado: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado do módulo Reading', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado do módulo Reading', error: e);
      return false;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(ReadingConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'reading',
        'is_module_active': config.isModuleActive,
        'enable_notifications': config.enableNotifications,
        'reminder_hour': config.reminderHour,
        'reminder_minute': config.reminderMinute,
        'enable_daily_reminder': config.enableDailyReminder,
        'enable_streak_reminder': config.enableStreakReminder,
        'current_streak': config.currentStreak,
        'last_reading_date': config.lastReadingDate?.toIso8601String(),
        'longest_streak_start': config.longestStreakStart?.toIso8601String(),
        'longest_streak_end': config.longestStreakEnd?.toIso8601String(),
        'longest_streak_days': config.longestStreakDays,
        'daily_pages_goal': config.dailyPagesGoal,
        'weekly_books_goal': config.weeklyBooksGoal,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração Reading sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Reading com Supabase', error: e);
    }
  }

  Future<ReadingConfigEntity?> loadFromSupabase() async {
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
          .eq('module_id', 'reading')
          .maybeSingle();

      if (response == null) return null;

      final entity = ReadingConfigEntity(
        userId: userId,
        isModuleActive: response['is_module_active'] ?? false,
      );
      
      // Preencher campos adicionais
      entity.enableNotifications = response['enable_notifications'] ?? true;
      entity.reminderHour = response['reminder_hour'] ?? 20;
      entity.reminderMinute = response['reminder_minute'] ?? 0;
      entity.enableDailyReminder = response['enable_daily_reminder'] ?? true;
      entity.enableStreakReminder = response['enable_streak_reminder'] ?? true;
      entity.currentStreak = response['current_streak'] ?? 0;
      entity.lastReadingDate = response['last_reading_date'] != null ? DateTime.parse(response['last_reading_date']) : null;
      entity.longestStreakStart = response['longest_streak_start'] != null ? DateTime.parse(response['longest_streak_start']) : null;
      entity.longestStreakEnd = response['longest_streak_end'] != null ? DateTime.parse(response['longest_streak_end']) : null;
      entity.longestStreakDays = response['longest_streak_days'] ?? 0;
      entity.dailyPagesGoal = response['daily_pages_goal'] ?? 20;
      entity.weeklyBooksGoal = response['weekly_books_goal'] ?? 1;
      entity.createdAt = response['created_at'] != null ? DateTime.parse(response['created_at']) : DateTime.now();
      entity.updatedAt = response['updated_at'] != null ? DateTime.parse(response['updated_at']) : DateTime.now();
      
      return entity;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar Reading do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<ReadingConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      ReadingConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      ReadingConfigEntity? localConfig = await getConfig();
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = ReadingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Reading', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return ReadingConfigEntity(userId: userId);
    }
  }
}
