import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/discipline/module_registry.dart';
import 'package:disciplinum/core/discipline/module_discipline_engine.dart';
import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';

/// Inicializador simplificado do sistema de disciplina
/// Substitui o DisciplineEngineInitializer original
class DisciplineInitializer {
  /// Inicializa o sistema com módulos registrados
  static Future<void> initialize() async {
    try {
      LoggerService.instance.i('Iniciando sistema de disciplina...');
      
      // Inicializa todos os módulos registrados no registry
      await ModuleRegistry.instance.initializeAllModules();
      
      final stats = ModuleDisciplineEngine.instance.getStatistics();
      LoggerService.instance.i(
        'Sistema de disciplina inicializado: '
        '${stats['total_modules']} módulos, ${stats['total_rules']} regras'
      );
      
      // Verifica saúde do sistema
      final health = ModuleRegistry.instance.checkHealth();
      if (!health['healthy']) {
        LoggerService.instance.w(
          'Problemas de saúde detectados: ${health['issues']}'
        );
      }
      
    } catch (e) {
      LoggerService.instance.e('Falha ao inicializar sistema de disciplina', error: e);
      rethrow;
    }
  }
  
  /// Registra um módulo individualmente
  static Future<void> registerModule(ModuleDisciplineInterface module) async {
    await ModuleRegistry.instance.registerModule(module);
  }
  
  /// Registra múltiplos módulos
  static Future<void> registerModules(List<ModuleDisciplineInterface> modules) async {
    await ModuleRegistry.instance.registerModules(modules);
  }
  
  /// Obtém estatísticas do sistema
  static Map<String, dynamic> getStatistics() {
    final engineStats = ModuleDisciplineEngine.instance.getStatistics();
    final registryStats = ModuleRegistry.instance.getRegistryStatistics();
    
    return {
      'engine': engineStats,
      'registry': registryStats,
      'health': ModuleRegistry.instance.checkHealth(),
    };
  }
  
  /// Limpa o sistema
  static Future<void> dispose() async {
    await ModuleRegistry.instance.clear();
    await ModuleDisciplineEngine.instance.dispose();
    LoggerService.instance.i('Sistema de disciplina finalizado');
  }
}
