import 'dart:async';
import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_gamification_entity.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_module_state.dart';

/// Repository do módulo Binge Eating implementando ModuleRepositoryContract
class BingeEatingModuleRepository implements ModuleRepositoryContract<BingeEatingModuleState> {
  static BingeEatingModuleRepository? _instance;
  static BingeEatingModuleRepository get instance => _instance ??= BingeEatingModuleRepository._();
  
  BingeEatingModuleRepository._();

  Box<BingeEatingGamificationEntity> get _box => ObjectBoxService.instance.store.box<BingeEatingGamificationEntity>();

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
      
      // Busca se já existe algum objeto no box
      final existing = _box.getAll().firstOrNull;
      
      final entity = BingeEatingGamificationEntity.fromModuleState('', state);
      
      // Se já existe, usa o mesmo ID para atualizar
      // Se não existe, usa ID 0 para deixar ObjectBox gerar novo ID
      if (existing != null) {
        entity.id = existing.id;
      } else {
        entity.id = 0; // ObjectBox vai gerar novo ID
      }
      
      _box.put(entity);

      LoggerService.instance.gamification('✅ BingeEatingModuleState salvo localmente (id=${entity.id})');
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
      final entities = _box.getAll();
      return entities.map((e) => e.toModuleState()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BingeEatingModuleState> syncToRemote(String userId, BingeEatingModuleState state) async {
    return state;
  }

  @override
  Future<BingeEatingModuleState?> loadFromRemote(String userId) async {
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
    final local = await loadLocal(userId);
    return local ?? BingeEatingModuleState();
  }

  @override
  Future<bool> hasDivergence(String userId) async {
    return false;
  }

  @override
  Future<void> clearAll(String userId) async {
    await deleteLocal(userId);
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
