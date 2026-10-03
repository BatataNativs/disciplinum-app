import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/entities/user_choices_entity.dart';
import 'package:disciplinum/core/storage/repositories/user_choices_repository.dart';

/// Serviço de sincronização local de escolhas do usuário
/// Gerencia persistência local via ObjectBox
class UserChoicesSyncService {
  final UserChoicesRepository _repository;
  
  UserChoicesSyncService(this._repository);

  /// Sincroniza escolhas do usuário localmente
  Future<bool> syncToCloud(String userId) async {
    try {
      final localChoices = await _repository.getByUserId(userId);
      if (localChoices == null) return false;
      await _repository.updateLastSync(userId);
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar escolhas para userId: $userId', error: e);
      return false;
    }
  }

  /// Busca escolhas do usuário localmente
  Future<UserChoicesEntity?> fetchFromCloud(String userId) async {
    return await _repository.getByUserId(userId);
  }

  /// Sincroniza dados localmente
  Future<bool> syncFromCloud(String userId) async {
    return true;
  }

  /// Sincronização local
  Future<bool> fullSync(String userId) async {
    return true;
  }

  /// Atualiza campo específico
  Future<bool> updateField(String userId, String field, dynamic value) async {
    try {
      final fields = {field: value};
      return await _repository.updateFields(userId, fields);
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar campo $field para userId: $userId', error: e);
      return false;
    }
  }

  /// Atualiza visibilidade de módulo específico
  Future<bool> updateModuleVisibility(String userId, String moduleId, bool isVisible) async {
    try {
      return await _repository.updateModuleVisibility(userId, moduleId, isVisible);
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar visibilidade do módulo $moduleId para userId: $userId', error: e);
      return false;
    }
  }

  /// Obtém estatísticas de sincronização
  Future<Map<String, dynamic>> getSyncStats(String userId) async {
    try {
      final localChoices = await _repository.getByUserId(userId);
      final stats = await _repository.getStats();
      
      return {
        'userId': userId,
        'hasLocal': localChoices != null,
        'hasCloud': false,
        'lastLocalSync': localChoices?.lastSyncAt?.toIso8601String(),
        'localUpdatedAt': localChoices?.updatedAt.toIso8601String(),
        'needsSync': false,
        'repositoryStats': stats,
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas de escolhas', error: e);
      return {
        'userId': userId,
        'error': e.toString(),
      };
    }
  }

  /// Limpa dados do usuário localmente
  Future<bool> clearUserData(String userId) async {
    try {
      return await _repository.deleteByUserId(userId);
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar dados do usuário $userId', error: e);
      return false;
    }
  }
}
