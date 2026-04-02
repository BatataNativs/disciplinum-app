/// Contrato para repositories de estado de módulos
///
/// Define a interface mínima para acesso a dados,
/// abstraindo a fonte (Isar local, Supabase remoto, cache, etc).
///
/// Cada módulo implementa seu próprio repository seguindo
/// este contrato, permitindo:
/// - Troca de implementação sem alterar UI
/// - Testes com mocks
/// - Cache transparente
/// - Sync offline-first
abstract class ModuleRepositoryContract<T extends Object> {
  /// ID do módulo que este repository gerencia
  String get moduleId;

  /// Inicializa o repository (conexões, índices, etc)
  Future<void> initialize();

  /// Libera recursos do repository
  Future<void> dispose();

  // ==================== OPERAÇÕES LOCAIS (ISAR) ====================

  /// Salva estado localmente (Isar)
  ///
  /// Deve ser rápido e não bloquear UI.
  /// Retorna o estado salvo (pode ter campos atualizados como id).
  Future<T> saveLocal(T state);

  /// Carrega estado local por userId
  ///
  /// Retorna null se não encontrado.
  Future<T?> loadLocal(String userId);

  /// Verifica se existe estado local
  Future<bool> existsLocal(String userId);

  /// Deleta estado local
  Future<void> deleteLocal(String userId);

  /// Lista todos os estados locais (para debug/admin)
  Future<List<T>> listAllLocal();

  // ==================== OPERAÇÕES REMOTAS (SUPABASE) ====================

  /// Sincroniza estado com Supabase (upsert)
  ///
  /// Deve tratar conflitos e erros de rede.
  Future<T> syncToRemote(String userId, T state);

  /// Carrega estado do Supabase
  ///
  /// Retorna null se não encontrado ou erro.
  Future<T?> loadFromRemote(String userId);

  /// Verifica se existe estado remoto
  Future<bool> existsRemote(String userId);

  /// Deleta estado remoto
  Future<void> deleteRemote(String userId);

  // ==================== SYNC E CONFLITOS ====================

  /// Resolve conflito entre estado local e remoto
  ///
  /// Estratégia padrão: last-write-wins (mais recente)
  /// Módulos podem sobrescrever para estratégias específicas.
  Future<T> resolveConflict(T local, T remote);

  /// Sincronização bidirecional completa
  ///
  /// 1. Carrega remoto
  /// 2. Resolve conflito se necessário
  /// 3. Salva resultado local e remoto
  /// 4. Retorna estado consolidado
  Future<T> fullSync(String userId);

  /// Verifica se há divergência local vs remoto
  ///
  /// Útil para mostrar indicador de sync pendente.
  Future<bool> hasDivergence(String userId);

  // ==================== UTILITÁRIOS ====================

  /// Limpa todos os dados (local e remoto) - cuidado!
  Future<void> clearAll(String userId);

  /// Exporta estado para JSON (backup/debug)
  Future<Map<String, dynamic>> exportToJson(String userId);

  /// Importa estado de JSON (restore/debug)
  Future<T> importFromJson(Map<String, dynamic> json);

  /// Status do repository
  RepositoryStatus get status;

  /// Stream de mudanças de status
  Stream<RepositoryStatus> get statusStream;
}

/// Status do repository
enum RepositoryStatus {
  /// Inicializando
  initializing,

  /// Pronto para uso
  ready,

  /// Operação em andamento
  busy,

  /// Erro (ver logs)
  error,

  /// Desconectado (offline)
  offline,

  /// Sincronizando
  syncing,

  /// Desativado/disposed
  disposed,
}

/// Resultado de operação de sync
class SyncResult<T> {
  final bool success;
  final SyncAction action;
  final T? data;
  final String? error;
  final DateTime? remoteTimestamp;
  final DateTime? localTimestamp;

  SyncResult.success({
    required this.action,
    this.data,
    this.remoteTimestamp,
    this.localTimestamp,
  })  : success = true,
        error = null;

  SyncResult.failure({
    required this.error,
  })  : success = false,
        action = SyncAction.none,
        data = null,
        remoteTimestamp = null,
        localTimestamp = null;

  /// Factory para resultado de upload
  factory SyncResult.uploaded(T data, DateTime remoteTimestamp) {
    return SyncResult.success(
      action: SyncAction.uploaded,
      data: data,
      remoteTimestamp: remoteTimestamp,
    );
  }

  /// Factory para resultado de download
  factory SyncResult.downloaded(T data, DateTime remoteTimestamp) {
    return SyncResult.success(
      action: SyncAction.downloaded,
      data: data,
      remoteTimestamp: remoteTimestamp,
    );
  }

  /// Factory para sem mudanças
  factory SyncResult.unchanged(T data) {
    return SyncResult.success(
      action: SyncAction.unchanged,
      data: data,
    );
  }

  /// Factory para conflito resolvido
  factory SyncResult.conflictResolved(T data, DateTime remoteTimestamp) {
    return SyncResult.success(
      action: SyncAction.conflictResolved,
      data: data,
      remoteTimestamp: remoteTimestamp,
    );
  }
}

/// Ações possíveis em sync
enum SyncAction {
  /// Nenhuma ação
  none,

  /// Enviado para nuvem
  uploaded,

  /// Baixado da nuvem
  downloaded,

  /// Sem mudanças
  unchanged,

  /// Conflito detectado e resolvido
  conflictResolved,

  /// Erro de conflito não resolvido
  conflictUnresolved,
}

/// Exceção específica para operações de repository
class RepositoryException implements Exception {
  final String message;
  final String moduleId;
  final RepositoryOperation? operation;
  final Object? originalError;

  RepositoryException({
    required this.message,
    required this.moduleId,
    this.operation,
    this.originalError,
  });

  @override
  String toString() {
    final op = operation != null ? ' (${operation!.name})' : '';
    return 'RepositoryException [$moduleId]$op: $message';
  }
}

/// Operações que podem gerar exceções
enum RepositoryOperation {
  saveLocal,
  loadLocal,
  deleteLocal,
  syncToRemote,
  loadFromRemote,
  deleteRemote,
  resolveConflict,
  fullSync,
}
