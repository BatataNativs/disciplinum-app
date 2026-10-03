import 'package:disciplinum/infrastructure/entities/user_module_status.dart';
import 'package:disciplinum/infrastructure/datasources/local_module_datasource.dart';

/// Repository Pattern para dados de módulos (100% Local-First)
class ModuleRepository {
  final LocalModuleDatasource _localDatasource;

  ModuleRepository({
    required LocalModuleDatasource localDatasource,
    dynamic cloudDatasource,
  }) : _localDatasource = localDatasource;

  /// Obtém status do módulo do armazenamento local
  Future<UserModuleStatus?> getModuleStatus(int nicheId) async {
    return await _localDatasource.getModuleStatus(nicheId);
  }

  /// Salva status do módulo localmente
  Future<void> saveModuleStatus(UserModuleStatus status) async {
    await _localDatasource.saveModuleStatus(status);
  }

  /// Lista todos os módulos ativos
  Future<List<UserModuleStatus>> getActiveModules() async {
    return await _localDatasource.getActiveModules();
  }

  /// Remove um módulo
  Future<void> removeModule(int nicheId) async {
    await _localDatasource.removeModule(nicheId);
  }

  /// Sincronização (Local-First: sem nuvem)
  Future<void> syncWithCloud() async {
    // Operação 100% local: nenhum envio para nuvem
  }
}
