# Background Processing Architecture

## 📋 Visão Geral

Sistema de processamento em background usando **WorkManager** para notificações de conquistas e verificação de streaks, mesmo com o app fechado.

## 🏗️ Componentes

### WorkManager (Flutter)

| Propriedade | Valor |
|-------------|-------|
| **Biblioteca** | `workmanager: ^0.9.0+3` |
| **Frequência mínima** | 15 minutos (limitação Android) |
| **Tasks registradas** | 2 |

#### Tasks

| Task ID | Propósito | Frequência |
|---------|-----------|------------|
| `checkAchievementsTask` | Verifica novas conquistas/medalhas | A cada 15 min |
| `dailyStreakCheckTask` | Verifica streaks prestes a quebrar | A cada 6 horas |

### Arquitetura de Arquivos

```
lib/core/background/
├── background_callback.dart          # Entry point do WorkManager
├── background_achievement_service.dart  # Agendamento de tasks
├── batched_achievement_notifier.dart    # Batching de notificações
└── background_retry_handler.dart        # Retry com exponential backoff
```

## 🔄 Fluxo de Execução

```
WorkManager (15 min)
  ↓
callbackDispatcher() [isolate separado]
  ↓
BackgroundRetryHandler.executeWithRetry()
  ↓ (1s, 2s, 4s em caso de falha)
ObjectBox.initialize()
  ↓
BatchedAchievementNotifier.clear()
  ↓
_check*Achievements() [9 módulos]
  ↓
notifier.queueNotification() [múltiplas]
  ↓
notifier.flush() [batching inteligente]
  ↓
NotificationService.showNotification() [1 ou batch]
```

## 🎯 Batching de Notificações

### Problema
Múltiplas conquistas desbloqueadas simultaneamente (ex: insígnia + medalha) geravam spam de notificações.

### Solução
`BatchedAchievementNotifier` agrupa conquistas em uma única notificação:

| Cenário | Comportamento |
|---------|--------------|
| 1 conquista | Notificação normal |
| Insígnia + Medalha (mesmo módulo) | "🏆 Conquista Dupla! Módulo: X + Y!" |
| Múltiplos módulos | "🎉 Múltiplas Conquistas! Mod1: info | Mod2: info | +N mais..." |

### Exemplo
```dart
// Antes: 2 notificações separadas
"🏆 Nova Conquista!" - "🎱 Disciplinum conquistada!"
"🏆 Nova Conquista!" - "Medalha Bronze!"

// Depois: 1 notificação combinada
"🏆 Conquista Dupla! Smoking: 🎱 Disciplinum + Medalha Bronze!"
```

## 🔄 Retry Strategy

### Exponential Backoff
```
Tentativa 1: falha → espera 1s → retry
Tentativa 2: falha → espera 2s → retry
Tentativa 3: falha → espera 4s → retry
Tentativa 4: desiste
```

### Casos de Retry
- ❌ **Sem internet** → Retry
- ❌ **ObjectBox bloqueado** → Retry  
- ❌ **Timeout** → Retry
- ✅ **Erro de lógica** → Não retry (falha definitiva)

## 📊 Módulos Verificados

| Módulo | Tipo de Verificação | Marcos |
|--------|-------------------|--------|
| Smoking | Streak days | 7, 30, 100 dias |
| Spending | Consecutive months | 3, 6, 12, 24 meses |
| Reading | Consecutive days | 7, 30, 100, 365 dias |
| Focus | Sessions + Hours | 10/50/100/500 sessões, 10/50/100/500 horas |
| Money Saving | Total saved | R$100, R$500, R$1000, R$5000, R$10000 |
| Procrastination | Tasks completed | 10, 50, 100, 500 tarefas |
| Diet | Consecutive days | 7, 30, 100 dias |
| Binge Eating | Consecutive days | 7, 30, 100 dias |
| Adult Content | Consecutive days | 7, 30, 100 dias |

## 🧪 Testes

### Estrutura
```
test/
├── integration/background/
│   ├── background_callback_test.dart
│   ├── batched_achievement_notifier_test.dart
│   └── background_retry_handler_test.dart
```

### Cenários de Teste
- Batching com 1 conquista → notificação única
- Batching com múltiplas conquistas → notificação agrupada
- Retry com falha temporária → sucesso na 2ª/3ª tentativa
- Retry com falha definitiva → desiste após 3 tentativas

## 📱 Constraints Android

```dart
Constraints(
  networkType: NetworkType.connected,    // Precisa de internet para sync
  requiresBatteryNotLow: true,           // Não executa com bateria baixa
  requiresStorageNotLow: false,          // Executa mesmo com pouco storage
)
```

## 🚀 Inicialização

O serviço é inicializado no `AppBootstrap`:

```dart
// lib/app/bootstrap.dart
static Future<void> _initBackgroundAchievementService() async {
  await BackgroundAchievementService.instance.initialize();
  await BackgroundAchievementService.instance.scheduleAchievementChecks();
  await BackgroundAchievementService.instance.scheduleStreakChecks();
}
```

## ⚠️ Limitações

1. **Frequência mínima**: 15 minutos (limitação Android)
2. **Doze mode**: WorkManager respeita o modo de economia de bateria
3. **Persistência**: Tasks são reagendadas após reboot automaticamente
4. **Memória**: Batching é em memória (não persiste entre execuções)

## 📚 Referências

- [WorkManager Flutter](https://github.com/fluttercommunity/flutter_workmanager)
- [Android WorkManager](https://developer.android.com/topic/libraries/architecture/workmanager)
- [Background Execution Flutter](https://docs.flutter.dev/development/packages-and-plugins/background-processes)

---

**Status**: ✅ Implementado | **Última atualização**: 2026-05-05
