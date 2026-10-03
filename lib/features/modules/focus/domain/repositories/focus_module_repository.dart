import 'dart:async';
import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_gamification_entity.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';

/// Repository do módulo Focus implementando ModuleRepositoryContract
class FocusModuleRepository implements ModuleRepositoryContract<FocusModuleState> {
  static FocusModuleRepository? _instance;
  static FocusModuleRepository get instance => _instance ??= FocusModuleRepository._();
  
  FocusModuleRepository._();

  Box<FocusGamificationEntity> get _box => ObjectBoxService.instance.store.box<FocusGamificationEntity>();

  final _statusController = StreamController<RepositoryStatus>.broadcast();
  RepositoryStatus _status = RepositoryStatus.initializing;

  @override
  String get moduleId => 'focus';

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
    LoggerService.instance.gamification('FocusModuleRepository inicializado');
  }

  @override
  Future<void> dispose() async {
    _setStatus(RepositoryStatus.disposed);
    await _statusController.close();
  }

  @override
  Future<FocusModuleState> saveLocal(FocusModuleState state) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      // Busca se já existe algum objeto no box
      final existing = _box.getAll().firstOrNull;
      
      final entity = FocusGamificationEntity()
        ..earnedInsigniasList = state.earnedInsignias
        ..earnedMedalhasList = state.earnedMedalhas
        ..completedSessions = state.sessionsCompleted
        ..totalFocusMinutes = state.totalFocusMinutes
        ..currentStreakDays = state.currentStreakDays
        ..maxStreakDays = state.longestStreakDays
        ..touch();
      
      // Se já existe, usa o mesmo ID para atualizar
      // Se não existe, usa ID 0 para deixar ObjectBox gerar novo ID
      if (existing != null) {
        entity.id = existing.id;
      } else {
        entity.id = 0; // ObjectBox vai gerar novo ID
      }
      
      _box.put(entity);

      LoggerService.instance.gamification('✅ FocusModuleState salvo localmente');
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
  Future<FocusModuleState?> loadLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final entity = _box.get(1);

      _setStatus(RepositoryStatus.ready);
      
      if (entity != null) {
        return FocusModuleState(
          createdAt: entity.createdAt,
          updatedAt: entity.updatedAt,
          earnedInsignias: entity.earnedInsigniasList,
          earnedMedalhas: entity.earnedMedalhasList,
          sessionsCompleted: entity.completedSessions,
          totalFocusMinutes: entity.totalFocusMinutes,
          currentStreakDays: entity.currentStreakDays,
          longestStreakDays: entity.maxStreakDays,
          currentStageId: entity.disciplinumCount > 5 ? 'silver' : 'bronze',
          unlockedAchievements: entity.earnedInsigniasList,
        );
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
      LoggerService.instance.gamification('🗑️ FocusModuleState local deletado');
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
  Future<List<FocusModuleState>> listAllLocal() async {
    try {
      final entities = _box.getAll();
      return entities.map((e) => FocusModuleState(
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        earnedInsignias: e.earnedInsigniasList,
        earnedMedalhas: e.earnedMedalhasList,
        sessionsCompleted: e.completedSessions,
        totalFocusMinutes: e.totalFocusMinutes,
        currentStreakDays: e.currentStreakDays,
        longestStreakDays: e.maxStreakDays,
        currentStageId: e.disciplinumCount > 5 ? 'silver' : 'bronze',
        unlockedAchievements: e.earnedInsigniasList,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FocusModuleState> syncToRemote(String userId, FocusModuleState state) async {
    return state;
  }

  @override
  Future<FocusModuleState?> loadFromRemote(String userId) async {
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
  Future<FocusModuleState> resolveConflict(FocusModuleState local, FocusModuleState remote) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      LoggerService.instance.gamification('⚡ Conflito resolvido: local é mais recente');
      return local;
    } else {
      LoggerService.instance.gamification('⚡ Conflito resolvido: remoto é mais recente');
      return remote;
    }
  }

  @override
  Future<FocusModuleState> fullSync(String userId) async {
    final local = await loadLocal(userId);
    return local ?? FocusModuleState();
  }

  @override
  Future<bool> hasDivergence(String userId) async {
    return false;
  }

  @override
  Future<void> clearAll(String userId) async {
    await deleteLocal(userId);
    LoggerService.instance.gamification('🧹 FocusModuleState completamente limpo');
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
  Future<FocusModuleState> importFromJson(Map<String, dynamic> json) async {
    final state = FocusModuleState.fromJson(json['state'] as Map<String, dynamic>);
    await saveLocal(state);
    LoggerService.instance.gamification('📥 FocusModuleState importado');
    return state;
  }
}
