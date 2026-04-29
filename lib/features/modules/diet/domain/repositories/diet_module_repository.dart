import 'dart:async';
import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/entities/diet_gamification_entity.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_module_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository do módulo Diet implementando ModuleRepositoryContract
class DietModuleRepository implements ModuleRepositoryContract<DietModuleState> {
  static DietModuleRepository? _instance;
  static DietModuleRepository get instance => _instance ??= DietModuleRepository._();
  
  DietModuleRepository._();

  Box<DietGamificationEntity> get _box => ObjectBoxService.instance.store.box<DietGamificationEntity>();

  final _statusController = StreamController<RepositoryStatus>.broadcast();
  RepositoryStatus _status = RepositoryStatus.initializing;

  @override
  String get moduleId => 'diet';

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
    LoggerService.instance.gamification('DietModuleRepository inicializado');
  }

  @override
  Future<void> dispose() async {
    _setStatus(RepositoryStatus.disposed);
    await _statusController.close();
  }

  @override
  Future<DietModuleState> saveLocal(DietModuleState state) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      // Busca se já existe algum objeto no box
      final existing = _box.getAll().firstOrNull;
      
      final entity = DietGamificationEntity.fromModuleState('', state.toJson());
      
      // Se já existe, usa o mesmo ID para atualizar
      // Se não existe, usa ID 0 para deixar ObjectBox gerar novo ID
      if (existing != null) {
        entity.id = existing.id;
      } else {
        entity.id = 0; // ObjectBox vai gerar novo ID
      }
      
      _box.put(entity);

      LoggerService.instance.gamification('✅ DietModuleState salvo localmente (id=${entity.id})');
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
  Future<DietModuleState?> loadLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      // Usar ID fixo (1) como padrão do projeto, igual ao Reading
      final entity = _box.get(1);

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
      final count = _box.count();
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      _box.removeAll();
      LoggerService.instance.gamification('🗑️ DietModuleState local deletado');
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
  Future<List<DietModuleState>> listAllLocal() async {
    try {
      final entities = _box.getAll();
      return entities.map((e) => e.toModuleState()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<DietModuleState> syncToRemote(String userId, DietModuleState state) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) throw Exception('Usuário não autenticado');

      await supabase.from('diet_gamification_states').upsert(
        {
          'user_id': currentUserId,
          'state_data': state.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id',
      );

      LoggerService.instance.gamification('☁️ DietModuleState sincronizado');
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
  Future<DietModuleState?> loadFromRemote(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) return null;

      final response = await supabase
          .from('diet_gamification_states')
          .select('state_data')
          .eq('user_id', currentUserId)
          .maybeSingle();

      _setStatus(RepositoryStatus.ready);
      
      if (response != null && response['state_data'] != null) {
        return DietModuleState.fromJson(response['state_data']);
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
          .from('diet_gamification_states')
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
        await supabase.from('diet_gamification_states').delete().eq('user_id', currentUserId);
      }
      LoggerService.instance.gamification('🗑️ DietModuleState remoto deletado');
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
  Future<DietModuleState> resolveConflict(DietModuleState local, DietModuleState remote) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      LoggerService.instance.gamification('⚡ Conflito resolvido: local é mais recente');
      return local;
    } else {
      LoggerService.instance.gamification('⚡ Conflito resolvido: remoto é mais recente');
      return remote;
    }
  }

  @override
  Future<DietModuleState> fullSync(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final local = await loadLocal(userId);
      final remote = await loadFromRemote(userId);

      DietModuleState result;
      if (local == null && remote == null) {
        result = DietModuleState();
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

      LoggerService.instance.gamification('🔄 DietModuleState full sync completo');
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
    LoggerService.instance.gamification('🧹 DietModuleState completamente limpo');
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
  Future<DietModuleState> importFromJson(Map<String, dynamic> json) async {
    final state = DietModuleState.fromJson(json['state'] as Map<String, dynamic>);
    await saveLocal(state);
    LoggerService.instance.gamification('📥 DietModuleState importado');
    return state;
  }
}
