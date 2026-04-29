import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de BingeEating usando ObjectBox
class BingeEatingConfigRepository {
  static BingeEatingConfigRepository? _instance;
  static BingeEatingConfigRepository get instance => _instance ??= BingeEatingConfigRepository._internal();
  
  BingeEatingConfigRepository._internal();

  Box<BingeEatingConfigEntity> get _box => ObjectBoxService.instance.store.box<BingeEatingConfigEntity>();

  Future<BingeEatingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return _box.query(BingeEatingConfigEntity_.userId.equals(userId)).build().findFirst();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do BingeEating', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(BingeEatingConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      config.touch();
      _box.put(config);
      LoggerService.instance.i('Configuração do BingeEating salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do BingeEating', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }
      LoggerService.instance.i('Configuração do BingeEating removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do BingeEating', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do BingeEating foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do BingeEating', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(BingeEatingConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'binge_eating',
        'is_module_active': config.isModuleActive,
        'blocked_until': config.blockedUntil?.toIso8601String(),
        'block_reason': config.blockReason,
        'daily_limit_minutes': config.dailyLimitMinutes,
        'require_password': config.requirePassword,
        'trigger_foods': config.triggerFoods,
        'coping_strategies': config.copingStrategies,
        'enable_notifications': config.enableNotifications,
        'reminder_hour': config.reminderHour,
        'reminder_minute': config.reminderMinute,
        'enable_app_lock': config.enableAppLock,
        'monitored_apps': config.monitoredApps,
        'app_lock_require_password': config.appLockRequirePassword,
        'app_lock_message': config.appLockMessage,
        'app_lock_cooldown_minutes': config.appLockCooldownMinutes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração BingeEating sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar BingeEating com Supabase', error: e);
    }
  }

  Future<BingeEatingConfigEntity?> loadFromSupabase() async {
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
          .eq('module_id', 'binge_eating')
          .maybeSingle();

      if (response == null) return null;

      final entity = BingeEatingConfigEntity(userId: userId);
      entity.isModuleActive = response['is_module_active'] ?? false;
      entity.blockedUntil = response['blocked_until'] != null ? DateTime.parse(response['blocked_until']) : null;
      entity.blockReason = response['block_reason'];
      entity.dailyLimitMinutes = response['daily_limit_minutes'] ?? 60;
      entity.requirePassword = response['require_password'] ?? false;
      entity.triggerFoods = (response['trigger_foods'] as List<dynamic>?)?.cast<String>() ?? [];
      entity.copingStrategies = (response['coping_strategies'] as List<dynamic>?)?.cast<String>() ?? [];
      entity.enableNotifications = response['enable_notifications'] ?? true;
      entity.reminderHour = response['reminder_hour'] ?? 20;
      entity.reminderMinute = response['reminder_minute'] ?? 0;
      entity.enableAppLock = response['enable_app_lock'] ?? false;
      entity.monitoredApps = (response['monitored_apps'] as List<dynamic>?)?.cast<String>() ?? [];
      entity.appLockRequirePassword = response['app_lock_require_password'] ?? false;
      entity.appLockMessage = response['app_lock_message'] ?? "Pare! Você está tentando acessar um app durante seu momento de controle alimentar.";
      entity.appLockCooldownMinutes = response['app_lock_cooldown_minutes'] ?? 5;
      entity.createdAt = response['created_at'] != null ? DateTime.parse(response['created_at']) : DateTime.now();
      entity.updatedAt = response['updated_at'] != null ? DateTime.parse(response['updated_at']) : DateTime.now();
      
      return entity;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar BingeEating do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<BingeEatingConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      BingeEatingConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      BingeEatingConfigEntity? localConfig = await getConfig();
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = BingeEatingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa BingeEating', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return BingeEatingConfigEntity(userId: userId);
    }
  }
}
