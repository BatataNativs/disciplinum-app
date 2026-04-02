/// Contrato base que todo estado de módulo deve implementar
/// 
/// Este contrato define o "DNA" comum entre todos os módulos, sem
/// centralizar a lógica de negócio. Cada módulo mantém sua independência
/// mas segue uma estrutura padronizada para facilitar:
/// - Sincronização com Supabase
/// - Auditoria de conformidade
/// - Evolução do schema (versionamento)
/// 
/// Princípio: Padronizar infraestrutura, não comportamento.
abstract class ModuleStateContract {
  /// Identificador único do módulo (ex: 'smoking', 'diet', 'focus')
  /// 
  /// Usado para:
  /// - Roteamento de sync
  /// - Nomeação de tabelas no Supabase
  /// - Logging e analytics
  String get moduleId;

  /// Versão do schema para controle de evolução
  /// 
  /// Permite migrações graduais do formato de dados.
  /// Iniciar em 1 e incrementar quando houver mudanças
  /// incompatíveis no formato do estado.
  int get schemaVersion;

  /// Timestamp de criação do registro
  DateTime get createdAt;

  /// Timestamp da última atualização
  DateTime get updatedAt;

  /// Serializa o estado para JSON (para Supabase)
  /// 
  /// Deve incluir todos os campos obrigatórios do contrato
  /// mais os campos específicos do módulo.
  /// 
  /// Campos obrigatórios no JSON:
  /// ```json
  /// {
  ///   "_schema_version": 1,
  ///   "_module_id": "module_name",
  ///   "created_at": "2024-03-27T10:30:00.000Z",
  ///   "updated_at": "2024-03-27T10:30:00.000Z",
  ///   // ... campos específicos
  /// }
  /// ```
  Map<String, dynamic> toJson();

  /// Serializa o estado para Map (para Isar/Local)
  /// 
  /// Geralmente delega para [toJson] mas permite
  /// otimizações específicas para storage local.
  Map<String, dynamic> toMap();

  /// Retorna métricas de progresso do módulo
  /// 
  /// Cada módulo define SEU conceito de progresso.
  /// Exemplos:
  /// - Focus: minutos de foco, sessões completadas
  /// - Diet: refeições no horário, streak de dias
  /// - Money: valor economizado, dias consecutivos
  List<ProgressMetricContract> get progressMetrics;

  /// Retorna o estágio/nível atual do módulo
  /// 
  /// Cada módulo define SEU sistema de estágios.
  /// Exemplos:
  /// - "bronze", "silver", "gold"
  /// - "level_1", "level_2"
  /// - "iniciante", "intermediario", "avancado"
  StageContract get currentStage;
}

/// Contrato para métricas de progresso
/// 
/// Define a estrutura mínima para qualquer métrica
/// de progresso, sem impor semântica específica.
abstract class ProgressMetricContract {
  /// Nome identificador da métrica (snake_case)
  /// 
  /// Exemplos:
  /// - 'sessions_completed'
  /// - 'money_saved'
  /// - 'meals_on_time'
  /// - 'pages_read'
  String get fieldName;

  /// Tipo do valor armazenado
  Type get valueType;

  /// Valor atual da métrica
  dynamic get currentValue;

  /// Meta/limite para esta métrica (pode ser null)
  dynamic get goalValue;

  /// Porcentagem de progresso (0.0 a 1.0)
  /// 
  /// Calculado como: currentValue / goalValue
  /// Retorna null se não houver meta definida
  double? get progressPercentage;
}

/// Contrato para estágios/níveis
/// 
/// Define a estrutura mínima para qualquer sistema
/// de estágios/níveis/graduação.
abstract class StageContract {
  /// Identificador único do estágio
  /// 
  /// Exemplos:
  /// - 'bronze'
  /// - 'level_5'
  /// - 'streak_30_days'
  String get stageId;

  /// Nome para exibição ao usuário
  String get displayName;

  /// Ordem/sequência para comparação
  /// 
  /// Quanto maior, mais "avançado" o estágio.
  /// Exemplo: bronze=1, silver=2, gold=3
  int get order;

  /// Verifica se este estágio é maior que outro
  bool isHigherThan(StageContract other) => order > other.order;

  /// Verifica se este estágio é igual ou maior que outro
  bool isAtLeast(StageContract other) => order >= other.order;
}

/// Exception lançada quando há violação do contrato
class ModuleContractException implements Exception {
  final String message;
  final String moduleId;
  final String? fieldName;

  ModuleContractException({
    required this.message,
    required this.moduleId,
    this.fieldName,
  });

  @override
  String toString() =>
      'ModuleContractException: $message (module: $moduleId, field: $fieldName)';
}

/// Validator para verificar conformidade com contrato
class ModuleStateValidator {
  /// Valida se um estado segue o contrato mínimo
  static void validate(ModuleStateContract state) {
    // Validar campos obrigatórios
    if (state.moduleId.isEmpty) {
      throw ModuleContractException(
        message: 'moduleId não pode ser vazio',
        moduleId: 'unknown',
        fieldName: 'moduleId',
      );
    }

    if (state.schemaVersion < 1) {
      throw ModuleContractException(
        message: 'schemaVersion deve ser >= 1',
        moduleId: state.moduleId,
        fieldName: 'schemaVersion',
      );
    }

    // Validar JSON gerado
    final json = state.toJson();
    _validateJsonStructure(json, state.moduleId);
  }

  /// Valida estrutura do JSON
  static void _validateJsonStructure(Map<String, dynamic> json, String moduleId) {
    final requiredFields = ['_schema_version', '_module_id', 'created_at', 'updated_at'];

    for (final field in requiredFields) {
      if (!json.containsKey(field)) {
        throw ModuleContractException(
          message: 'Campo obrigatório ausente no JSON: $field',
          moduleId: moduleId,
          fieldName: field,
        );
      }
    }
  }
}
