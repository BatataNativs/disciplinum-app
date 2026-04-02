import 'package:disciplinum/core/modules/contracts/module_contracts.dart';

/// Métrica de progresso base implementando [ProgressMetricContract]
/// 
/// Usada por todos os módulos para representar métricas numéricas.
class BaseProgressMetric implements ProgressMetricContract {
  @override
  final String fieldName;

  @override
  final Type valueType;

  final num _currentValue;
  final num? _goalValue;

  BaseProgressMetric({
    required this.fieldName,
    required num currentValue,
    num? goalValue,
  })  : valueType = currentValue.runtimeType,
        _currentValue = currentValue,
        _goalValue = goalValue;

  @override
  dynamic get currentValue => _currentValue;

  @override
  dynamic get goalValue => _goalValue;

  @override
  double? get progressPercentage {
    if (_goalValue == null || _goalValue == 0) return null;
    return (_currentValue / _goalValue).clamp(0.0, 1.0).toDouble();
  }
}

/// Estágio base implementando [StageContract]
/// 
/// Usado por todos os módulos para representar níveis/estágios.
class BaseStage implements StageContract {
  @override
  final String stageId;

  @override
  final String displayName;

  @override
  final int order;

  const BaseStage({
    required this.stageId,
    required this.displayName,
    required this.order,
  });

  @override
  bool isHigherThan(StageContract other) => order > other.order;

  @override
  bool isAtLeast(StageContract other) => order >= other.order;

  /// Estágios predefinidos para consistência
  static const BaseStage bronze = BaseStage(
    stageId: 'bronze',
    displayName: 'Bronze',
    order: 1,
  );

  static const BaseStage silver = BaseStage(
    stageId: 'silver',
    displayName: 'Prata',
    order: 2,
  );

  static const BaseStage gold = BaseStage(
    stageId: 'gold',
    displayName: 'Ouro',
    order: 3,
  );

  static const BaseStage diamond = BaseStage(
    stageId: 'diamond',
    displayName: 'Diamante',
    order: 4,
  );

  static const List<BaseStage> defaultStages = [bronze, silver, gold, diamond];
}

/// Helper para criar estrutura JSON padronizada
/// 
/// Garante que todos os campos obrigatórios do contrato estejam presentes.
class ModuleStateJsonBuilder {
  final String moduleId;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Map<String, dynamic> _customFields = {};

  ModuleStateJsonBuilder({
    required this.moduleId,
    this.schemaVersion = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Adiciona campo customizado
  void setField(String key, dynamic value) {
    _customFields[key] = value;
  }

  /// Adiciona métrica de progresso
  void setProgressMetric(ProgressMetricContract metric) {
    setField('progress_${metric.fieldName}', {
      'current': metric.currentValue,
      'goal': metric.goalValue,
      'percentage': metric.progressPercentage,
    });
  }

  /// Adiciona estágio atual
  void setStage(StageContract stage) {
    setField('stage', {
      'id': stage.stageId,
      'name': stage.displayName,
      'order': stage.order,
    });
  }

  /// Constrói o JSON final
  Map<String, dynamic> build() {
    return {
      '_schema_version': schemaVersion,
      '_module_id': moduleId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      ..._customFields,
    };
  }
}

/// Validador de conformidade com contrato
/// 
/// Verifica se um JSON segue o contrato mínimo.
class ContractComplianceValidator {
  /// Valida estrutura JSON contra o contrato
  static List<String> validateJson(
    Map<String, dynamic> json,
    String moduleId,
  ) {
    final errors = <String>[];

    // Campos obrigatórios
    final requiredFields = [
      '_schema_version',
      '_module_id',
      'created_at',
      'updated_at',
    ];

    for (final field in requiredFields) {
      if (!json.containsKey(field)) {
        errors.add('Campo obrigatório ausente: $field');
      }
    }

    // Valida tipo de schema_version
    final version = json['_schema_version'];
    if (version != null && version is! int) {
      errors.add('_schema_version deve ser int, é ${version.runtimeType}');
    }

    // Valida module_id
    final jsonModuleId = json['_module_id'];
    if (jsonModuleId != null && jsonModuleId != moduleId) {
      errors.add('_module_id mismatch: esperado $moduleId, é $jsonModuleId');
    }

    // Valida timestamps
    for (final field in ['created_at', 'updated_at']) {
      final value = json[field];
      if (value != null && value is! String) {
        errors.add('$field deve ser String (ISO8601)');
      }
    }

    return errors;
  }

  /// Verifica se JSON é válido
  static bool isValid(Map<String, dynamic> json, String moduleId) {
    return validateJson(json, moduleId).isEmpty;
  }

  /// Lança exceção se inválido
  static void assertValid(Map<String, dynamic> json, String moduleId) {
    final errors = validateJson(json, moduleId);
    if (errors.isNotEmpty) {
      throw ModuleContractException(
        message: 'JSON inválido: ${errors.join(', ')}',
        moduleId: moduleId,
      );
    }
  }
}
