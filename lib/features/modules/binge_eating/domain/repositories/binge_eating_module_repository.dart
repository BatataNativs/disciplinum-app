import 'dart:async';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_gamification_entity.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_module_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository do módulo Binge Eating implementando ModuleRepositoryContract
class BingeEatingModuleRepository implements ModuleRepositoryContract<BingeEatingModuleState> {
  static BingeEatingModuleRepository? _instance;
  static BingeEatingModuleRepository get instance => _instance ??= BingeEatingModuleRepository._();
  
  BingeEatingModuleRepository._();

  final _statusController = StreamController<RepositoryStatus>.broadcast();
  RepositoryStatus _status = RepositoryStatus.initializing;

  @override
  String get moduleId => 'binge_eating';

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
    LoggerService.instance.gamification('BingeEatingModuleRepository inicializado');
  }

  @override
  Future<void> dispose() async {
    _setStatus(RepositoryStatus.disposed);
    await _statusController.close();
  }

  @override
  Future<BingeEatingModuleState> saveLocal(BingeEatingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final entity = BingeEatingGamificationEntity.fromModuleState('', state);

      final isar = IsarService.instance.database;
      await isar.writeTxn(() async {
        await isar.bingeEatingGamificationEntitys.put(entity);
      });

      LoggerService.instance.gamification('✅ BingeEatingModuleState salvo localmente');
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
  Future<BingeEatingModuleState?> loadLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final isar = IsarService.instance.database;
      final entity = await isar.bingeEatingGamificationEntitys.filter().userIdEqualTo(userId).findFirst();

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
      final isar = IsarService.instance.database;
      final count = await isar.bingeEatingGamificationEntitys.filter().userIdEqualTo(userId).count();
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
        final entities = await isar.bingeEatingGamificationEntitys.filter().userIdEqualTo(userId).findAll();
        await isar.bingeEatingGamificationEntitys.deleteAll(entities.map((e) => e.id).toList());
      });
      LoggerService.instance.gamification('🗑️ BingeEatingModuleState local deletado');
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
  Future<List<BingeEatingModuleState>> listAllLocal() async {
    try {
      final isar = IsarService.instance.database;
      final entities = await isar.bingeEatingGamificationEntitys.where().findAll();
      return entities.map((e) => e.toModuleState()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BingeEatingModuleState> syncToRemote(String userId, BingeEatingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) throw Exception('Usuário não autenticado');

      await supabase.from('binge_eating_gamification_states').upsert({
        'user_id': currentUserId,
        'state_data': state.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('☁️ BingeEatingModuleState sincronizado');
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
  Future<BingeEatingModuleState?> loadFromRemote(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) return null;

      final response = await supabase
          .from('binge_eating_gamification_states')
          .select('state_data')
          .eq('user_id', currentUserId)
          .maybeSingle();

      _setStatus(RepositoryStatus.ready);
      
      if (response != null && response['state_data'] != null) {
        return BingeEatingModuleState.fromJson(response['state_data']);
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
          .from('binge_eating_gamification_states')
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
        await supabase.from('binge_eating_gamification_states').delete().eq('user_id', currentUserId);
      }
      LoggerService.instance.gamification('🗑️ BingeEatingModuleState remoto deletado');
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
  Future<BingeEatingModuleState> resolveConflict(BingeEatingModuleState local, BingeEatingModuleState remote) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      LoggerService.instance.gamification('⚡ Conflito resolvido: local é mais recente');
      return local;
    } else {
      LoggerService.instance.gamification('⚡ Conflito resolvido: remoto é mais recente');
      return remote;
    }
  }

  @override
  Future<BingeEatingModuleState> fullSync(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final local = await loadLocal(userId);
      final remote = await loadFromRemote(userId);

      BingeEatingModuleState result;
      if (local == null && remote == null) {
        result = BingeEatingModuleState();
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

      LoggerService.instance.gamification('🔄 BingeEatingModuleState full sync completo');
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
    LoggerService.instance.gamification('🧹 BingeEatingModuleState completamente limpo');
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
  Future<BingeEatingModuleState> importFromJson(Map<String, dynamic> json) async {
    final state = BingeEatingModuleState.fromJson(json['state'] as Map<String, dynamic>);
    await saveLocal(state);
    LoggerService.instance.gamification('📥 BingeEatingModuleState importado');
    return state;
  }
}
