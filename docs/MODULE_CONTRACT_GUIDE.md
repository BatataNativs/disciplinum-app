# Guia do Contrato Invisível - Disciplinum

## O que é o "Contrato Invisível"?

O **Contrato Invisível** é o conjunto de regras mínimas que todos os módulos do Disciplinum devem seguir para garantir:

1. **Consistência estrutural** - Mesmo "esqueleto" para todos os módulos
2. **Interoperabilidade** - Capacidade de comunicação entre módulos quando necessário
3. **Manutenibilidade** - Facilidade de evolução e debug
4. **Testabilidade** - Padrões que facilitam testes automatizados

> 💡 **Filosofia**: Não centralizamos lógica, apenas padronizamos a **infraestrutura**.

---

## 🧬 O DNA Comum

### 1. Estrutura de Armazenamento (OBRIGATÓRIO)

Todo estado de módulo deve implementar [`ModuleStateContract`](lib/core/modules/contracts/module_state_contract.dart):

```dart
abstract class ModuleStateContract {
  String get moduleId;        // Ex: 'focus', 'diet', 'smoking'
  int get schemaVersion;      // Sempre >= 1
  DateTime get createdAt;     // ISO8601
  DateTime get updatedAt;     // ISO8601
  
  Map<String, dynamic> toJson();  // Para Supabase
  Map<String, dynamic> toMap();   // Para Isar
  
  List<ProgressMetricContract> get progressMetrics;
  StageContract get currentStage;
}
```

### 2. Estrutura JSON Padrão (OBRIGATÓRIO)

Todo `state_data` no Supabase deve seguir este formato:

```json
{
  "_schema_version": 1,
  "_module_id": "nome_do_modulo",
  "created_at": "2024-03-27T10:30:00.000Z",
  "updated_at": "2024-03-27T10:30:00.000Z",
  
  "stage": {
    "id": "bronze|silver|gold|diamond",
    "name": "Nome para exibição",
    "order": 1
  },
  
  "progress_metric_name": {
    "current": 42,
    "goal": 100,
    "percentage": 0.42
  },
  
  // ... campos específicos do módulo
}
```

### 3. Convenções de Nomenclatura

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Campos JSON | snake_case | `sessions_completed` |
| Classes Dart | PascalCase | `FocusModuleState` |
| Métodos | camelCase | `toJson()`, `copyWith()` |
| IDs de módulo | snake_case | `'focus'`, `'money_saving'` |
| IDs de estágio | snake_case | `'bronze'`, `'level_5'` |

### 4. Métricas de Progresso

Todo módulo deve expor suas métricas via `progressMetrics`:

```dart
List<ProgressMetricContract> get progressMetrics => [
  BaseProgressMetric(
    fieldName: 'nome_da_metrica',  // snake_case
    currentValue: valorAtual,
    goalValue: metaOpcional,
  ),
];
```

**Conceitos equivalentes entre módulos:**

| Conceito | Focus | Diet | Money | Reading |
|----------|-------|------|-------|---------|
| Progresso | sessions_completed | meals_on_time | money_saved | pages_read |
| Nível | current_stage | streak_level | tier | reading_level |
| Evento | session_completed | meal_logged | deposit | book_finished |

---

## 🏗️ Estrutura de Diretórios Padronizada

Cada módulo deve seguir esta estrutura:

```
lib/features/modules/{module_name}/
├── domain/
│   ├── entities/
│   │   ├── {module}_module_state.dart     # Implementa ModuleStateContract ✅
│   │   └── {module}_config_entity.dart    # Configurações do módulo
│   └── repositories/
│       └── {module}_repository.dart        # Implementa ModuleRepositoryContract ✅
├── data/
│   └── ...                                # Datasources, mappers, etc.
├── gamification/
│   ├── domain/
│   │   ├── entities/
│   │   │   └── {module}_gamification_entity.dart  # @collection Isar
│   │   └── services/
│   │       └── {module}_gamification_service.dart
│   └── presentation/
│       └── controllers/
│           └── {module}_notifier.dart      # StateNotifier
└── presentation/
    ├── screens/
    └── widgets/
```

---

## 🔄 Ciclo de Vida do Módulo

Todo módulo deve implementar este ciclo:

```
┌─────────────────────────────────────────────────────────────┐
│  1. init()                                                  │
│     └── Carrega estado local (Isar) ou cria novo          │
├─────────────────────────────────────────────────────────────┤
│  2. loadFromRemote()                                      │
│     └── Se online, carrega do Supabase                    │
├─────────────────────────────────────────────────────────────┤
│  3. resolveConflict()                                     │
│     └── Local vs Remoto (last-write-wins)                │
├─────────────────────────────────────────────────────────────┤
│  4. processEvent()                                        │
│     └── Reage a eventos do usuário                      │
├─────────────────────────────────────────────────────────────┤
│  5. updateState()                                         │
│     └── Atualiza métricas e verifica conquistas          │
├─────────────────────────────────────────────────────────────┤
│  6. persist()                                             │
│     └── Salva local (Isar) e sync remoto (Supabase)       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Checklist de Conformidade

Antes de considerar um módulo "pronto", verifique:

### Backend (Supabase)
- [ ] Tabela `{module}_gamification_states` existe
- [ ] Campos: `id`, `user_id`, `state_data`, `created_at`, `updated_at`
- [ ] `state_data` tem `DEFAULT '{}'`
- [ ] `UNIQUE(user_id)` constraint
- [ ] RLS habilitado com políticas CRUD
- [ ] Trigger `updated_at` configurado
- [ ] `_schema_version` no JSON

### Frontend (Flutter)
- [ ] `{Module}ModuleState` implementa `ModuleStateContract`
- [ ] `{Module}Repository` implementa `ModuleRepositoryContract`
- [ ] `schemaVersion` >= 1
- [ ] `toJson()` retorna JSON com campos obrigatórios
- [ ] `progressMetrics` retorna lista não vazia
- [ ] `currentStage` retorna Stage válido
- [ ] `moduleId` consistente com nome da tabela
- [ ] Testes de unidade para serialização JSON

### Eventos
- [ ] Eventos implementam `ModuleEventContract`
- [ ] Categorias de evento apropriadas
- [ ] Payload documentado

---

## 🧪 Validação Automática

Use o script de auditoria para verificar conformidade:

```bash
dart scripts/audit_module_compliance.dart --module=focus
```

Ou verifique todos os módulos:

```bash
dart scripts/audit_module_compliance.dart --all
```

---

## 📊 Evolução do Schema (Versionamento)

Quando precisar alterar a estrutura do estado:

1. **Incremente** `schemaVersion` (ex: 1 → 2)
2. **Documente** a mudança em `docs/schemas/state_data_v{version}.md`
3. **Implemente** migração no Supabase se necessário
4. **Atualize** o `fromJson()` para lidar com versões antigas

Exemplo de compatibilidade retroativa:

```dart
factory FocusModuleState.fromJson(Map<String, dynamic> json) {
  final version = json['_schema_version'] as int? ?? 1;
  
  switch (version) {
    case 1:
      return _fromJsonV1(json);
    case 2:
      return _fromJsonV2(json);
    default:
      throw UnsupportedError('Versão $version não suportada');
  }
}
```

---

## 🚨 Anti-Padrões (NÃO FAÇA)

❌ **Nunca** salve lógica de negócio diretamente no JSON:
```json
// ERRADO - lógica espalhada
{ "xp": 100, "level": 2 }  // cada módulo calcula diferente
```

✅ **Sempre** use métricas semânticas:
```json
// CERTO - conceito consistente
{ "sessions_completed": 10, "current_stage": "silver" }
```

❌ **Nunca** acesse Isar/Supabase direto da UI:
```dart
// ERRADO - na UI
await isar.focusGamifications.put(state);  // 🔴 NÃO!
```

✅ **Sempre** use o Repository:
```dart
// CERTO - via Repository
await repository.saveLocal(state);  // ✅ SIM!
```

❌ **Nunca** use tipos primitivos para IDs de módulo:
```dart
// ERRADO
int moduleId = 5;  // magic number
```

✅ **Sempre** use strings semânticas:
```dart
// CERTO
String moduleId = 'focus';  // claro e autodocumentado
```

---

## 🎓 Exemplos de Implementação

### Exemplo 1: Módulo Simples (Focus)

Ver: [`lib/features/modules/focus/domain/entities/focus_module_state.dart`](lib/features/modules/focus/domain/entities/focus_module_state.dart)

### Exemplo 2: Métricas Customizadas

```dart
@override
List<ProgressMetricContract> get progressMetrics => [
  // Métrica com meta
  BaseProgressMetric(
    fieldName: 'daily_goal_minutes',
    currentValue: todayMinutes,
    goalValue: 60,
  ),
  
  // Métrica sem meta (acompanhamento)
  BaseProgressMetric(
    fieldName: 'total_sessions',
    currentValue: totalSessions,
  ),
];
```

### Exemplo 3: Estágios Customizados

```dart
static const List<BaseStage> myStages = [
  BaseStage(stageId: 'novice', displayName: 'Novato', order: 1),
  BaseStage(stageId: 'apprentice', displayName: 'Aprendiz', order: 2),
  BaseStage(stageId: 'master', displayName: 'Mestre', order: 3),
];
```

---

## 📚 Recursos Relacionados

- [Contratos Dart](lib/core/modules/contracts/) - Código fonte dos contratos
- [Migrações SQL](../supabase/migrations/) - Estrutura do backend
- [FocusModuleState](lib/features/modules/focus/domain/entities/focus_module_state.dart) - Exemplo de implementação

---

## 🤝 Contribuindo

Ao criar um novo módulo:

1. Copie a estrutura do módulo Focus como template
2. Implemente todos os métodos do `ModuleStateContract`
3. Execute o script de auditoria
4. Submeta PR com evidências de conformidade

---

**Lembrete:** *"Modularidade sem padrão mínimo não é independência. É entropia."*

Última atualização: 2026-04-02
