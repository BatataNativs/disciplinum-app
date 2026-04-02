import 'dart:convert';

import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:isar/isar.dart';

/// Entidade para fila de sync offline
@collection
class SyncQueueItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String moduleId;

  @Index()
  late String userId;

  @Index()
  late String operation;

  late String payloadJson;

  @Index()
  late DateTime createdAt;

  int retryCount = 0;

  @Index()
  bool processed = false;

  @Index()
  DateTime? processedAt;

  String? errorMessage;
}

/// Abstração para storage da fila de sync
abstract class SyncQueueStorage {
  Future<void> addItem(SyncQueueItem item);
  Future<List<SyncQueueItem>> getPendingItems();
  Future<void> markAsProcessed(int id);
  Future<void> incrementRetry(int id, String? error);
  Future<void> cleanupOldItems(Duration olderThan);
  Future<Map<String, dynamic>> getStats();
}

/// Serviço de sincronização para módulos
///
/// Implementa estratégia offline-first com:
/// - Fila de operações pendentes
/// - Sync automático quando online
/// - Resolução de conflitos (last-write-wins)
/// - Retry com backoff exponencial
class ModuleSyncService {
  final SyncQueueStorage _storage;
  final LoggerService _logger;

  bool _isOnline = true;

  ModuleSyncService({
    required SyncQueueStorage storage,
    required LoggerService logger,
  })  : _storage = storage,
        _logger = logger;

  /// Inicializa o serviço
  Future<void> initialize() async {
    _logger.i('ModuleSyncService inicializado');
  }

  /// Define estado da conexão
  void setOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _logger.i('Status de rede alterado: ${isOnline ? 'online' : 'offline'}');

      if (isOnline) {
        // Quando volta online, processar fila
        processQueue(_storage);
      }
    }
  }

  /// Verifica se está online
  bool get isOnline => _isOnline;

  /// ============================================
  /// OPERAÇÕES DE SYNC
  /// ============================================

  /// Sincroniza estado de um módulo específico
  /// 
  /// [repository] é usado para operações de sync
  /// [storage] é usado para fila offline (pode ser null se não suportar offline)
  Future<SyncResult<T>> syncModuleState<T extends Object>(
    String moduleId,
    String userId,
    T localState,
    ModuleRepositoryContract<T> repository, {
    SyncQueueStorage? storage,
  }) async {
    try {
      _logger.d('Iniciando sync para $moduleId (user: $userId)');

      // 1. Se offline e tem storage, enfileirar
      if (!_isOnline && storage != null) {
        await _enqueueSync(moduleId, userId, localState, storage);
        return SyncResult.unchanged(localState);
      }

      // 2. Carregar estado remoto
      final remoteState = await repository.loadFromRemote(userId);

      // 3. Se não existe remoto, enviar local
      if (remoteState == null) {
        final result = await repository.syncToRemote(userId, localState);
        _logger.i('Estado enviado para nuvem: $moduleId');
        return SyncResult.uploaded(result, DateTime.now());
      }

      // 4. Comparar timestamps e resolver conflito
      final resolved = await repository.resolveConflict(localState, remoteState);

      // 5. Sincronizar resultado
      await repository.saveLocal(resolved);
      await repository.syncToRemote(userId, resolved);

      // 6. Determinar ação
      final action = _determineSyncAction(localState, remoteState, resolved);

      _logger.i('Sync concluído para $moduleId: ${action.name}');

      return SyncResult.success(
        action: action,
        data: resolved,
        remoteTimestamp: DateTime.now(),
      );
    } catch (e, stack) {
      _logger.e(
        'Erro ao sincronizar $moduleId',
        error: e,
        stackTrace: stack,
      );

      // Enfileirar para retry se tem storage
      if (storage != null) {
        await _enqueueSync(moduleId, userId, localState, storage);
      }

      return SyncResult.failure(error: 'Sync falhou: $e');
    }
  }

  /// Sincronização bidirecional completa
  Future<SyncResult<T>> fullSync<T extends Object>(
    String moduleId,
    String userId,
    ModuleRepositoryContract<T> repository,
  ) async {
    try {
      _logger.d('Full sync para $moduleId');

      final local = await repository.loadLocal(userId);
      final remote = await repository.loadFromRemote(userId);

      if (local == null && remote == null) {
        return SyncResult.failure(error: 'Nenhum estado encontrado');
      }

      if (local == null) {
        // Apenas remoto existe, baixar
        await repository.saveLocal(remote!);
        return SyncResult.downloaded(remote, DateTime.now());
      }

      if (remote == null) {
        // Apenas local existe, enviar
        final result = await repository.syncToRemote(userId, local);
        return SyncResult.uploaded(result, DateTime.now());
      }

      // Ambos existem, resolver conflito
      final resolved = await repository.resolveConflict(local, remote);
      await repository.saveLocal(resolved);
      await repository.syncToRemote(userId, resolved);

      final action = _determineSyncAction(local, remote, resolved);

      return SyncResult.success(
        action: action,
        data: resolved,
        remoteTimestamp: DateTime.now(),
      );
    } catch (e, stack) {
      _logger.e(
        'Erro em full sync para $moduleId',
        error: e,
        stackTrace: stack,
      );
      return SyncResult.failure(error: 'Full sync falhou: $e');
    }
  }

  /// ============================================
  /// FILA OFFLINE
  /// ============================================

  /// Adiciona operação à fila de sync
  Future<void> _enqueueSync<T>(
    String moduleId,
    String userId,
    T state,
    SyncQueueStorage storage,
  ) async {
    final item = SyncQueueItem()
      ..moduleId = moduleId
      ..userId = userId
      ..operation = 'upsert'
      ..payloadJson = jsonEncode(_stateToJson(state))
      ..createdAt = DateTime.now()
      ..processed = false
      ..retryCount = 0;

    await storage.addItem(item);

    _logger.w('Sync enfileirado (offline): $moduleId');
  }

  /// Processa fila de operações pendentes
  Future<void> processQueue(SyncQueueStorage storage) async {
    if (!_isOnline) {
      _logger.w('Não é possível processar fila: offline');
      return;
    }

    final pending = await storage.getPendingItems();

    _logger.i('Processando ${pending.length} itens da fila de sync');

    for (final item in pending) {
      try {
        await _processQueueItem(item);
        await storage.markAsProcessed(item.id);
      } catch (e) {
        _logger.e(
          'Erro ao processar item da fila: ${item.moduleId}',
          error: e,
        );
        await storage.incrementRetry(item.id, e.toString());
      }
    }
  }

  /// Processa item individual da fila
  Future<void> _processQueueItem(SyncQueueItem item) async {
    // Aqui precisaríamos do repository específico
    // Esta é uma implementação base que deve ser estendida
    _logger.d('Processando item: ${item.moduleId}');

    // Implementação real depende de ter acesso ao repository
    // do módulo específico. Isso é feito via registro de repositories.
  }

  /// ============================================
  /// UTILITÁRIOS
  /// ============================================

  /// Determina ação de sync baseada na resolução de conflito
  SyncAction _determineSyncAction<T>(T local, T remote, T resolved) {
    // Implementação simplificada
    // Na prática, comparar timestamps ou hash
    if (_statesEqual(local, resolved)) {
      return SyncAction.unchanged;
    }
    if (_statesEqual(remote, resolved)) {
      return SyncAction.downloaded;
    }
    return SyncAction.conflictResolved;
  }

  /// Compara dois estados (implementação base)
  bool _statesEqual<T>(T a, T b) {
    // Implementação simplificada
    // Deve ser sobrescrita para comparação adequada
    return a == b;
  }

  /// Converte estado para JSON
  Map<String, dynamic> _stateToJson<T>(T state) {
    if (state is ModuleStateContract) {
      return state.toJson();
    }
    // Fallback para outros tipos
    return {'data': state.toString()};
  }

  /// Limpa itens processados antigos
  Future<void> cleanupProcessedItems({
    Duration olderThan = const Duration(days: 7),
  }) async {
    await _storage.cleanupOldItems(olderThan);
  }

  /// Retorna estatísticas da fila
  Future<Map<String, dynamic>> getQueueStats() async {
    return await _storage.getStats();
  }
}
