import 'dart:async';

import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_module_state.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/entities/spending_gamification_entity.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository do módulo Spending implementando ModuleRepositoryContract
class SpendingModuleRepository implements ModuleRepositoryContract<SpendingModuleState> {
  static SpendingModuleRepository? _instance;
  static SpendingModuleRepository get instance => _instance ??= SpendingModuleRepository._();

  SpendingModuleRepository._();

  Box<SpendingGamificationEntity>? _box;

  Box<SpendingGamificationEntity> get box {
    _box ??= ObjectBoxService.instance.store.box<SpendingGamificationEntity>();
    return _box!;
  }

  final _statusController = StreamController<RepositoryStatus>.broadcast();
  RepositoryStatus _status = RepositoryStatus.initializing;

  @override
  String get moduleId => 'spending';

  @override
  RepositoryStatus get status => _status;

  @override
  Stream<RepositoryStatus> get statusStream => _statusController.stream;

  void _setStatus(RepositoryStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  @override
  Future<void> initialize() async {
    _setStatus(RepositoryStatus.ready);
    LoggerService.instance.gamification('SpendingModuleRepository inicializado');
  }

  @override
  Future<void> dispose() async {
    _setStatus(RepositoryStatus.disposed);
    await _statusController.close();
  }

  @override
  Future<SpendingModuleState> saveLocal(SpendingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      // Busca se já existe algum objeto no box
      final existing = box.getAll().firstOrNull;
      
      final entity = SpendingGamificationEntity.fromModuleState('', state);
      
      // Se já existe, usa o mesmo ID para atualizar
      // Se não existe, usa ID 0 para deixar ObjectBox gerar novo ID
      if (existing != null) {
        entity.id = existing.id;
      } else {
        entity.id = 0; // ObjectBox vai gerar novo ID
      }

      box.put(entity);

      LoggerService.instance.gamification('✅ SpendingModuleState salvo localmente');
      _setStatus(RepositoryStatus.ready);
      return state;
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro ao salvar localmente: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.saveLocal,
        originalError: e,
      );
    }
  }

  @override
  Future<SpendingModuleState?> loadLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);

      // Usar ID fixo (1) como padrão do projeto, igual ao Reading
      final entity = box.get(1);

      _setStatus(RepositoryStatus.ready);
      
      if (entity != null) {
        return entity.toModuleState();
      }
      return null;
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro ao carregar localmente: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.loadLocal,
        originalError: e,
      );
    }
  }

  @override
  Future<bool> existsLocal(String userId) async {
    try {
      final count = box.count();
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      // Limpar todas as entidades (padrão igual ao Reading)
      box.removeAll();
      LoggerService.instance.gamification('🗑️ SpendingModuleState local deletado');
      _setStatus(RepositoryStatus.ready);
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro ao deletar localmente: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.deleteLocal,
        originalError: e,
      );
    }
  }

  @override
  Future<List<SpendingModuleState>> listAllLocal() async {
    try {
      final entities = box.getAll();
      return entities.map((e) => e.toModuleState()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<SpendingModuleState> syncToRemote(String userId, SpendingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) throw Exception('Usuário não autenticado');

      await supabase.from('spending_gamification_states').upsert(
        {
          'user_id': currentUserId,
          'state_data': state.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id',
      );

      LoggerService.instance.gamification('☁️ SpendingModuleState sincronizado');
      _setStatus(RepositoryStatus.ready);
      return state;
    } catch (e) {
      _setStatus(RepositoryStatus.offline);
      throw RepositoryException(
        message: 'Erro ao sincronizar: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.syncToRemote,
        originalError: e,
      );
    }
  }

  @override
  Future<SpendingModuleState?> loadFromRemote(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) return null;

      final response = await supabase
          .from('spending_gamification_states')
          .select('state_data')
          .eq('user_id', currentUserId)
          .maybeSingle();

      _setStatus(RepositoryStatus.ready);
      
      if (response != null && response['state_data'] != null) {
        return SpendingModuleState.fromJson(response['state_data']);
      }
      return null;
    } catch (e) {
      _setStatus(RepositoryStatus.offline);
      throw RepositoryException(
        message: 'Erro ao carregar do remoto: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.loadFromRemote,
        originalError: e,
      );
    }
  }

  @override
  Future<bool> existsRemote(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      final response = await supabase
          .from('spending_gamification_states')
          .select('id')
          .eq('user_id', currentUserId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteRemote(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId != null) {
        await supabase.from('spending_gamification_states').delete().eq('user_id', currentUserId);
      }
      LoggerService.instance.gamification('🗑️ SpendingModuleState remoto deletado');
      _setStatus(RepositoryStatus.ready);
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro ao deletar remotamente: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.deleteRemote,
        originalError: e,
      );
    }
  }

  @override
  Future<SpendingModuleState> resolveConflict(SpendingModuleState local, SpendingModuleState remote) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      LoggerService.instance.gamification('⚡ Conflito resolvido: local é mais recente');
      return local;
    } else {
      LoggerService.instance.gamification('⚡ Conflito resolvido: remoto é mais recente');
      return remote;
    }
  }

  @override
  Future<SpendingModuleState> fullSync(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final local = await loadLocal(userId);
      final remote = await loadFromRemote(userId);

      SpendingModuleState result;
      if (local == null && remote == null) {
        result = SpendingModuleState();
        await saveLocal(result);
        await syncToRemote(userId, result);
      } else if (local == null && remote != null) {
        result = remote;
        await saveLocal(result);
      } else if (local != null && remote == null) {
        result = local;
        await syncToRemote(userId, result);
      } else {
        result = await resolveConflict(local!, remote!);
        await saveLocal(result);
        await syncToRemote(userId, result);
      }

      LoggerService.instance.gamification('🔄 SpendingModuleState full sync completo');
      _setStatus(RepositoryStatus.ready);
      return result;
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro no full sync: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.fullSync,
        originalError: e,
      );
    }
  }

  @override
  Future<bool> hasDivergence(String userId) async {
    try {
      final local = await loadLocal(userId);
      final remote = await loadFromRemote(userId);
      if (local == null && remote == null) return false;
      if (local == null || remote == null) return true;
      return local.updatedAt != remote.updatedAt;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAll(String userId) async {
    await deleteLocal(userId);
    await deleteRemote(userId);
    LoggerService.instance.gamification('🧹 SpendingModuleState completamente limpo');
  }

  @override
  Future<Map<String, dynamic>> exportToJson(String userId) async {
    final local = await loadLocal(userId);
    return {
      'module_id': moduleId,
      'exported_at': DateTime.now().toIso8601String(),
      'state': local?.toJson(),
    };
  }

  @override
  Future<SpendingModuleState> importFromJson(Map<String, dynamic> json) async {
    final state = SpendingModuleState.fromJson(json['state'] as Map<String, dynamic>);
    await saveLocal(state);
    LoggerService.instance.gamification('📥 SpendingModuleState importado');
    return state;
  }
}
