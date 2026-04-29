import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Focus usando ObjectBox
class FocusConfigRepository {
  static FocusConfigRepository? _instance;
  static FocusConfigRepository get instance => _instance ??= FocusConfigRepository._internal();
  
  FocusConfigRepository._internal();

  Box<FocusConfigEntity> get _box => ObjectBoxService.instance.store.box<FocusConfigEntity>();

  Future<FocusConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return _box.query(FocusConfigEntity_.userId.equals(userId)).build().findFirst();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Focus', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(FocusConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Focus salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Focus', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }
      LoggerService.instance.i('Configuração do Focus removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Focus', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Focus foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Focus', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(FocusConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'focus',
        'is_module_active': config.isModuleActive,
        'enable_notifications': config.enableNotifications,
        'daily_goal_minutes': config.dailyGoalMinutes,
        'reminder_hour': config.reminderHour,
        'reminder_minute': config.reminderMinute,
        'streak_days': config.streakDays,
        'last_focus_date': config.lastFocusDate?.toIso8601String(),
        'total_focus_minutes': config.totalFocusMinutes,
        'longest_focus_session': config.longestFocusSession,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração Focus sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Focus com Supabase', error: e);
    }
  }

  Future<FocusConfigEntity?> loadFromSupabase() async {
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
          .eq('module_id', 'focus')
          .maybeSingle();

      if (response == null) return null;

      final entity = FocusConfigEntity(userId: userId);
      entity.isModuleActive = response['is_module_active'] ?? false;
      entity.enableNotifications = response['enable_notifications'] ?? true;
      entity.dailyGoalMinutes = response['daily_goal_minutes'] ?? 120;
      entity.reminderHour = response['reminder_hour'] ?? 9;
      entity.reminderMinute = response['reminder_minute'] ?? 0;
      entity.streakDays = response['streak_days'] ?? 0;
      entity.lastFocusDate = response['last_focus_date'] != null ? DateTime.parse(response['last_focus_date']) : null;
      entity.totalFocusMinutes = response['total_focus_minutes'] ?? 0;
      entity.longestFocusSession = response['longest_focus_session'] ?? 0;
      entity.createdAt = response['created_at'] != null ? DateTime.parse(response['created_at']) : DateTime.now();
      entity.updatedAt = response['updated_at'] != null ? DateTime.parse(response['updated_at']) : DateTime.now();
      
      return entity;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar Focus do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<FocusConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      FocusConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      FocusConfigEntity? localConfig = await getConfig();
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = FocusConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Focus', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return FocusConfigEntity(userId: userId);
    }
  }
}
