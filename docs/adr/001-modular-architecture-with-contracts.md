# Architecture Decision Record (ADR) 001: Modular Architecture with Invisible Contracts

## Status
**Accepted** - 2026-04-02

## Context

O Disciplinum possui 9 módulos independentes (Smoking, Focus, Diet, Money Saving, Reading, Binge Eating, Adult Content, Procrastination, Spending), cada um com:
- Domínio de negócio completamente diferente
- Regras de gamificação específicas
- Persistência local (Isar) e remota (Supabase)
- Ciclo de vida e eventos próprios

O desafio arquitetural era garantir **consistência estrutural** sem **centralização de lógica**.

## Decision

Adotamos uma arquitetura de **"Contratos Invisíveis"** (Invisible Contracts):

1. **Padronizar infraestrutura, não comportamento**
2. **Contratos Dart** definem interface mínima
3. **Cada módulo implementa independentemente**
4. **Validação automática** garante conformidade

### Contratos Definidos

```dart
// Contrato base para estados
abstract class ModuleStateContract {
  String get moduleId;        // 'focus', 'diet', etc.
  int get schemaVersion;      // Versionamento
  DateTime get createdAt;
  DateTime get updatedAt;
  Map<String, dynamic> toJson();
  List<ProgressMetricContract> get progressMetrics;
  StageContract get currentStage;
}

// Contrato para eventos
abstract class ModuleEventContract {
  String get eventType;
  String get moduleId;
  ModuleEventCategory get category;
  Map<String, dynamic> get payload;
}

// Contrato para repositories
abstract class ModuleRepositoryContract<T> {
  String get moduleId;
  Future<T> saveLocal(T state);
  Future<T?> loadLocal(String userId);
  Future<T> syncToRemote(String userId, T state);
  Future<T> resolveConflict(T local, T remote);
}
```

### Estrutura JSON Padronizada

Todo `state_data` no Supabase segue:

```json
{
  "_schema_version": 1,
  "_module_id": "nome_modulo",
  "created_at": "2024-03-27T10:30:00.000Z",
  "updated_at": "2024-03-27T10:30:00.000Z",
  "stage": { "id": "bronze", "name": "Bronze", "order": 1 },
  "progress_metric": { "current": 42, "goal": 100, "percentage": 0.42 },
  // ... campos específicos
}
```

## Consequences

### Positive

- ✅ **Independência real** - Módulos podem ser removidos/adicionados sem afetar outros
- ✅ **Consistência implícita** - Todos "falam a mesma língua" estrutural
- ✅ **Testabilidade** - Contratos permitem mocks e testes unitários
- ✅ **Evolução gradual** - Schema versioning permite migrações suaves
- ✅ **Auditoria automática** - Scripts verificam conformidade

### Negative

- ⚠️ **Curva de aprendizado** - Devs precisam entender os contratos
- ⚠️ **Overhead inicial** - Mais código boilerplate por módulo
- ⚠️ **Validação necessária** - Requer CI/CD para garantir conformidade

## Alternatives Considered

### 1. Engine Centralizada ❌
**Proposta:** GamificationEngine central processa tudo
**Contra:** Centralização mata independência dos módulos

### 2. Totalmente Desacoplado ❌
**Proposta:** Zero padrões, cada módulo faz do jeito que quiser
**Contra:** Vira "zoológico" - cada um com estrutura diferente

### 3. Biblioteca Compartilhada ⚠️
**Proposta:** Package com classes base compartilhadas
**Contra:** Ainda cria acoplamento indireto, versões conflitantes

## Implementation

- **2026-04-02** - Contratos criados em `lib/core/modules/contracts/`
- **2026-04-02** - Migrações SQL padronizadas no Supabase
- **2026-04-02** - Script de auditoria implementado
- **Next** - Atualizar todos os 9 módulos para implementar contratos

## References

- [Module Contract Guide](../../docs/MODULE_CONTRACT_GUIDE.md)
- [Contract Helpers](../../lib/core/modules/contracts/contract_helpers.dart)
- [Example: FocusModuleState](../../lib/features/modules/focus/domain/entities/focus_module_state.dart)
