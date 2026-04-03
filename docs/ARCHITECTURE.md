# Arquitetura do Disciplinum

## 🎯 Visão Geral

Disciplinum é um aplicativo de **desenvolvimento pessoal** com **9 módulos independentes**, cada um focado em uma área específica de disciplina:

- 🚭 Smoking (parar de fumar)
- 🧘 Focus (foco e produtiprodutividade)
- 🍽️ Diet (controlar dieta)
- 💰 Money Saving (desafio da poupança)
- 📚 Reading (leitura)
- 🍔 Binge Eating (evitar compulsão alimentar)
- 🔞 Adult Content (evitar conteúdo adulto)
- ⏱️ Procrastination (evitar procrastinação)
- 💳 Spending (controle de gastos)

## 🏗️ Arquitetura de Alto Nível

### Paradigma: Modular Monolith com Contratos

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (Disciplinum)                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Core (Compartilhado)                    │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐  │   │
│  │  │   Isar      │  │  Riverpod    │  │  Supabase   │  │   │
│  │  │  (Local DB) │  │  (State)     │  │  (Remote)   │  │   │
│  │  └─────────────┘  └──────────────┘  └─────────────┘  │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐  │   │
│  │  │   Sync      │  │  Contracts   │  │   Logger    │  │   │
│  │  │  Service    │  │  (DNA)       │  │             │  │   │
│  │  └─────────────┘  └──────────────┘  └─────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │ Smoking │ │  Focus  │ │  Diet   │ │  Money  │ │ Reading ││
│  │ Module  │ │ Module  │ │ Module  │ │ Saving  │ │ Module  ││
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘│
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │
│  │  Binge  │ │  Adult  │ │Procrast.│ │ Spending│           │
│  │ Eating  │ │ Content │ │ Module  │ │ Module  │           │
│  │ Module  │ │ Module  │ │         │ │         │           │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘           │
└─────────────────────────────────────────────────────────────┘
```

## 🧬 O "Contrato Invisível" (DNA Comum)

Todos os módulos seguem um **contrato mínimo** que garante consistência sem comprometer independência:

### Contratos Dart

```dart
// Contrato base para estados
abstract class ModuleStateContract {
  String get moduleId;        // 'focus', 'diet', etc.
  int get schemaVersion;      // Versionamento
  DateTime get createdAt;
  DateTime get updatedAt;
  Map<String, dynamic> toJson();
}

// Contrato para eventos
abstract class ModuleEventContract {
  String get eventType;
  String get moduleId;
  DateTime get timestamp;
  Map<String, dynamic> get payload;
}

// Contrato para repositories
abstract class ModuleRepositoryContract<T> {
  String get moduleId;
  Future<T> saveLocal(T state);
  Future<T?> loadLocal(String userId);
  Future<T> syncToRemote(String userId, T state);
}
```

### Estrutura JSON Padronizada

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

## 📦 Estrutura de Módulo

Cada módulo é autônomo e segue esta estrutura:

```
lib/features/modules/{module_name}/
├── domain/
│   ├── entities/
│   │   ├── {module}_module_state.dart          # State + Contrato
│   │   └── {module}_events.dart                # Eventos
│   └── repositories/
│       └── {module}_module_repository.dart      # Repository + Contrato
├── gamification/
│   └── domain/
│       ├── entities/
│       │   └── {module}_gamification_entity.dart # Isar Entity
│       └── repositories/
│           └── {module}_gamification_repository.dart
└── presentation/
    ├── screens/
    │   └── {module}_screen.dart
    └── widgets/
        └── {module}_specific_widgets.dart
```

## 💾 Camada de Dados

### Isar (Banco Local)

```dart
@collection
class SmokingGamificationEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  late String earnedInsignias;  // JSON
  late String earnedMedalhas;   // JSON
  late int consecutiveDays;
  late DateTime lastUpdated;

  /// Converte de/para ModuleState
  SmokingModuleState toModuleState() { /* ... */ }
  factory SmokingGamificationEntity.fromModuleState(...) { /* ... */ }
}
```

### Supabase (Banco Remoto)

```sql
-- Tabela padronizada para cada módulo
CREATE TABLE smoking_gamification_states (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  state_data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- RLS: Row Level Security
ALTER TABLE smoking_gamification_states ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own data"
  ON smoking_gamification_states FOR SELECT
  USING (auth.uid() = user_id);
```

## 🔄 Sincronização Offline-First

### Arquitetura de Sync

```
┌──────────────────────────────────────────┐
│           Flutter App                     │
│  ┌──────────┐     ┌──────────────────┐  │
│  │   Isar   │◄───►│  Sync Service    │  │
│  │ (Local)  │     │                  │  │
│  └──────────┘     │  ┌────────────┐   │  │
│                   │  │ Offline    │   │  │
│                   │  │ Queue      │   │  │
│                   │  └────────────┘   │  │
│                   └──────────────────┘  │
└──────────────────────────────────────────┘
                    │
                    │ HTTPS
                    ▼
┌──────────────────────────────────────────┐
│           Supabase                       │
│  ┌──────────────────────────────────┐  │
│  │  PostgreSQL + JSONB States        │  │
│  └──────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

### Estratégia de Conflito: Last-Write-Wins

```dart
Future<SyncResult> syncModuleState(...) async {
  final localTime = localState.updatedAt;
  final remoteTime = DateTime.parse(remoteState['updated_at']);

  if (localTime.isAfter(remoteTime)) {
    // Local é mais recente → Envia para nuvem
    await _pushToRemote(moduleId, userId, localState);
  } else if (remoteTime.isAfter(localTime)) {
    // Remoto é mais recente → Baixa para local
    await _applyRemoteState(moduleId, userId, remoteState);
  }
}
```

## 🎮 State Management (Riverpod)

### Hierarquia de Providers

```dart
// Provider de estado do módulo
final smokingModuleStateProvider = StateNotifierProvider<SmokingModuleNotifier, SmokingModuleState>((ref) {
  final repository = ref.watch(smokingModuleRepositoryProvider);
  return SmokingModuleNotifier(repository);
});

// Provider de autenticação
final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(supabaseUserProvider);
  return user?.id ?? 'guest_user';
});

// Provider de sync
final moduleSyncServiceProvider = Provider<ModuleSyncService>((ref) {
  final storage = ref.watch(syncQueueStorageProvider);
  final logger = ref.watch(loggerServiceProvider);
  return ModuleSyncService(storage: storage, logger: logger);
});
```

## 🛡️ Segurança

### Autenticação

- **Supabase Auth**: JWT tokens
- **Guest Mode**: ID temporário para uso sem login
- **RLS**: Row Level Security garante isolamento de dados

### Privacidade

- Dados sensíveis apenas no dispositivo
- Sincronização criptografada (HTTPS/TLS)
- Nenhum dado pessoal compartilhado

## 📊 Auditoria e Qualidade

### Scripts de Verificação

```bash
# Verifica conformidade de todos os módulos
dart scripts/full_compliance_audit.dart

# Valida migrações SQL
dart scripts/validate_migrations.dart

# Análise estática
flutter analyze
```

### Checklist de Conformidade

- [ ] Implementa `ModuleStateContract`
- [ ] Implementa `ModuleRepositoryContract`
- [ ] Tem `schemaVersion` >= 1
- [ ] JSON segue estrutura padronizada
- [ ] RLS ativo no Supabase
- [ ] Triggers de `updated_at` configurados

## 🚀 Fluxo de Desenvolvimento

### Adicionando um Novo Módulo

1. **Criar estrutura de diretórios**
2. **Implementar contratos** (State, Repository, Events)
3. **Criar migração SQL** (tabela + RLS)
4. **Implementar repository** (Isar + Supabase)
5. **Criar Notifier** (Riverpod)
6. **Criar UI** (Screens + Widgets)
7. **Validar** (`full_compliance_audit.dart`)

### Evolução de Schema

```dart
// Quando precisar mudar o formato do estado
class SchemaVersionValidator {
  static const int currentVersion = 2;

  static Map<String, dynamic> migrateIfNeeded(Map<String, dynamic> data) {
    final version = data['_schema_version'] as int? ?? 1;

    if (version == currentVersion) return data;

    // Aplicar migrações sequenciais
    var migrated = data;
    for (var v = version; v < currentVersion; v++) {
      migrated = _migrateFrom(v, migrated);
    }
    return migrated;
  }
}
```

## 📚 Documentação Relacionada

- [Module Contract Guide](MODULE_CONTRACT_GUIDE.md) - Detalhes dos contratos
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Como contribuir
- ADRs em `docs/adr/`:
  - [001-modular-architecture-with-contracts.md](adr/001-modular-architecture-with-contracts.md)
  - [002-dna-contract.md](adr/002-dna-contract.md)
  - [003-jsonb-versioning.md](adr/003-jsonb-versioning.md)
  - [004-offline-first.md](adr/004-offline-first.md)

## 🎯 Métricas

- **9 módulos** independentes
- **100% compliance** com contratos
- **< 50ms** para queries locais (Isar)
- **Offline-first** - funciona sem internet
- **Zero warnings** em `flutter analyze`

---

**Princípio Fundamental**: *"Modularidade sem padrão mínimo não é independência. É entropia."*
