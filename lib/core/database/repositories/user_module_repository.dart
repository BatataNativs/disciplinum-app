import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/database/entities/user_module_state.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório para gerenciar estados de módulos do usuário no ObjectBox
class UserModuleRepository {
  static UserModuleRepository? _instance;
  static UserModuleRepository get instance => _instance ??= UserModuleRepository._internal();
  
  UserModuleRepository._internal();

  Box<UserModuleState> get _box => ObjectBoxService.instance.store.box<UserModuleState>();

  /// Obtém o estado de um módulo para um usuário
  Future<UserModuleState?> getModuleState(String userId, int nicheId) async {
    try {
      return _box.query(
        UserModuleState_.userId.equals(userId)
          .and(UserModuleState_.nicheId.equals(nicheId))
      ).build().findFirst();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to get module state', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Obtém todos os estados de módulos de um usuário
  Future<List<UserModuleState>> getAllModuleStates(String userId) async {
    try {
      return _box.query(
        UserModuleState_.userId.equals(userId)
      ).build().find();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to get all module states', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Obtém apenas os módulos ativos de um usuário
  Future<List<UserModuleState>> getActiveModules(String userId) async {
    try {
      return _box.query(
        UserModuleState_.userId.equals(userId)
          .and(UserModuleState_.isActive.equals(true))
      ).build().find();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to get active modules', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Salva ou atualiza o estado de um módulo
  Future<void> saveModuleState(UserModuleState moduleState) async {
    try {
      _box.put(moduleState);
      LoggerService.instance.i('Module state saved: ${moduleState.nicheId}');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to save module state', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Ativa um módulo para um usuário
  Future<UserModuleState> activateModule(String userId, int nicheId) async {
    try {
      final now = DateTime.now();
      
      // Busca estado existente ou cria novo
      var moduleState = await getModuleState(userId, nicheId);
      moduleState ??= UserModuleState.create(
        userId: userId,
        nicheId: nicheId,
        isActive: true,
      );
      
      // Atualiza para ativo
      moduleState = moduleState.copyWith(
        isActive: true,
        lastAccessDate: now,
        updatedAt: now,
      );
      
      await saveModuleState(moduleState);
      return moduleState;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to activate module', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Desativa um módulo para um usuário
  Future<UserModuleState> deactivateModule(String userId, int nicheId) async {
    try {
      final now = DateTime.now();
      
      // Busca estado existente
      var moduleState = await getModuleState(userId, nicheId);
      if (moduleState == null) {
        throw StateError('Module state not found for user $userId and niche $nicheId');
      }
      
      // Atualiza para inativo
      moduleState = moduleState.copyWith(
        isActive: false,
        lastAccessDate: now,
        updatedAt: now,
      );
      
      await saveModuleState(moduleState);
      return moduleState;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to deactivate module', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Atualiza o acesso a um módulo (incrementa dias consecutivos)
  Future<UserModuleState> updateModuleAccess(String userId, int nicheId) async {
    try {
      final now = DateTime.now();
      
      // Busca estado existente
      var moduleState = await getModuleState(userId, nicheId);
      if (moduleState == null) {
        throw StateError('Module state not found for user $userId and niche $nicheId');
      }
      
      // Verifica se é um novo dia para incrementar sequência
      final isNewDay = _isNewDay(moduleState.lastAccessDate, now);
      final newConsecutiveDays = isNewDay ? moduleState.consecutiveDays + 1 : moduleState.consecutiveDays;
      
      // Atualiza estado
      moduleState = moduleState.copyWith(
        lastAccessDate: now,
        consecutiveDays: newConsecutiveDays,
        updatedAt: now,
      );
      
      await saveModuleState(moduleState);
      return moduleState;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to update module access', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Atualiza a medalha de um módulo
  Future<UserModuleState> updateModuleMedal(String userId, int nicheId, String medal) async {
    try {
      final now = DateTime.now();
      
      // Busca estado existente
      var moduleState = await getModuleState(userId, nicheId);
      if (moduleState == null) {
        throw StateError('Module state not found for user $userId and niche $nicheId');
      }
      
      // Atualiza medalha
      moduleState = moduleState.copyWith(
        maxMedal: medal,
        updatedAt: now,
      );
      
      await saveModuleState(moduleState);
      return moduleState;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to update module medal', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deleta um estado de módulo específico
  Future<void> deleteModuleState(String userId, int nicheId) async {
    try {
      final moduleState = await getModuleState(userId, nicheId);
      if (moduleState != null) {
        _box.remove(moduleState.id);
        LoggerService.instance.i('Module state deleted: ${moduleState.nicheId}');
      }
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to delete module state', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Limpa todos os estados de um usuário
  Future<void> clearUserStates(String userId) async {
    try {
      final query = _box.query(
        UserModuleState_.userId.equals(userId)
      ).build();
      final count = query.find().length;
      query.close();
      
      // Remove todos os estados do usuário
      final allStates = await getAllModuleStates(userId);
      for (final state in allStates) {
        _box.remove(state.id);
      }
      
      LoggerService.instance.i('Cleared $count module states for user $userId');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to clear user states', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Verifica se duas datas representam dias diferentes
  bool _isNewDay(DateTime lastDate, DateTime currentDate) {
    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final currentDay = DateTime(currentDate.year, currentDate.month, currentDate.day);
    return currentDay.isAfter(lastDay);
  }

  /// Obtém estatísticas dos módulos de um usuário
  Future<Map<String, dynamic>> getModuleStats(String userId) async {
    try {
      final allStates = await getAllModuleStates(userId);
      final activeStates = allStates.where((state) => state.isActive).toList();
      
      return {
        'totalModules': allStates.length,
        'activeModules': activeStates.length,
        'totalConsecutiveDays': allStates.fold<int>(0, (sum, state) => sum + state.consecutiveDays),
        'modulesWithMedals': allStates.where((state) => state.maxMedal != null).length,
        'mostUsedModule': activeStates.isNotEmpty 
            ? activeStates.reduce((a, b) => a.consecutiveDays > b.consecutiveDays ? a : b).nicheId 
            : null,
      };
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to get module stats', error: e, stackTrace: stackTrace);
      return {};
    }
  }
}
