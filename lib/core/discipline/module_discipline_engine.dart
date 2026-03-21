import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/discipline/interfaces/module_discipline_interface.dart';

/// Motor de disciplina refatorado para arquitetura de plugins
/// Não conhece implementações específicas, apenas interfaces
class ModuleDisciplineEngine {
  static ModuleDisciplineEngine? _instance;
  static ModuleDisciplineEngine get instance => _instance ??= ModuleDisciplineEngine._();

  ModuleDisciplineEngine._();

  final Map<String, ModuleDisciplineInterface> _modules = {};
  final StreamController<ModuleDisciplineResult> _resultsController = 
      StreamController<ModuleDisciplineResult>.broadcast();

  /// Stream de resultados das regras de todos os módulos
  Stream<ModuleDisciplineResult> get results => _resultsController.stream;

  /// Registra um módulo e suas regras
  Future<void> registerModule(ModuleDisciplineInterface module) async {
    try {
      // Inicializa as regras do módulo
      await module.initializeRules();
      
      // Registra o módulo
      _modules[module.moduleId] = module;
      
      LoggerService.instance.i(
        'Módulo registrado: ${module.moduleName} (${module.moduleId}) '
        'com ${module.rules.length} regras'
      );
      
      // Emite evento de registro
      EventBus.instance.emit(ModuleRegisteredEvent(
        moduleId: module.moduleId,
        ruleId: 'module_registration',
        moduleName: module.moduleName,
      ));
      
      // Log das regras registradas
      for (final rule in module.rules) {
        LoggerService.instance.d(
          '  - Regra: ${rule.ruleName} (${rule.ruleId}) '
          '[${rule.isEnabled ? "ENABLED" : "DISABLED"}]'
        );
      }
    } catch (e) {
      LoggerService.instance.e(
        'Erro ao registrar módulo ${module.moduleId}',
        error: e,
      );
      rethrow;
    }
  }

  /// Remove um módulo e suas regras
  Future<void> unregisterModule(String moduleId) async {
    final module = _modules.remove(moduleId);
    if (module != null) {
      await module.dispose();
      
      LoggerService.instance.i('Módulo removido: ${module.moduleName} ($moduleId)');
      
      EventBus.instance.emit(ModuleRegisteredEvent(
        moduleId: moduleId,
        ruleId: 'module_unregistration',
        moduleName: module.moduleName,
      ));
    }
  }

  /// Obtém um módulo registrado
  ModuleDisciplineInterface? getModule(String moduleId) {
    return _modules[moduleId];
  }

  /// Obtém todos os módulos registrados
  Map<String, ModuleDisciplineInterface> get allModules => 
      Map.unmodifiable(_modules);

  /// Executa regras para um contexto específico
  Future<List<ModuleDisciplineResult>> executeRules(
    ModuleDisciplineContext context
  ) async {
    final module = _modules[context.moduleId];
    if (module == null) {
      LoggerService.instance.w(
        'Módulo não encontrado: ${context.moduleId}'
      );
      return [];
    }

    final applicableRules = module.rules
        .where((rule) => rule.isEnabled && rule.canExecute(context))
        .toList();
    
    final results = <ModuleDisciplineResult>[];

    LoggerService.instance.d(
      'Executando ${applicableRules.length} regras para módulo ${context.moduleId}'
    );

    for (final rule in applicableRules) {
      try {
        final result = await rule.execute(context);
        results.add(result);
        
        _resultsController.add(result);
        
        // Emite evento de execução
        EventBus.instance.emit(RuleExecutedEvent(
          moduleId: context.moduleId,
          ruleId: rule.ruleId,
          result: result,
        ));

        LoggerService.instance.d(
          'Regra executada: ${rule.ruleName} -> ${result.success ? "SUCESSO" : "FALHA"}'
        );
      } catch (e) {
        final errorResult = ModuleDisciplineResult.failure(
          message: 'Erro inesperado ao executar regra ${rule.ruleName}: $e',
          ruleId: rule.ruleId,
          moduleId: context.moduleId,
        );
        
        results.add(errorResult);
        _resultsController.add(errorResult);
        
        LoggerService.instance.e(
          'Erro ao executar regra ${rule.ruleName}',
          error: e,
        );
      }
    }

    return results;
  }

  /// Executa regras para um módulo específico com dados opcionais
  Future<List<ModuleDisciplineResult>> executeRulesForModule(
    String moduleId, {
    Map<String, dynamic>? data,
  }) async {
    final context = ModuleDisciplineContext(
      moduleId: moduleId,
      data: data ?? {},
    );

    return executeRules(context);
  }

  /// Habilita/desabilita uma regra específica
  Future<bool> toggleRule(String moduleId, String ruleId, bool enabled) async {
    final module = _modules[moduleId];
    if (module == null) {
      LoggerService.instance.w('Módulo não encontrado: $moduleId');
      return false;
    }

    final rule = module.rules.firstWhere(
      (r) => r.ruleId == ruleId,
      orElse: () => throw StateError('Regra não encontrada: $ruleId'),
    );

    rule.isEnabled = enabled;
    
    LoggerService.instance.i(
      'Regra $ruleId do módulo $moduleId ${enabled ? "habilitada" : "desabilitada"}'
    );
    
    return true;
  }

  /// Obtém estatísticas dos módulos e regras
  Map<String, dynamic> getStatistics() {
    final totalRules = _modules.values
        .fold<int>(0, (sum, module) => sum + module.rules.length);
    
    final enabledRules = _modules.values
        .fold<int>(0, (sum, module) => 
            sum + module.rules.where((r) => r.isEnabled).length);

    return {
      'total_modules': _modules.length,
      'total_rules': totalRules,
      'enabled_rules': enabledRules,
      'modules': {
        for (final entry in _modules.entries)
          entry.key: {
            'name': entry.value.moduleName,
            'rules_count': entry.value.rules.length,
            'enabled_rules': entry.value.rules
                .where((r) => r.isEnabled).length,
            'rules': entry.value.rules.map((r) => {
              'id': r.ruleId,
              'name': r.ruleName,
              'enabled': r.isEnabled,
            }).toList(),
          },
      },
    };
  }

  /// Verifica se um módulo está registrado
  bool isModuleRegistered(String moduleId) {
    return _modules.containsKey(moduleId);
  }

  /// Obtém regras de um módulo específico
  List<ModuleRule> getRulesForModule(String moduleId) {
    final module = _modules[moduleId];
    return module?.rules ?? [];
  }

  /// Limpa todos os recursos
  Future<void> dispose() async {
    // Dispose de todos os módulos
    for (final module in _modules.values) {
      try {
        await module.dispose();
      } catch (e) {
        LoggerService.instance.e(
          'Erro ao dar dispose no módulo ${module.moduleId}',
          error: e,
        );
      }
    }
    
    _modules.clear();
    await _resultsController.close();
    
    LoggerService.instance.i('ModuleDisciplineEngine disposed');
  }
}

/// Facade para manter compatibilidade com código existente
/// Encaminha chamadas para o novo ModuleDisciplineEngine
@Deprecated('Use ModuleDisciplineEngine instead')
class DisciplineEngine {
  static final ModuleDisciplineEngine _delegate = ModuleDisciplineEngine.instance;
  
  static Stream<ModuleDisciplineResult> get results => _delegate.results;
  
  static Future<void> registerModule(ModuleDisciplineInterface module) => 
      _delegate.registerModule(module);
  
  static Future<void> unregisterModule(String moduleId) => 
      _delegate.unregisterModule(moduleId);
  
  static Future<List<ModuleDisciplineResult>> executeRulesForModule(
    String moduleId, {
    Map<String, dynamic>? data,
  }) => _delegate.executeRulesForModule(moduleId, data: data);
  
  static Map<String, dynamic> getStatistics() => _delegate.getStatistics();
  
  static Future<void> dispose() => _delegate.dispose();
}
