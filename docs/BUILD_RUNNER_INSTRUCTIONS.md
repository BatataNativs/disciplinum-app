# 🔧 Build Runner Instructions - Isar Code Generation

## 📋 Problemas Atuais

Os erros que você está vindo são **normais e esperados**. Precisamos gerar os arquivos `.g.dart` do Isar usando o build_runner.

## ⚡ Comandos para Resolver

### 1. Rodar Build Runner (gera .g.dart files)
```bash
# No diretório raiz do projeto
flutter packages pub run build_runner build

# Ou se houver conflitos
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 2. Se o comando acima falhar, limpe e rode novamente:
```bash
# Limpa arquivos gerados anteriormente
flutter packages pub run build_runner clean

# Roda novamente
flutter packages pub run build_runner build
```

## 🎯 Após Rodar o Build Runner

### 3. Ativar Schemas no IsarService
Descomente as linhas no `lib/core/database/isar_service.dart`:

```dart
_isar = await Isar.open(
  [
    UserModuleStateSchema,
    ReadingBookEntitySchema,
    GamificationProgressSchema,
    DetectionSessionSchema,     // ✅ DESCOMENTAR
    MonitoringStateSchema,      // ✅ DESCOMENTAR
  ],
  directory: dbPath,
);
```

### 4. Ativar Getters
Descomente os getters:

```dart
/// Getter para DetectionSessions
IsarCollection<DetectionSession> get detectionSessions => database.detectionSessions; // ✅ DESCOMENTAR

/// Getter para MonitoringStates  
IsarCollection<MonitoringState> get monitoringStates => database.monitoringStates; // ✅ DESCOMENTAR
```

### 5. Substituir SessionPersistenceService
Renomeie os arquivos:
```bash
# Substitui versão temporária pela versão completa
mv lib/core/storage/session_persistence_service_temp.dart lib/core/storage/session_persistence_service_OLD.dart
mv lib/core/storage/session_persistence_service.dart lib/core/storage/session_persistence_service_ISAR.dart
cp lib/core/storage/session_persistence_service_ISAR.dart lib/core/storage/session_persistence_service.dart
```

## 🔍 Verificação

Após rodar o build_runner, você deve ver estes arquivos:
- ✅ `lib/core/storage/entities/detection_session_entity.g.dart`
- ✅ `lib/core/storage/entities/monitoring_state_entity.g.dart`

## 🚀 Teste

Depois de completar os passos acima, teste assim:

```dart
// Teste básico
final sessionService = SessionPersistenceService.instance;
await sessionService.saveDetectionSession(
  packageName: 'instagram',
  nicheId: NicheId.focus,
  duration: 30,
);

final sessions = await sessionService.getActiveSessions();
print('Active sessions: ${sessions.length}');
```

## 📝 Notas Importantes

1. **Os erros atuais são normais** - é só falta de código gerado
2. **Build Runner pode demorar** um pouco na primeira vez
3. **Se falhar**, tente com `--delete-conflicting-outputs`
4. **Após gerar**, o sistema de persistência estará 100% funcional

---

## 🎉 Resultado Esperado

Após completar estes passos:
- ✅ Sem erros de compilação
- ✅ Sessões persistem em Isar (banco profissional)
- ✅ Recuperação automática de timers
- ✅ Sistema robusto contra process kill do Android

**Pronto para usar persistência de nível enterprise!** 🚀
