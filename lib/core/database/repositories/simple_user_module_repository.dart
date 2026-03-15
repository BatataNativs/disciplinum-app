import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/database/entities/user_module_state.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório simplificado para gerenciar estados de módulos do usuário
/// Versão temporária sem depender de código gerado pelo build_runner
class SimpleUserModuleRepository {
  static SimpleUserModuleRepository? _instance;
  static SimpleUserModuleRepository get instance => _instance ??= SimpleUserModuleRepository._internal();
  
  SimpleUserModuleRepository._internal();

  /// Armazenamento temporário em memória para substituir Isar enquanto não gerado
  final Map<String, UserModuleState> _cache = {};

  /// Obtém o estado de um módulo para um usuário
  Future<UserModuleState?> getModuleState(String userId, int nicheId) async {
    try {
      // Verifica cache primeiro
      final cacheKey = '${userId}_$nicheId';
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey];
      }

      // Tenta inicializar Isar se ainda não foi inicializado
      if (!IsarService.instance.isInitialized) {
        await IsarService.instance.initialize();
      }

      // Simulação de dados para teste
      final mockState = UserModuleState.create(
        userId: userId,
        nicheId: nicheId,
        isActive: false,
      );
      
      // Adiciona ao cache
      _cache[cacheKey] = mockState;
      
      return mockState;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to get module state', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Obtém todos os estados de módulos de um usuário
  Future<List<UserModuleState>> getAllModuleStates(String userId) async {
    try {
      // Verifica cache primeiro
      final cachedStates = _cache.values.where((state) => state.userId == userId).toList();
      if (cachedStates.isNotEmpty) {
        return cachedStates;
      }

      // Simulação de dados para teste
      final mockStates = [
        UserModuleState.create(userId: userId, nicheId: 1, isActive: true),
        UserModuleState.create(userId: userId, nicheId: 2, isActive: false),
      ];
      
      // Atualiza cache
      for (final state in mockStates) {
        _cache['${userId}_${state.nicheId}'] = state;
      }
      
      return mockStates;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to get all module states', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Obtém apenas os módulos ativos de um usuário
  Future<List<UserModuleState>> getActiveModules(String userId) async {
    try {
      final allStates = await getAllModuleStates(userId);
      final activeStates = allStates.where((state) => state.isActive).toList();
      
      // Atualiza cache
      for (final state in activeStates) {
        _cache['${userId}_${state.nicheId}'] = state;
      }
      
      return activeStates;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to get active modules', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Salva ou atualiza o estado de um módulo
  Future<void> saveModuleState(UserModuleState moduleState) async {
    try {
      // Simulação de salvamento (cache apenas)
      _cache['${moduleState.userId}_${moduleState.nicheId}'] = moduleState;
      
      LoggerService.instance.i('Module state saved (cache): ${moduleState.nicheId}');
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

  /// Limpa cache
  void clearCache() {
    _cache.clear();
  }

  /// Limpa todos os estados de um usuário
  Future<void> clearUserStates(String userId) async {
    try {
      // Limpa cache
      _cache.removeWhere((key, value) => key.startsWith('${userId}_'));
      
      LoggerService.instance.i('Cleared module states for user $userId (cache only)');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to clear user states', error: e, stackTrace: stackTrace);
      rethrow;
    }
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
