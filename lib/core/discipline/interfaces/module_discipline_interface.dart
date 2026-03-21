import 'package:disciplinum/core/events/event_bus.dart';

/// Interface abstrata para regras de disciplina de módulos
/// Cada módulo implementa suas próprias regras seguindo esta interface
abstract class ModuleDisciplineInterface {
  /// Identificador único do módulo
  String get moduleId;
  
  /// Nome do módulo para exibição
  String get moduleName;
  
  /// Lista de regras que este módulo disponibiliza
  List<ModuleRule> get rules;
  
  /// Inicializa as regras do módulo com as dependências necessárias
  Future<void> initializeRules();
  
  /// Limpa recursos do módulo
  Future<void> dispose();
}

/// Contrato para uma regra de disciplina de módulo
abstract class ModuleRule {
  /// Identificador único da regra
  String get ruleId;
  
  /// Nome da regra para exibição
  String get ruleName;
  
  /// Descrição do que a regra faz
  String get description;
  
  /// Se a regra está habilitada
  bool get isEnabled;
  
  /// Habilita/desabilita a regra
  set isEnabled(bool value);
  
  /// Verifica se a regra pode ser executada para o contexto fornecido
  bool canExecute(ModuleDisciplineContext context);
  
  /// Executa a regra e retorna o resultado
  Future<ModuleDisciplineResult> execute(ModuleDisciplineContext context);
}

/// Contexto de execução para regras de módulos
class ModuleDisciplineContext {
  final String moduleId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  ModuleDisciplineContext({
    required this.moduleId,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// Helper para obter um valor do data de forma segura
  T? getData<T>(String key) {
    final value = data[key];
    return value is T ? value : null;
  }
  
  /// Helper para verificar se uma chave existe no data
  bool hasData(String key) => data.containsKey(key);
}

/// Resultado da execução de uma regra de módulo
class ModuleDisciplineResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? metadata;
  final String ruleId;
  final String moduleId;
  
  ModuleDisciplineResult({
    required this.success,
    required this.message,
    this.metadata,
    required this.ruleId,
    required this.moduleId,
  });
  
  factory ModuleDisciplineResult.success({
    required String message,
    required String ruleId,
    required String moduleId,
    Map<String, dynamic>? metadata,
  }) {
    return ModuleDisciplineResult(
      success: true,
      message: message,
      ruleId: ruleId,
      moduleId: moduleId,
      metadata: metadata,
    );
  }
  
  factory ModuleDisciplineResult.failure({
    required String message,
    required String ruleId,
    required String moduleId,
  }) {
    return ModuleDisciplineResult(
      success: false,
      message: message,
      ruleId: ruleId,
      moduleId: moduleId,
    );
  }
}

/// Eventos do sistema de disciplina (compatíveis com EventBus)
abstract class DisciplineEvent extends AppEvent {
  final String moduleId;
  final String ruleId;
  
  DisciplineEvent({
    required this.moduleId,
    required this.ruleId,
    Map<String, dynamic>? data,
  }) : super(data: {
        'moduleId': moduleId,
        'ruleId': ruleId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?data,
      });
}

class RuleExecutedEvent extends DisciplineEvent {
  final ModuleDisciplineResult result;
  
  RuleExecutedEvent({
    required super.moduleId,
    required super.ruleId,
    required this.result,
  }) : super(data: {
        'success': result.success,
        'message': result.message,
        'metadata': result.metadata,
      });
}

class ModuleRegisteredEvent extends DisciplineEvent {
  final String moduleName;
  
  ModuleRegisteredEvent({
    required super.moduleId,
    required super.ruleId,
    required this.moduleName,
  }) : super(data: {
        'moduleName': moduleName,
      });
}
