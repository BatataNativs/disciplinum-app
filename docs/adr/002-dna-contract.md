# Architecture Decision Record (ADR) 002: DNA Contract (Contrato Invisível)

## Status
**Accepted** - 2026-04-02

## Context

O Disciplinum possui 9 módulos independentes, cada um com:
- Domínio de negócio único (foco, dieta, fumar, etc.)
- Regras de gamificação específicas
- Estrutura de dados própria
- Ciclo de vida independente

O desafio: garantir **consistência estrutural** sem **centralização de comportamento**.

## Decision

Adotar o conceito de **"DNA Contract"** ou **"Contrato Invisível"**:

> Padronizar o "esqueleto", não a "personalidade"

### Princípios Fundamentais

1. **Estrutura de Armazenamento Padronizada**
   - Todas as tabelas seguem mesmo formato: `user_id`, `state_data` (JSONB), timestamps
   - Unidade: um estado por usuário por módulo

2. **Gramática JSON Comum**
   - Todos os `state_data` contêm campos obrigatórios:
     ```json
     {
       "_schema_version": 1,
       "_module_id": "nome_modulo",
       "created_at": "ISO8601",
       "updated_at": "ISO8601"
     }
     ```
   - Campos específicos são adicionados após os obrigatórios

3. **Conceitos Equivalentes (não idênticos)**

   | Conceito | Focus | Diet | Money | Reading |
   |----------|-------|------|-------|---------|
   | Progresso | `sessions_completed` | `meals_on_time` | `money_saved` | `pages_read` |
   | Nível | `current_stage` | `streak_level` | `tier` | `reading_level` |
   | Evento | `session_completed` | `meal_logged` | `deposit` | `book_finished` |

4. **Ciclo de Vida Comum**
   - Todo módulo deve implementar: `iniciar`, `atualizar`, `calcular progresso`, `persistir`
   - Implementação específica é livre, mas fases são obrigatórias

## Consequences

### Positive

- ✅ **Independência preservada** - Módulos mantêm autonomia total
- ✅ **Consistência implícita** - Todos "falam a mesma língua" estrutural
- ✅ **Ferramentas genéricas** - Scripts de auditoria funcionam para todos
- ✅ **Evolução gradual** - Schema versioning permite mudanças suaves
- ✅ **Onboarding facilitado** - Novos devs entendem rápido o padrão

### Negative

- ⚠️ **Curva de aprendizado** - Time precisa entender a filosofia
- ⚠️ **Disciplina necessária** - Sem validação automática, tende a divergir
- ⚠️ **Documentação vital** - Padrão só funciona se estiver documentado

## Implementation

### Contratos Dart

```dart
abstract class ModuleStateContract {
  String get moduleId;           // 'focus', 'diet', etc.
  int get schemaVersion;         // Versionamento
  DateTime get createdAt;
  DateTime get updatedAt;
  Map<String, dynamic> toJson(); // Para Supabase
}
```

### Estrutura JSON Obrigatória

```json
{
  "_schema_version": 1,
  "_module_id": "focus",
  "created_at": "2024-03-27T10:30:00.000Z",
  "updated_at": "2024-03-27T10:30:00.000Z",
  "stage": { "id": "bronze", "name": "Bronze", "order": 1 },
  "progress": { "current": 42, "goal": 100 },
  "...": "campos específicos do módulo"
}
```

## References

- [Module Contract Guide](../docs/MODULE_CONTRACT_GUIDE.md)
- ADR 001: Modular Architecture with Contracts
- ADR 003: JSONB Versioning Strategy
- `lib/core/modules/contracts/module_state_contract.dart`

## Quote

> "Modularidade sem padrão mínimo não é independência. É entropia."
