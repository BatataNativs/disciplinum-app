/// Module Contracts Library
///
/// Este arquivo exporta todos os contratos definidos para módulos.
/// Use este barrel file para importar contratos:
///
/// ```dart
/// import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
/// ```
///
/// Contratos disponíveis:
/// - [ModuleStateContract] - Contrato base para estados de módulos
/// - [ModuleEventContract] - Contrato para eventos de módulos
/// - [ModuleRepositoryContract] - Contrato para repositories
///
/// Implementações auxiliares:
/// - [ProgressMetricContract] - Métricas de progresso
/// - [StageContract] - Estágios/níveis
/// - [ModuleEventCategory] - Categorias de eventos
/// - [RepositoryStatus] - Status de repository
/// - [SyncResult] - Resultado de sync
/// - [SyncAction] - Ações de sync
///
/// Exceptions:
/// - [ModuleContractException] - Violação de contrato
/// - [RepositoryException] - Erro de repository
///
/// Utilitários:
/// - [ModuleStateValidator] - Validador de conformidade
/// - [EventEmitterMixin] - Mixin para emissão de eventos

library;

export 'module_state_contract.dart';
export 'module_event_contract.dart';
export 'module_repository_contract.dart';
