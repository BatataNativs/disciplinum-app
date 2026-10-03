import 'dart:async';
import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_gamification_entity.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';

/// Repository do módulo Money Saving implementando ModuleRepositoryContract
class MoneySavingModuleRepository implements ModuleRepositoryContract<MoneySavingModuleState> {
  static MoneySavingModuleRepository? _instance;
  static MoneySavingModuleRepository get instance => _instance ??= MoneySavingModuleRepository._();
  
  MoneySavingModuleRepository._();

  Box<MoneySavingGamificationEntity> get _box => ObjectBoxService.instance.store.box<MoneySavingGamificationEntity>();

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
      
      // Busca se já existe algum objeto no box
      final existing = _box.getAll().firstOrNull;
      
      final entity = MoneySavingGamificationEntity.fromModuleState(state);
      
      // Se já existe, usa o mesmo ID para atualizar
      // Se não existe, usa ID 0 para deixar ObjectBox gerar novo ID
      if (existing != null) {
        entity.id = existing.id;
      } else {
        entity.id = 0; // ObjectBox vai gerar novo ID
      }
      
      _box.put(entity);

      LoggerService.instance.gamification('✅ MoneySavingModuleState salvo localmente (id=${entity.id})');
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
      final entities = _box.getAll();
      return entities.map((e) => e.toModuleState()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<MoneySavingModuleState> syncToRemote(String userId, MoneySavingModuleState state) async {
    _setStatus(RepositoryStatus.ready);
    return state;
  }

  @override
  Future<MoneySavingModuleState?> loadFromRemote(String userId) async {
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
