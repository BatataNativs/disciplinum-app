import 'dart:async';

import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_module_state.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/entities/adult_content_gamification_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repository do módulo Adult Content implementando ModuleRepositoryContract
class AdultContentModuleRepository implements ModuleRepositoryContract<AdultContentModuleState> {
  static AdultContentModuleRepository? _instance;
  static AdultContentModuleRepository get instance => _instance ??= AdultContentModuleRepository._();

  AdultContentModuleRepository._();

  Box<AdultContentGamificationEntity>? _box;

  Box<AdultContentGamificationEntity> get box {
    _box ??= ObjectBoxService.instance.store.box<AdultContentGamificationEntity>();
    return _box!;
  }

  final _statusController = StreamController<RepositoryStatus>.broadcast();
  RepositoryStatus _status = RepositoryStatus.initializing;

  @override
  String get moduleId => 'adult_content';

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
    LoggerService.instance.gamification('AdultContentModuleRepository inicializado');
  }

  @override
  Future<void> dispose() async {
    _setStatus(RepositoryStatus.disposed);
    await _statusController.close();
  }

  @override
  Future<AdultContentModuleState> saveLocal(AdultContentModuleState state) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final entity = AdultContentGamificationEntity.fromModuleState('', state);

      box.put(entity);

      LoggerService.instance.gamification('✅ AdultContentModuleState salvo localmente');
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
  Future<AdultContentModuleState?> loadLocal(String userId) async {
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
      LoggerService.instance.gamification('🗑️ AdultContentModuleState local deletado');
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
  Future<List<AdultContentModuleState>> listAllLocal() async {
    try {
      final entities = box.getAll();
      return entities.map((e) => e.toModuleState()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<AdultContentModuleState> syncToRemote(String userId, AdultContentModuleState state) async {
    return state;
  }

  @override
  Future<AdultContentModuleState?> loadFromRemote(String userId) async {
    return null;
  }

  @override
  Future<bool> existsRemote(String userId) async {
    return false;
  }

  @override
  Future<void> deleteRemote(String userId) async {
    // No-op em modo 100% local
  }

  @override
  Future<AdultContentModuleState> resolveConflict(AdultContentModuleState local, AdultContentModuleState remote) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      LoggerService.instance.gamification('⚡ Conflito resolvido: local é mais recente');
      return local;
    } else {
      LoggerService.instance.gamification('⚡ Conflito resolvido: remoto é mais recente');
      return remote;
    }
  }

  @override
  Future<AdultContentModuleState> fullSync(String userId) async {
    final local = await loadLocal(userId);
    return local ?? AdultContentModuleState();
  }

  @override
  Future<bool> hasDivergence(String userId) async {
    return false;
  }

  @override
  Future<void> clearAll(String userId) async {
    await deleteLocal(userId);
    LoggerService.instance.gamification('🧹 AdultContentModuleState completamente limpo');
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
  Future<AdultContentModuleState> importFromJson(Map<String, dynamic> json) async {
    final state = AdultContentModuleState.fromJson(json['state'] as Map<String, dynamic>);
    await saveLocal(state);
    LoggerService.instance.gamification('📥 AdultContentModuleState importado');
    return state;
  }
}
