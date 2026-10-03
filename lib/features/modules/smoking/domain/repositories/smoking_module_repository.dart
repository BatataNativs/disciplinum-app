import 'dart:async';

import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_gamification_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repository do módulo Smoking implementando ModuleRepositoryContract (100% Local-First)
class SmokingModuleRepository implements ModuleRepositoryContract<SmokingModuleState> {
  static SmokingModuleRepository? _instance;
  static SmokingModuleRepository get instance => _instance ??= SmokingModuleRepository._();

  SmokingModuleRepository._();

  Box<SmokingGamificationEntity>? _box;

  Box<SmokingGamificationEntity> get box {
    _box ??= ObjectBoxService.instance.store.box<SmokingGamificationEntity>();
    return _box!;
  }

  final _statusController = StreamController<RepositoryStatus>.broadcast();
  RepositoryStatus _status = RepositoryStatus.initializing;

  @override
  String get moduleId => 'smoking';

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
    LoggerService.instance.gamification('SmokingModuleRepository inicializado');
  }

  @override
  Future<void> dispose() async {
    _setStatus(RepositoryStatus.disposed);
    await _statusController.close();
  }

  @override
  Future<SmokingModuleState> saveLocal(SmokingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final entity = SmokingGamificationEntity()
        ..earnedInsigniasList = state.earnedInsignias
        ..earnedMedalhasList = state.earnedMedalhas
        ..consecutivePositiveDays = state.consecutivePositiveDays
        ..disciplinumCount = state.disciplinumCount
        ..lastPositiveCheckIn = state.lastPositiveCheckIn
        ..startDate = state.startDate
        ..dailyCost = state.dailyCost
        ..packCost = state.packCost
        ..isModuleActive = state.isModuleActive
        ..id = 1
        ..touch();

      box.put(entity);

      LoggerService.instance.gamification('✅ SmokingModuleState salvo localmente');
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
  Future<SmokingModuleState?> loadLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);

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
      box.removeAll();
      LoggerService.instance.gamification('🗑️ SmokingModuleState local deletado');
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
  Future<List<SmokingModuleState>> listAllLocal() async {
    try {
      final entities = box.getAll();
      return entities.map((e) => SmokingModuleState.fromJson(e.toJson())).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<SmokingModuleState> syncToRemote(String userId, SmokingModuleState state) async {
    // 100% Local-First: nada a sincronizar remotamente
    _setStatus(RepositoryStatus.ready);
    return state;
  }

  @override
  Future<SmokingModuleState?> loadFromRemote(String userId) async {
    // 100% Local-First: dados lidos exclusivamente do ObjectBox
    _setStatus(RepositoryStatus.ready);
    return null;
  }

  @override
  Future<bool> existsRemote(String userId) async {
    return false;
  }

  @override
  Future<void> deleteRemote(String userId) async {
    _setStatus(RepositoryStatus.ready);
  }

  @override
  Future<SmokingModuleState> resolveConflict(SmokingModuleState local, SmokingModuleState remote) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      LoggerService.instance.gamification('⚡ Conflito resolvido: local é mais recente');
      return local;
    } else {
      LoggerService.instance.gamification('⚡ Conflito resolvido: remoto é mais recente');
      return remote;
    }
  }

  @override
  Future<SmokingModuleState> fullSync(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      LoggerService.instance.gamification('🔄 fullSync START: userId=$userId');
      
      final local = await loadLocal(userId);
      final remote = await loadFromRemote(userId);
      
      LoggerService.instance.gamification('📊 fullSync STATUS: local=${local != null ? 'EXISTS(isActive=${local.isModuleActive})' : 'NULL'}, remote=${remote != null ? 'EXISTS(isActive=${remote.isModuleActive})' : 'NULL'}');

      SmokingModuleState result;
      if (local == null && remote == null) {
        LoggerService.instance.gamification('📝 fullSync PATH: local=null, remote=null -> Criando novo estado INATIVO');
        result = SmokingModuleState();
        await saveLocal(result);
        await syncToRemote(userId, result);
      } else if (local == null && remote != null) {
        LoggerService.instance.gamification('☁️ fullSync PATH: local=null, remote=EXISTS -> Restaurando da nuvem (isActive=${remote.isModuleActive})');
        result = remote;
        await saveLocal(result);
      } else if (local != null && remote == null) {
        LoggerService.instance.gamification('💾 fullSync PATH: local=EXISTS, remote=null -> Enviando local para nuvem');
        result = local;
        await syncToRemote(userId, result);
      } else {
        LoggerService.instance.gamification('⚡ fullSync PATH: local=EXISTS, remote=EXISTS -> Resolvendo conflito');
        result = await resolveConflict(local!, remote!);
        await saveLocal(result);
        await syncToRemote(userId, result);
      }

      LoggerService.instance.gamification('✅ fullSync END: result.isActive=${result.isModuleActive}');
      _setStatus(RepositoryStatus.ready);
      return result;
    } catch (e, stackTrace) {
      _setStatus(RepositoryStatus.error);
      LoggerService.instance.e('❌ fullSync ERRO: $e');
      LoggerService.instance.d('StackTrace: $stackTrace');
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
    LoggerService.instance.gamification('🧹 SmokingModuleState completamente limpo');
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
  Future<SmokingModuleState> importFromJson(Map<String, dynamic> json) async {
    final state = SmokingModuleState.fromJson(json['state'] as Map<String, dynamic>);
    await saveLocal(state);
    LoggerService.instance.gamification('📥 SmokingModuleState importado');
    return state;
  }
}
