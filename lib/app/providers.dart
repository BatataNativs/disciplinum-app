import 'package:provider/provider.dart';
import 'package:disciplinum/infrastructure/repositories/module_repository.dart';
import 'package:disciplinum/infrastructure/datasources/local_module_datasource.dart';
import 'package:disciplinum/infrastructure/datasources/cloud_module_datasource.dart';
import 'package:disciplinum/features/gamification/presentation/controllers/gamification_controller.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider(
      create: (_) => GamificationController(
        moduleRepository: ModuleRepository(
          localDatasource: LocalModuleDatasource(),
          cloudDatasource: CloudModuleDatasource(),
        ),
      ),
    ),
    // Adicionar outros providers aqui
  ];
}
