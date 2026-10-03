import 'package:disciplinum/infrastructure/entities/user_module_status.dart';

/// DataSource legado de nuvem (desativado na arquitetura 100% Local-First)
class CloudModuleDatasource {
  Future<UserModuleStatus?> getModuleStatus(int nicheId) async => null;
  Future<void> saveModuleStatus(UserModuleStatus status) async {}
  Future<void> removeModule(int nicheId) async {}
  Future<List<UserModuleStatus>> getActiveModules() async => [];
  Future<void> syncMultipleModules(List<UserModuleStatus> modules) async {}
  Future<void> forceSync() async {}
}
