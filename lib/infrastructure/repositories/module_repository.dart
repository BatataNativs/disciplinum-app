import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';
import 'package:disciplinum/infrastructure/datasources/local_module_datasource.dart';
import 'package:disciplinum/infrastructure/datasources/cloud_module_datasource.dart';

/// Repository Pattern para dados de módulos
/// Abstrai a origem dos dados (local vs cloud)
class ModuleRepository {
  final LocalModuleDatasource _localDatasource;
  final CloudModuleDatasource _cloudDatasource;

  ModuleRepository({
    required LocalModuleDatasource localDatasource,
    required CloudModuleDatasource cloudDatasource,
  })  : _localDatasource = localDatasource,
        _cloudDatasource = cloudDatasource;

  /// Obtém status do módulo com cache local primeiro
  Future<UserModuleStatus?> getModuleStatus(int nicheId) async {
    try {
      // Tentar cache local primeiro
      final cached = await _localDatasource.getModuleStatus(nicheId);
      
      // Se não tiver cache ou estiver desatualizado, buscar do cloud
      if (cached == null || await _isCacheExpired(nicheId)) {
        final cloudData = await _cloudDatasource.getModuleStatus(nicheId);
        if (cloudData != null) {
          await _localDatasource.saveModuleStatus(cloudData);
          return cloudData;
        }
      }
      
      return cached;
    } catch (e) {
      // Fallback para cache local em caso de erro de rede
      return await _localDatasource.getModuleStatus(nicheId);
    }
  }

  /// Salva status do módulo localmente e sincroniza com cloud
  Future<void> saveModuleStatus(UserModuleStatus status) async {
    try {
      // Salvar localmente imediatamente
      await _localDatasource.saveModuleStatus(status);
      
      // Sincronizar com cloud em background
      await _cloudDatasource.saveModuleStatus(status);
    } catch (e) {
      // Se falhar sincronização, manter apenas local
      rethrow;
    }
  }

  /// Lista todos os módulos ativos
  Future<List<UserModuleStatus>> getActiveModules() async {
    try {
      final cached = await _localDatasource.getActiveModules();
      
      // Atualizar cache se necessário
      if (cached.isEmpty || await _shouldRefreshCache()) {
        final cloudData = await _cloudDatasource.getActiveModules();
        for (final status in cloudData) {
          await _localDatasource.saveModuleStatus(status);
        }
        return cloudData;
      }
      
      return cached;
    } catch (e) {
      return await _localDatasource.getActiveModules();
    }
  }

  /// Remove um módulo
  Future<void> removeModule(int nicheId) async {
    await _localDatasource.removeModule(nicheId);
    await _cloudDatasource.removeModule(nicheId);
  }

  /// Sincroniza dados locais com cloud
  Future<void> syncWithCloud() async {
    try {
      final localModules = await _localDatasource.getActiveModules();
      final cloudModules = await _cloudDatasource.getActiveModules();
      
      // Merge dos dados (cloud tem precedência)
      final mergedModules = <int, UserModuleStatus>{};
      
      // Adicionar dados do cloud
      for (final module in cloudModules) {
        mergedModules[module.nicheId] = module;
      }
      
      // Adicionar dados locais que não existem no cloud
      for (final module in localModules) {
        if (!mergedModules.containsKey(module.nicheId)) {
          mergedModules[module.nicheId] = module;
        }
      }
      
      // Salvar merged data
      for (final status in mergedModules.values) {
        await _localDatasource.saveModuleStatus(status);
        await _cloudDatasource.saveModuleStatus(status);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se cache está expirado
  Future<bool> _isCacheExpired(int nicheId) async {
    final lastSync = await _localDatasource.getLastSyncTime(nicheId);
    if (lastSync == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    // Cache expira em 1 hora
    return difference.inHours > 1;
  }

  /// Verifica se deve atualizar cache geral
  Future<bool> _shouldRefreshCache() async {
    final lastGeneralSync = await _localDatasource.getLastGeneralSyncTime();
    if (lastGeneralSync == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastGeneralSync);
    
    // Cache geral expira em 30 minutos
    return difference.inMinutes > 30;
  }
}
