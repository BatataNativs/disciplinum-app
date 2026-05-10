import 'dart:async';
import 'package:disciplinum/core/storage/entities/user_choices_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório para gerenciar escolhas do usuário com ObjectBox
/// Persistência local rápida e confiável
class UserChoicesRepository {
  late final Store _store;
  late final Box<UserChoicesEntity> _box;
  
  UserChoicesRepository(this._store) {
    _box = Box<UserChoicesEntity>(_store);
  }

  /// Obtém as escolhas do usuário pelo ID
  Future<UserChoicesEntity?> getByUserId(String userId) async {
    try {
      final query = _box.query(UserChoicesEntity_.userId.equals(userId)).build();
      final result = query.findFirst();
      query.close();
      
      LoggerService.instance.d('🔐 UserChoices obtido para userId: $userId, encontrado: ${result != null}');
      return result;
    } catch (e) {
      LoggerService.instance.e('Erro ao obter UserChoices para userId: $userId', error: e);
      return null;
    }
  }

  /// Salva ou atualiza as escolhas do usuário
  Future<bool> save(UserChoicesEntity choices) async {
    try {
      final existing = await getByUserId(choices.userId);
      
      if (existing != null) {
        // Atualiza registro existente
        choices.id = existing.id;
        await _box.putAsync(choices);
        LoggerService.instance.i('🔐 UserChoices atualizado para userId: ${choices.userId}');
      } else {
        // Cria novo registro
        await _box.putAsync(choices);
        LoggerService.instance.i('🔐 UserChoices criado para userId: ${choices.userId}');
      }
      
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar UserChoices para userId: ${choices.userId}', error: e);
      return false;
    }
  }

  /// Atualiza campos específicos das escolhas do usuário
  Future<bool> updateFields(String userId, Map<String, dynamic> fields) async {
    try {
      final existing = await getByUserId(userId);
      if (existing == null) {
        LoggerService.instance.w('🔐 UserChoices não encontrado para userId: $userId, criando novo');
        final newChoices = UserChoicesEntity(userId: userId);
        return await save(newChoices.copyWith(
          showEmail: fields['show_email'],
          showAvatar: fields['show_avatar'],
          theme: fields['theme'],
          notificationsEnabled: fields['notifications_enabled'],
          notificationTime: fields['notification_time'],
          language: fields['language'],
          moduleVisibility: fields['module_visibility'] as Map<String, bool>?,
        ));
      }

      // Atualiza apenas os campos fornecidos
      final updated = existing.copyWith(
        showEmail: fields['show_email'],
        showAvatar: fields['show_avatar'],
        theme: fields['theme'],
        notificationsEnabled: fields['notifications_enabled'],
        notificationTime: fields['notification_time'],
        language: fields['language'],
        moduleVisibility: fields['module_visibility'] as Map<String, bool>?,
        lastSyncAt: fields['last_sync_at'] != null 
            ? DateTime.tryParse(fields['last_sync_at']) 
            : null,
      );

      return await save(updated);
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar campos do UserChoices para userId: $userId', error: e);
      return false;
    }
  }

  /// Atualiza visibilidade de módulos específicos
  Future<bool> updateModuleVisibility(String userId, String moduleId, bool isVisible) async {
    try {
      final existing = await getByUserId(userId);
      if (existing == null) {
        LoggerService.instance.w('🔐 UserChoices não encontrado para userId: $userId, criando novo');
        final newChoices = UserChoicesEntity(
          userId: userId,
        );
        newChoices.moduleVisibility = {moduleId: isVisible};
        return await save(newChoices);
      }

      final updatedVisibility = Map<String, bool>.from(existing.moduleVisibility);
      updatedVisibility[moduleId] = isVisible;

      final updated = existing.copyWith(
        moduleVisibility: updatedVisibility,
      );

      return await save(updated);
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar visibilidade do módulo $moduleId para userId: $userId', error: e);
      return false;
    }
  }

  /// Obtém visibilidade de um módulo específico
  Future<bool> getModuleVisibility(String userId, String moduleId) async {
    try {
      final choices = await getByUserId(userId);
      return choices?.moduleVisibility[moduleId] ?? true; // Default: visível
    } catch (e) {
      LoggerService.instance.e('Erro ao obter visibilidade do módulo $moduleId para userId: $userId', error: e);
      return true; // Default: visível
    }
  }

  /// Lista todos os usuários com escolhas salvas
  Future<List<UserChoicesEntity>> getAll() async {
    try {
      final result = await _box.getAllAsync();
      LoggerService.instance.d('🔐 UserChoices.getAll(): ${result.length} registros encontrados');
      return result;
    } catch (e) {
      LoggerService.instance.e('Erro ao listar todos os UserChoices', error: e);
      return [];
    }
  }

  /// Remove as escolhas de um usuário
  Future<bool> deleteByUserId(String userId) async {
    try {
      final query = _box.query(UserChoicesEntity_.userId.equals(userId)).build();
      final result = await query.removeAsync();
      query.close();
      
      LoggerService.instance.i('🔐 UserChoices removido para userId: $userId, registros: $result');
      return result > 0;
    } catch (e) {
      LoggerService.instance.e('Erro ao remover UserChoices para userId: $userId', error: e);
      return false;
    }
  }

  /// Limpa todas as escolhas (para reset/debug)
  Future<bool> clearAll() async {
    try {
      await _box.removeAllAsync();
      LoggerService.instance.w('🔐 Todos os UserChoices foram removidos');
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar todos os UserChoices', error: e);
      return false;
    }
  }

  /// Verifica se há dados pendentes de sincronização
  Future<List<UserChoicesEntity>> getPendingSync() async {
    try {
      final query = _box.query(
        UserChoicesEntity_.lastSyncAt.isNull().or(
          UserChoicesEntity_.lastSyncAt.lessThan(
            DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch
          )
        )
      ).build();
      
      final result = await query.findAsync();
      query.close();
      
      LoggerService.instance.d('🔐 UserChoices pendentes de sincronização: ${result.length}');
      return result;
    } catch (e) {
      LoggerService.instance.e('Erro ao obter UserChoices pendentes de sincronização', error: e);
      return [];
    }
  }

  /// Atualiza timestamp de última sincronização
  Future<bool> updateLastSync(String userId) async {
    try {
      final existing = await getByUserId(userId);
      if (existing == null) return false;
      
      final updated = existing.copyWith(lastSyncAt: DateTime.now());
      return await save(updated);
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar lastSync para userId: $userId', error: e);
      return false;
    }
  }

  /// Obtém estatísticas do repositório
  Future<Map<String, dynamic>> getStats() async {
    try {
      final total = _box.count();
      final pendingSync = await getPendingSync();
      
      return {
        'total_users': total,
        'pending_sync': pendingSync.length,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas do UserChoices', error: e);
      return {};
    }
  }
}
