# Architecture Decision Record (ADR) 004: Offline-First Sync Strategy

## Status
**Accepted** - 2026-04-02

## Context

O Disciplinum é um app mobile que precisa funcionar mesmo sem internet:
- Usuários podem ter conectividade intermitente
- Dados de gamificação não podem ser perdidos
- Experiência deve ser fluida independente da rede

O desafio: garantir **consistência de dados** entre dispositivo local (Isar) e nuvem (Supabase) com **resolução de conflitos** quando houver divergências.

## Decision

Adotar estratégia **Offline-First com Last-Write-Wins**:

1. **Fonte de verdade primária**: Banco local (Isar)
2. **Sincronização**: Background quando online
3. **Conflitos**: Resolvido por timestamp (quem escreveu por último, ganha)
4. **Fila offline**: Operações enfileiradas quando offline

## Consequences

### Positive

- ✅ **UX fluida** - App funciona sem internet
- ✅ **Baixa latência** - Leituras são sempre locais
- ✅ **Resiliência** - Dados persistem mesmo offline
- ✅ **Simplicidade** - Last-write-wins é fácil de entender

### Negative

- ⚠️ **Perda de dados possível** - Escritas simultâneas perdem uma
- ⚠️ **Não é merge inteligente** - Conflitos de campo não são resolvidos
- ⚠️ **Clock skew** - Diferença de horário entre dispositivos causa problemas

## Implementation

### Arquitetura de Sync

```
┌─────────────────────────────────────────┐
│              Flutter App                │
├─────────────────────────────────────────┤
│  ┌─────────┐    ┌───────────────┐      │
│  │  Isar   │◄──►│  Sync Service │      │
│  │ (Local) │    │               │      │
│  └─────────┘    └───────┬───────┘      │
│                         │              │
│  ┌──────────────────────┴─────────┐    │
│  │      Offline Queue (Isar)      │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│           Supabase (PostgreSQL)         │
│         ┌──────────────────┐          │
│         │ gamification_states│          │
│         └──────────────────┘          │
└─────────────────────────────────────────┘
```

### Sync Queue

```dart
@collection
class SyncQueueItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String moduleId;

  @Index()
  late String userId;

  @Index()
  late String operation; // 'upsert', 'delete'

  late String payloadJson;
  late DateTime createdAt;
  int retryCount = 0;

  @Index()
  bool processed = false;
}
```

### Algoritmo de Sync

```dart
Future<SyncResult> syncModuleState(
  String moduleId,
  String userId,
  ModuleStateContract localState,
) async {
  // 1. Carregar estado remoto
  final remoteState = await _loadRemoteState(moduleId, userId);

  // 2. Se não existe remoto, enviar local
  if (remoteState == null) {
    await _pushToRemote(moduleId, userId, localState);
    return SyncResult.success(SyncAction.uploaded);
  }

  // 3. Comparar timestamps (last-write-wins)
  final localTime = localState.updatedAt;
  final remoteTime = DateTime.parse(remoteState['updated_at']);

  if (localTime.isAfter(remoteTime)) {
    await _pushToRemote(moduleId, userId, localState);
    return SyncResult.success(SyncAction.uploaded);
  } else if (remoteTime.isAfter(localTime)) {
    await _applyRemoteState(moduleId, userId, remoteState);
    return SyncResult.success(SyncAction.downloaded);
  } else {
    return SyncResult.success(SyncAction.unchanged);
  }
}
```

### Resolução de Conflitos

| Cenário | Ação |
|---------|------|
| Local mais recente | Sobrescreve remoto |
| Remoto mais recente | Sobrescreve local |
| Tiempos iguais | Mantém local (empate favorece local) |
| Conflito de campo | Resolvido por timestamp geral (não por campo) |

## Alternatives Considered

### 1. CRDT (Conflict-free Replicated Data Types)
**Contra**: Complexidade alta, overkill para o caso de uso

### 2. Operational Transformation
**Contra**: Complexidade muito alta, requer servidor especializado

### 3. Custom Merge Functions
**Contra**: Cada módulo precisaria implementar lógica de merge

### 4. Event Sourcing
**Contra**: Mudança arquitetural massiva, não justifica

## Network State Observer

```dart
/// Monitora estado da rede e dispara sync quando online
@riverpod
class NetworkStateObserver extends _$NetworkStateObserver {
  @override
  Stream<NetworkState> build() {
    return Connectivity().onConnectivityChanged
      .map(_mapToNetworkState);
  }
}

/// Provider que reage a mudanças de rede
@riverpod
Future<void> autoSyncOnNetworkChange(Ref ref) async {
  final networkState = await ref.watch(networkStateObserverProvider.future);

  if (networkState == NetworkState.online) {
    final queue = ref.read(offlineSyncQueueProvider);
    await queue.processQueue();
  }
}
```

## References

- [Module Contract Guide](../docs/MODULE_CONTRACT_GUIDE.md)
- ADR 002: DNA Contract
- ADR 003: JSONB Versioning
- `lib/core/modules/sync/module_sync_service.dart`
- `lib/core/network/network_state_observer.dart`

## Quote

> "Offline-first não é sobre ignorar a nuvem. É sobre respeitar a experiência do usuário primeiro."
