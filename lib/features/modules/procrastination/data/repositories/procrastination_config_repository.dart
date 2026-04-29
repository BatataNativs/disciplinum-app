import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Procrastination usando ObjectBox
class ProcrastinationConfigRepository {
  static ProcrastinationConfigRepository? _instance;
  static ProcrastinationConfigRepository get instance => _instance ??= ProcrastinationConfigRepository._internal();
  
  ProcrastinationConfigRepository._internal();

  Box<ProcrastinationConfigEntity> get _box => ObjectBoxService.instance.store.box<ProcrastinationConfigEntity>();

  Future<ProcrastinationConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final query = _box.query(ProcrastinationConfigEntity_.userId.equals(userId)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Procrastination', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(ProcrastinationConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Procrastination salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
         _box.remove(existingConfig.id);
      }
      
      LoggerService.instance.i('Configuração do Procrastination removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Procrastination foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(ProcrastinationConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'procrastination',
        'is_module_active': config.isModuleActive,
        'daily_focus_minutes': config.dailyFocusMinutes,
        'enable_notifications': config.enableNotifications,
        'reminder_hour': config.reminderHour,
        'reminder_minute': config.reminderMinute,
        'streak_days': config.streakDays,
        'last_focus_date': config.lastFocusDate?.toIso8601String(),
        'total_focus_minutes': config.totalFocusMinutes,
        'longest_focus_session': config.longestFocusSession,
        'enable_app_blocking': config.enableAppBlocking,
        'blocked_apps': config.blockedApps,
        'block_duration_minutes': config.blockDurationMinutes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração Procrastination sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Procrastination com Supabase', error: e);
    }
  }

  Future<ProcrastinationConfigEntity?> loadFromSupabase() async {
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
          .eq('module_id', 'procrastination')
          .maybeSingle();

      if (response == null) return null;

      final entity = ProcrastinationConfigEntity(userId: userId);
      entity.isModuleActive = response['is_module_active'] ?? false;
      entity.dailyFocusMinutes = response['daily_focus_minutes'] ?? 120;
      entity.enableNotifications = response['enable_notifications'] ?? true;
      entity.reminderHour = response['reminder_hour'] ?? 9;
      entity.reminderMinute = response['reminder_minute'] ?? 0;
      entity.streakDays = response['streak_days'] ?? 0;
      entity.lastFocusDate = response['last_focus_date'] != null ? DateTime.parse(response['last_focus_date']) : null;
      entity.totalFocusMinutes = response['total_focus_minutes'] ?? 0;
      entity.longestFocusSession = response['longest_focus_session'] ?? 0;
      entity.enableAppBlocking = response['enable_app_blocking'] ?? false;
      entity.blockedApps = (response['blocked_apps'] as List<dynamic>?)?.cast<String>() ?? [];
      entity.blockDurationMinutes = response['block_duration_minutes'] ?? 30;
      entity.createdAt = response['created_at'] != null ? DateTime.parse(response['created_at']) : DateTime.now();
      entity.updatedAt = response['updated_at'] != null ? DateTime.parse(response['updated_at']) : DateTime.now();
      
      return entity;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar Procrastination do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<ProcrastinationConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      ProcrastinationConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      ProcrastinationConfigEntity? localConfig = await getConfig();
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = ProcrastinationConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Procrastination', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return ProcrastinationConfigEntity(userId: userId);
    }
  }
}
