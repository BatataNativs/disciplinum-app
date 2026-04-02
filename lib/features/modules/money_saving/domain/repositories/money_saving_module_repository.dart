import 'dart:async';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_gamification_entity.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository do módulo Money Saving implementando ModuleRepositoryContract
class MoneySavingModuleRepository implements ModuleRepositoryContract<MoneySavingModuleState> {
  static MoneySavingModuleRepository? _instance;
  static MoneySavingModuleRepository get instance => _instance ??= MoneySavingModuleRepository._();
  
  MoneySavingModuleRepository._();

  final _statusController = StreamController<RepositoryStatus>.broadcast();
  RepositoryStatus _status = RepositoryStatus.initializing;

  @override
  String get moduleId => 'money_saving';

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
    LoggerService.instance.gamification('MoneySavingModuleRepository inicializado');
  }

  @override
  Future<void> dispose() async {
    _setStatus(RepositoryStatus.disposed);
    await _statusController.close();
  }

  @override
  Future<MoneySavingModuleState> saveLocal(MoneySavingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final entity = MoneySavingGamificationEntity.fromModuleState('', state.toJson());

      final isar = IsarService.instance.database;
      await isar.writeTxn(() async {
        await isar.moneySavingGamificationEntitys.put(entity);
      });

      LoggerService.instance.gamification('✅ MoneySavingModuleState salvo localmente');
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
  Future<MoneySavingModuleState?> loadLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final isar = IsarService.instance.database;
      final entity = await isar.moneySavingGamificationEntitys.filter().userIdEqualTo(userId).findFirst();

      _setStatus(RepositoryStatus.ready);
      
      if (entity != null) {
        return MoneySavingModuleState.fromJson(entity.toModuleStateMap());
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
      final isar = IsarService.instance.database;
      final count = await isar.moneySavingGamificationEntitys.filter().userIdEqualTo(userId).count();
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      final isar = IsarService.instance.database;
      await isar.writeTxn(() async {
        final entities = await isar.moneySavingGamificationEntitys.filter().userIdEqualTo(userId).findAll();
        await isar.moneySavingGamificationEntitys.deleteAll(entities.map((e) => e.id).toList());
      });
      LoggerService.instance.gamification('🗑️ MoneySavingModuleState local deletado');
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
  Future<List<MoneySavingModuleState>> listAllLocal() async {
    try {
      final isar = IsarService.instance.database;
      final entities = await isar.moneySavingGamificationEntitys.where().findAll();
      return entities.map((e) => MoneySavingModuleState.fromJson(e.toModuleStateMap())).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<MoneySavingModuleState> syncToRemote(String userId, MoneySavingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) throw Exception('Usuário não autenticado');

      await supabase.from('money_saving_gamification_states').upsert({
        'user_id': currentUserId,
        'state_data': state.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('☁️ MoneySavingModuleState sincronizado');
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
  Future<MoneySavingModuleState?> loadFromRemote(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) return null;

      final response = await supabase
          .from('money_saving_gamification_states')
          .select('state_data')
          .eq('user_id', currentUserId)
          .maybeSingle();

      _setStatus(RepositoryStatus.ready);
      
      if (response != null && response['state_data'] != null) {
        return MoneySavingModuleState.fromJson(response['state_data']);
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
          .from('money_saving_gamification_states')
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
        await supabase.from('money_saving_gamification_states').delete().eq('user_id', currentUserId);
      }
      LoggerService.instance.gamification('🗑️ MoneySavingModuleState remoto deletado');
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
  Future<MoneySavingModuleState> resolveConflict(MoneySavingModuleState local, MoneySavingModuleState remote) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      LoggerService.instance.gamification('⚡ Conflito resolvido: local é mais recente');
      return local;
    } else {
      LoggerService.instance.gamification('⚡ Conflito resolvido: remoto é mais recente');
      return remote;
    }
  }

  @override
  Future<MoneySavingModuleState> fullSync(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final local = await loadLocal(userId);
      final remote = await loadFromRemote(userId);

      MoneySavingModuleState result;
      if (local == null && remote == null) {
        result = MoneySavingModuleState();
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

      LoggerService.instance.gamification('🔄 MoneySavingModuleState full sync completo');
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
    LoggerService.instance.gamification('🧹 MoneySavingModuleState completamente limpo');
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
  Future<MoneySavingModuleState> importFromJson(Map<String, dynamic> json) async {
    final state = MoneySavingModuleState.fromJson(json['state'] as Map<String, dynamic>);
    await saveLocal(state);
    LoggerService.instance.gamification('📥 MoneySavingModuleState importado');
    return state;
  }
}
