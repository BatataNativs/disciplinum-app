import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/entities/user_choices_entity.dart';
import 'package:disciplinum/core/storage/repositories/user_choices_repository.dart';

/// Serviço de sincronização de escolhas do usuário
/// Gerencia persistência dual: local (ObjectBox) + cloud (Supabase)
class UserChoicesSyncService {
  final SupabaseClient _supabase;
  final UserChoicesRepository _repository;
  
  UserChoicesSyncService(this._supabase, this._repository);

  /// Sincroniza escolhas do usuário com a nuvem
  Future<bool> syncToCloud(String userId) async {
    try {
      LoggerService.instance.i('🔐 Iniciando sincronização para userId: $userId');
      
      // Obtém dados locais
      final localChoices = await _repository.getByUserId(userId);
      if (localChoices == null) {
        LoggerService.instance.w('🔐 Nenhum dado local encontrado para userId: $userId');
        return false;
      }

      // Converte para formato da nuvem
      final cloudData = localChoices.toCloudMap();
      
      // Sincroniza com Supabase
      try {
        final response = await _supabase
            .from('user_choices')
            .upsert(cloudData)
            .eq('user_id', userId)
            .select();
        
        // Se chegou aqui, não houve erro
        LoggerService.instance.d('🔐 Dados sincronizados com Supabase: $response');
      } catch (e) {
        LoggerService.instance.e('🔐 Erro ao sincronizar com Supabase', error: e);
        return false;
      }

      // Atualiza timestamp de sincronização local
      await _repository.updateLastSync(userId);
      
      LoggerService.instance.i('🔐 Sincronização concluída com sucesso para userId: $userId');
      return true;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro na sincronização para userId: $userId', error: e);
      return false;
    }
  }

  /// Busca escolhas do usuário na nuvem
  Future<UserChoicesEntity?> fetchFromCloud(String userId) async {
    try {
      LoggerService.instance.d('🔐 Buscando escolhas na nuvem para userId: $userId');
      
      final response = await _supabase
          .from('user_choices')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        LoggerService.instance.d('🔐 Nenhum dado encontrado na nuvem para userId: $userId');
        return null;
      }

      final cloudChoices = UserChoicesEntity.fromCloudMap(response);
      LoggerService.instance.d('🔐 Dados obtidos da nuvem: ${cloudChoices.toString()}');
      
      return cloudChoices;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao buscar da nuvem para userId: $userId', error: e);
      return null;
    }
  }

  /// Sincroniza dados da nuvem para o local
  Future<bool> syncFromCloud(String userId) async {
    try {
      LoggerService.instance.i('🔐 Sincronizando da nuvem para local: userId: $userId');
      
      final cloudChoices = await fetchFromCloud(userId);
      if (cloudChoices == null) {
        LoggerService.instance.w('🔐 Nenhum dado encontrado na nuvem para userId: $userId');
        return false;
      }

      // Salva localmente
      final success = await _repository.save(cloudChoices);
      if (success) {
        LoggerService.instance.i('🔐 Sincronização nuvem→local concluída para userId: $userId');
      } else {
        LoggerService.instance.e('🔐 Erro ao salvar localmente durante sincronização');
      }
      
      return success;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro na sincronização nuvem→local para userId: $userId', error: e);
      return false;
    }
  }

  /// Sincronização bidirecional inteligente
  Future<bool> fullSync(String userId) async {
    try {
      LoggerService.instance.i('🔐 Iniciando sincronização completa para userId: $userId');
      
      // Obtém dados locais e da nuvem
      final localChoices = await _repository.getByUserId(userId);
      final cloudChoices = await fetchFromCloud(userId);
      
      if (localChoices == null && cloudChoices == null) {
        LoggerService.instance.w('🔐 Nenhum dado encontrado local nem na nuvem para userId: $userId');
        return true; // Nada a sincronizar
      }

      if (localChoices == null) {
        // Apenas nuvem tem dados, baixa para local
        LoggerService.instance.d('🔐 Nuvem mais recente, baixando para local');
        return await syncFromCloud(userId);
      }

      if (cloudChoices == null) {
        // Apenas local tem dados, sobe para nuvem
        LoggerService.instance.d('🔐 Local mais recente, subindo para nuvem');
        return await syncToCloud(userId);
      }

      // Compara timestamps para decidir qual é mais recente
      final localTime = localChoices.updatedAt;
      final cloudTime = cloudChoices.updatedAt;
      
      if (cloudTime.isAfter(localTime)) {
        // Nuvem é mais recente, baixa para local
        LoggerService.instance.d('🔐 Nuvem mais recente, baixando para local');
        return await syncFromCloud(userId);
      } else if (localTime.isAfter(cloudTime)) {
        // Local é mais recente, sobe para nuvem
        LoggerService.instance.d('🔐 Local mais recente, subindo para nuvem');
        return await syncToCloud(userId);
      } else {
        LoggerService.instance.d('🔐 Dados já sincronizados, mesma versão');
        return true;
      }
    } catch (e) {
      LoggerService.instance.e('🔐 Erro na sincronização completa para userId: $userId', error: e);
      return false;
    }
  }

  /// Atualiza campo específico e sincroniza
  Future<bool> updateField(String userId, String field, dynamic value) async {
    try {
      LoggerService.instance.d('🔐 Atualizando campo $field para userId: $userId');
      
      // Atualiza localmente primeiro
      final fields = {field: value};
      final localSuccess = await _repository.updateFields(userId, fields);
      
      if (!localSuccess) {
        LoggerService.instance.e('🔐 Erro ao atualizar campo localmente');
        return false;
      }

      // Sincroniza com a nuvem
      final syncSuccess = await syncToCloud(userId);
      
      if (syncSuccess) {
        LoggerService.instance.i('🔐 Campo $field atualizado e sincronizado com sucesso');
      } else {
        LoggerService.instance.w('🔐 Campo atualizado localmente mas falha na sincronização');
      }
      
      return syncSuccess;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao atualizar campo $field para userId: $userId', error: e);
      return false;
    }
  }

  /// Atualiza visibilidade de módulo específico
  Future<bool> updateModuleVisibility(String userId, String moduleId, bool isVisible) async {
    try {
      LoggerService.instance.d('🔐 Atualizando visibilidade do módulo $moduleId: $isVisible para userId: $userId');
      
      // Atualiza localmente
      final localSuccess = await _repository.updateModuleVisibility(userId, moduleId, isVisible);
      
      if (!localSuccess) {
        LoggerService.instance.e('🔐 Erro ao atualizar visibilidade localmente');
        return false;
      }

      // Sincroniza com a nuvem
      final syncSuccess = await syncToCloud(userId);
      
      if (syncSuccess) {
        LoggerService.instance.i('🔐 Visibilidade do módulo $moduleId atualizada e sincronizada');
      } else {
        LoggerService.instance.w('🔐 Visibilidade atualizada localmente mas falha na sincronização');
      }
      
      return syncSuccess;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao atualizar visibilidade do módulo $moduleId para userId: $userId', error: e);
      return false;
    }
  }

  /// Obtém estatísticas de sincronização
  Future<Map<String, dynamic>> getSyncStats(String userId) async {
    try {
      final localChoices = await _repository.getByUserId(userId);
      final cloudChoices = await fetchFromCloud(userId);
      final stats = await _repository.getStats();
      
      return {
        'userId': userId,
        'hasLocal': localChoices != null,
        'hasCloud': cloudChoices != null,
        'lastLocalSync': localChoices?.lastSyncAt?.toIso8601String(),
        'localUpdatedAt': localChoices?.updatedAt.toIso8601String(),
        'cloudUpdatedAt': cloudChoices?.updatedAt.toIso8601String(),
        'needsSync': _needsSync(localChoices, cloudChoices),
        'repositoryStats': stats,
      };
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao obter estatísticas de sincronização', error: e);
      return {
        'userId': userId,
        'error': e.toString(),
      };
    }
  }

  /// Verifica se há necessidade de sincronização
  bool _needsSync(UserChoicesEntity? local, UserChoicesEntity? cloud) {
    if (local == null || cloud == null) return true;
    
    // Se a diferença for maior que 5 minutos, precisa sincronizar
    final diff = local.updatedAt.difference(cloud.updatedAt).inMinutes;
    return diff > 5;
  }

  /// Limpa dados do usuário (local e nuvem)
  Future<bool> clearUserData(String userId) async {
    try {
      LoggerService.instance.i('🔐 Limpando dados do usuário: $userId');
      
      // Remove localmente
      final localSuccess = await _repository.deleteByUserId(userId);
      
      // Remove da nuvem
      try {
        await _supabase
            .from('user_choices')
            .delete()
            .eq('user_id', userId);
        
        LoggerService.instance.i('🔐 Dados removidos da nuvem com sucesso');
      } catch (e) {
        LoggerService.instance.e('🔐 Erro ao remover da nuvem', error: e);
        return false;
      }

      LoggerService.instance.i('🔐 Dados do usuário $userId limpos com sucesso');
      return localSuccess;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao limpar dados do usuário $userId', error: e);
      return false;
    }
  }
}
