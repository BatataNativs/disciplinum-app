import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Money Saving usando ObjectBox
/// Com sincronização para Supabase (cloud)
class MoneySavingConfigRepository {
  static MoneySavingConfigRepository? _instance;
  static MoneySavingConfigRepository get instance => _instance ??= MoneySavingConfigRepository._internal();
  
  MoneySavingConfigRepository._internal();

  Box<MoneySavingConfigEntity> get _box => ObjectBoxService.instance.store.box<MoneySavingConfigEntity>();

  Future<MoneySavingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final query = _box.query(MoneySavingConfigEntity_.userId.equals(userId)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Money Saving', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(MoneySavingConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Money Saving salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Money Saving', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
         _box.remove(existingConfig.id);
      }
      
      LoggerService.instance.i('Configuração do Money Saving removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Money Saving', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Money Saving foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Money Saving', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setModuleActive(String userId, bool isActive, {String? challengeId}) async {
    try {
      final config = await getConfig();
      if (config != null) {
        final updatedConfig = config.copyWith(
          isModuleActive: isActive,
          activeChallengeId: challengeId ?? config.activeChallengeId,
        );
        await saveConfig(updatedConfig);
      } else {
        final newConfig = MoneySavingConfigEntity(
          userId: userId,
          isModuleActive: isActive,
          activeChallengeId: challengeId,
        );
        await saveConfig(newConfig);
      }
      LoggerService.instance.i('Estado do módulo Money Saving atualizado: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado do módulo Money Saving', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado do módulo Money Saving', error: e);
      return false;
    }
  }

  Future<String?> getActiveChallengeId() async {
    try {
      final config = await getConfig();
      return config?.activeChallengeId;
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar challenge ativo', error: e);
      return null;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(MoneySavingConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'money_saving',
        'is_module_active': config.isModuleActive,
        'active_challenge_id': config.activeChallengeId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração Money Saving sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Money Saving com Supabase', error: e);
    }
  }

  Future<MoneySavingConfigEntity?> loadFromSupabase() async {
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
          .eq('module_id', 'money_saving')
          .maybeSingle();

      if (response == null) return null;

      return MoneySavingConfigEntity(
        userId: userId,
        isModuleActive: response['is_module_active'] ?? false,
        activeChallengeId: response['active_challenge_id'],
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar Money Saving do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<MoneySavingConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      MoneySavingConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      MoneySavingConfigEntity? localConfig = await getConfig();
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = MoneySavingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Money Saving', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return MoneySavingConfigEntity(userId: userId);
    }
  }
}
