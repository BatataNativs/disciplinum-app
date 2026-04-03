# Architecture Decision Record (ADR) 003: JSONB Schema Versioning

## Status
**Accepted** - 2026-04-02

## Context

O Disciplinum usa PostgreSQL com JSONB para armazenar estado de módulos. Isso oferece:
- **Flexibilidade** - Cada módulo tem estrutura própria
- **Performance** - JSONB é indexável e queryável
- **Evolução** - Schema pode mudar sem migrações pesadas

O problema: sem versionamento, mudanças no formato do JSON quebram código existente.

## Decision

Implementar **Schema Versioning explícito dentro do JSONB**:

1. Campo obrigatório `_schema_version` em todo `state_data`
2. Versão começa em `1` e incrementa em mudanças incompatíveis
3. Código deve verificar versão antes de deserializar
4. Migrações de dados acontecem "on-read" quando possível

## Consequences

### Positive

- ✅ **Evolução segura** - Mudanças de schema não quebram código
- ✅ **Compatibilidade** - Dados antigos continuam funcionando
- ✅ **Rollback possível** - Versões anteriores são reconhecíveis
- ✅ **Auditoria** - É possível rastrear evolução dos dados

### Negative

- ⚠️ **Complexidade extra** - Código precisa verificar versão
- ⚠️ **Migrações on-read** - Custo de CPU para converter dados antigos
- ⚠️ **Documentação** - Cada versão precisa ser documentada

## Implementation

### Estrutura JSON Versionada

```json
{
  "_schema_version": 2,
  "_module_id": "focus",
  "created_at": "2024-03-27T10:30:00.000Z",
  "updated_at": "2024-03-27T10:30:00.000Z",
  "...": "dados específicos da versão 2"
}
```

### SQL: Adicionar Versionamento

```sql
-- Atualizar dados existentes
UPDATE focus_gamification_states 
SET state_data = jsonb_set(
    state_data, 
    '{_schema_version}', 
    '1'::jsonb
)
WHERE state_data->>'_schema_version' IS NULL;
```

### Dart: Verificação de Versão

```dart
class SchemaVersionValidator {
  static const int currentVersion = 2;

  static Map<String, dynamic> migrateIfNeeded(
    Map<String, dynamic> data,
  ) {
    final version = data['_schema_version'] as int? ?? 1;

    if (version == currentVersion) return data;

    // Aplicar migrações sequenciais
    var migrated = data;
    for (var v = version; v < currentVersion; v++) {
      migrated = _migrateFrom(v, migrated);
    }

    return migrated;
  }

  static Map<String, dynamic> _migrateFrom(
    int fromVersion,
    Map<String, dynamic> data,
  ) {
    switch (fromVersion) {
      case 1:
        // Migração de v1 para v2
        return {
          ...data,
          '_schema_version': 2,
          'new_field': data['old_field'], // exemplo
        };
      default:
        return data;
    }
  }
}
```

## Migration Strategy

### Quando incrementar versão?

| Mudança | Ação |
|---------|------|
| Adicionar campo opcional | Não incrementa (v1 compatível) |
| Renomear campo | Incrementa (v1 não reconhece) |
| Remover campo | Incrementa (v1 pode esperar campo) |
| Mudar tipo de campo | Incrementa (quebra deserialização) |
| Alterar estrutura aninhada | Incrementa (path muda) |

### Estratégias de Migração

1. **On-Read (Lazy)**
   - Dados são migrados quando lidos
   - Custo pago sob demanda
   - Boa para mudanças simples

2. **Batch (Eager)**
   - Migração SQL atualiza todos os registros
   - Custo pago uma vez
   - Boa para mudanças complexas

3. **Dual-Write (Shadow)**
   - Escreve em ambos os formatos durante transição
   - Complexo mas zero downtime
   - Boa para sistemas críticos

## References

- [Module Contract Guide](../docs/MODULE_CONTRACT_GUIDE.md)
- ADR 002: DNA Contract
- `lib/core/modules/contracts/module_state_contract.dart`
- `supabase/migrations/20260402151000_add_schema_versioning_to_gamification.sql`

## Quote

> "Sem versionamento, JSONB é um campo de minas terrestres. Com versionamento, é um banco de dados evolutivo."
