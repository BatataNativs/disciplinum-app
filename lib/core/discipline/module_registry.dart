import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/discipline/module_discipline_engine.dart';
import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';

/// Registro centralizado de módulos de disciplina
/// Gerencia o registro dinâmico e inicialização de todos os módulos
class ModuleRegistry {
  static ModuleRegistry? _instance;
  static ModuleRegistry get instance => _instance ??= ModuleRegistry._();

  ModuleRegistry._();

  final Map<String, ModuleDisciplineInterface> _modules = {};
  bool _initialized = false;

  /// Registra um módulo no sistema
  Future<void> registerModule(ModuleDisciplineInterface module) async {
    if (_modules.containsKey(module.moduleId)) {
      LoggerService.instance.w(
        'Módulo ${module.moduleId} já está registrado. Sobrescrevendo...'
      );
    }

    _modules[module.moduleId] = module;
    
    // Registra no engine se já estiver inicializado
    if (_initialized) {
      await ModuleDisciplineEngine.instance.registerModule(module);
    }

    LoggerService.instance.i(
      'Módulo ${module.moduleName} (${module.moduleId}) registrado no registry'
    );
  }

  /// Remove um módulo do sistema
  Future<void> unregisterModule(String moduleId) async {
    final module = _modules.remove(moduleId);
    if (module != null) {
      if (_initialized) {
        await ModuleDisciplineEngine.instance.unregisterModule(moduleId);
      }
      
      LoggerService.instance.i(
        'Módulo ${module.moduleName} ($moduleId) removido do registry'
      );
    }
  }

  /// Inicializa todos os módulos registrados no DisciplineEngine
  Future<void> initializeAllModules() async {
    if (_initialized) {
      LoggerService.instance.w('ModuleRegistry já foi inicializado');
      return;
    }

    LoggerService.instance.i(
      'Inicializando ${_modules.length} módulos no DisciplineEngine...'
    );

    for (final module in _modules.values) {
      try {
        await ModuleDisciplineEngine.instance.registerModule(module);
      } catch (e) {
        LoggerService.instance.e(
          'Erro ao inicializar módulo ${module.moduleId}',
          error: e,
        );
      }
    }

    _initialized = true;
    
    final stats = ModuleDisciplineEngine.instance.getStatistics();
    LoggerService.instance.i(
      'ModuleRegistry inicializado com ${stats['total_modules']} módulos '
      'e ${stats['total_rules']} regras totais'
    );
  }

  /// Obtém um módulo do registry
  ModuleDisciplineInterface? getModule(String moduleId) {
    return _modules[moduleId];
  }

  /// Lista todos os módulos registrados
  Map<String, ModuleDisciplineInterface> get allModules => 
      Map.unmodifiable(_modules);

  /// Verifica se um módulo está registrado
  bool isModuleRegistered(String moduleId) {
    return _modules.containsKey(moduleId);
  }

  /// Obtém estatísticas do registry
  Map<String, dynamic> getRegistryStatistics() {
    return {
      'registered_modules': _modules.length,
      'initialized': _initialized,
      'modules': {
        for (final entry in _modules.entries)
          entry.key: {
            'name': entry.value.moduleName,
            'rules_count': entry.value.rules.length,
            'enabled_rules': entry.value.rules
                .where((r) => r.isEnabled).length,
          },
      },
    };
  }

  /// Limpa todos os módulos
  Future<void> clear() async {
    for (final moduleId in _modules.keys.toList()) {
      await unregisterModule(moduleId);
    }
    _initialized = false;
    
    LoggerService.instance.i('ModuleRegistry limpo');
  }

  /// Facade para registrar múltiplos módulos de uma vez
  Future<void> registerModules(List<ModuleDisciplineInterface> modules) async {
    for (final module in modules) {
      await registerModule(module);
    }
  }

  /// Verifica a saúde do registry
  Map<String, dynamic> checkHealth() {
    final issues = <String>[];
    
    // Verifica se há módulos duplicados
    final moduleIds = _modules.keys.toList();
    final duplicates = moduleIds.where((id) => 
        moduleIds.where((other) => other == id).length > 1);
    
    if (duplicates.isNotEmpty) {
      issues.add('Módulos duplicados: ${duplicates.join(', ')}');
    }

    // Verifica se há módulos sem regras
    final modulesWithoutRules = _modules.entries
        .where((entry) => entry.value.rules.isEmpty)
        .map((entry) => entry.key);
    
    if (modulesWithoutRules.isNotEmpty) {
      issues.add('Módulos sem regras: ${modulesWithoutRules.join(', ')}');
    }

    // Verifica se o engine está consistente com o registry
    if (_initialized) {
      final engineModules = ModuleDisciplineEngine.instance.allModules.keys;
      final registryModules = _modules.keys;
      
      final missingInEngine = registryModules
          .where((id) => !engineModules.contains(id));
      final extraInEngine = engineModules
          .where((id) => !registryModules.contains(id));
      
      if (missingInEngine.isNotEmpty) {
        issues.add('Módulos no registry mas não no engine: ${missingInEngine.join(', ')}');
      }
      
      if (extraInEngine.isNotEmpty) {
        issues.add('Módulos no engine mas não no registry: ${extraInEngine.join(', ')}');
      }
    }

    return {
      'healthy': issues.isEmpty,
      'issues': issues,
      'registry_modules': _modules.length,
      'initialized': _initialized,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
