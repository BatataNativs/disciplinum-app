import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório específico para configurações de Adult Content usando ObjectBox
class AdultContentConfigRepository {
  static AdultContentConfigRepository? _instance;
  static AdultContentConfigRepository get instance => _instance ??= AdultContentConfigRepository._internal();
  
  AdultContentConfigRepository._internal();

  Box<AdultContentConfigEntity> get _box => ObjectBoxService.instance.store.box<AdultContentConfigEntity>();

  Future<AdultContentConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return _box.query(AdultContentConfigEntity_.userId.equals(userId)).build().findFirst();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Adult Content', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(AdultContentConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Adult Content salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Adult Content', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }
      
      LoggerService.instance.i('Configuração do Adult Content removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Adult Content', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Adult Content foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Adult Content', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(AdultContentConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'adult_content',
        'is_module_active': config.isModuleActive,
        'blocked_until': config.blockedUntil?.toIso8601String(),
        'block_reason': config.blockReason,
        'daily_limit_minutes': config.dailyLimitMinutes,
        'require_password': config.requirePassword,
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

      LoggerService.instance.i('Configuração Adult Content sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Adult Content com Supabase', error: e);
    }
  }

  Future<AdultContentConfigEntity?> loadFromSupabase() async {
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
          .eq('module_id', 'adult_content')
          .maybeSingle();

      if (response == null) return null;

      final entity = AdultContentConfigEntity(userId: userId);
      entity.isModuleActive = response['is_module_active'] ?? false;
      entity.blockedUntil = response['blocked_until'] != null ? DateTime.parse(response['blocked_until']) : null;
      entity.blockReason = response['block_reason'];
      entity.dailyLimitMinutes = response['daily_limit_minutes'] ?? 60;
      entity.requirePassword = response['require_password'] ?? false;
      entity.enableAppLock = response['enable_app_lock'] ?? false;
      entity.monitoredApps = (response['monitored_apps'] as List<dynamic>?)?.cast<String>() ?? [];
      entity.appLockRequirePassword = response['app_lock_require_password'] ?? false;
      entity.appLockMessage = response['app_lock_message'] ?? "Pare! Você está tentando acessar conteúdo adulto durante seu período de controle.";
      entity.appLockCooldownMinutes = response['app_lock_cooldown_minutes'] ?? 10;
      entity.createdAt = response['created_at'] != null ? DateTime.parse(response['created_at']) : DateTime.now();
      entity.updatedAt = response['updated_at'] != null ? DateTime.parse(response['updated_at']) : DateTime.now();
      
      return entity;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar Adult Content do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<AdultContentConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      AdultContentConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      AdultContentConfigEntity? localConfig = await getConfig();
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = AdultContentConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Adult Content', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return AdultContentConfigEntity(userId: userId);
    }
  }
}
