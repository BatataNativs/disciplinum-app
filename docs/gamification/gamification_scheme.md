# 🎮 Sistema de Gamificação - Arquitetura Completa

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Tipos de Módulos](#tipos-de-módulos)
3. [Fluxo de Detecção de Conquistas](#fluxo-de-detecção-de-conquistas)
4. [Arquitetura por Módulo](#arquitetura-por-módulo)
5. [Persistência (ObjectBox + Supabase)](#persistência-objectbox--supabase)
6. [Notificações e Celebrações](#notificações-e-celebrações)

---

## 🎯 Visão Geral

O sistema de gamificação do Disciplinum é composto por **9 módulos independentes**, cada um com:

- **Persistência local** via ObjectBox
- **Sincronização em nuvem** via Supabase
- **Sistema de insígnias** (conquistas imediatas)
- **Sistema de medalhas** (conquistas acumulativas)
- **Notificações push** com celebração global

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    🎮 SISTEMA DE GAMIFICAÇÃO DISCIPLINUM                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                        PERSISTÊNCIA DUAL                             │   │
│   │  ┌─────────────────────┐      ┌─────────────────────┐              │   │
│   │  │    OBJECTBOX 📦      │      │    SUPABASE ☁️       │              │   │
│   │  │    (Local)           │  ↔️   │    (Cloud)           │              │   │
│   │  │  • Estado do módulo  │      │  • Backup na nuvem   │              │   │
│   │  │  • Insígnias         │      │  • Sync multi-device │              │   │
│   │  │  • Medalhas          │      │  • Dados do usuário  │              │   │
│   │  │  • Streaks           │      │                      │              │   │
│   │  └─────────────────────┘      └─────────────────────┘              │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                     9 MÓDULOS INDEPENDENTES                          │   │
│   │                                                                     │   │
│   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                │   │
│   │  │ 🚭 SMOKING   │ │ 📱 FOCUS     │ │ 📖 READING   │                │   │
│   │  │ Check-in     │ │ Timer        │ │ Registro     │                │   │
│   │  └──────────────┘ └──────────────┘ └──────────────┘                │   │
│   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                │   │
│   │  │ 🍽️ DIET      │ │ 💰 MONEY     │ │ 🛡️ ADULT     │                │   │
│   │  │ Check-in     │ │ Passivo      │ │ Passivo      │                │   │
│   │  └──────────────┘ └──────────────┘ └──────────────┘                │   │
│   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                │   │
│   │  │ 🍔 BINGE     │ │ 💸 SPENDING  │ │ ✅ PROCRAST  │                │   │
│   │  │ Passivo      │ │ Passivo      │ │ Tarefas      │                │   │
│   │  └──────────────┘ └──────────────┘ └──────────────┘                │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Tipos de Módulos

### **TIPO A: IN APP ACTION** (Ação Direta → Recompensa Imediata)

O usuário realiza uma ação específica no app e, ao completar, recebe a conquista imediatamente.

| Módulo | Ação do Usuário | Gatilho de Conquista |
|--------|-----------------|---------------------|
| **📱 Focus** | Inicia e completa sessão de foco | Timer chega a 00:00 |
| **📖 Reading** | Registra páginas lidas | Atinge meta diária |
| **✅ Procrastination** | Marca tarefa como concluída | Completa N tarefas |

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TIPO A: FLUXO IN APP ACTION                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1️⃣ USUÁRIO INICIA AÇÃO                                                     │
│     └─▶ Toca "Iniciar Sessão de Foco"                                        │
│         ↓                                                                   │
│  2️⃣ SISTEMA MONITORA                                                        │
│     └─▶ Timer countdown rodando                                              │
│         ↓                                                                   │
│  3️⃣ AÇÃO COMPLETADA ✅                                                      │
│     └─▶ Timer chega a 00:00                                                  │
│         ↓                                                                   │
│  4️⃣ VERIFICAÇÃO IMEDIATA 🔥                                                 │
│     ┌─────────────────────────────────────────┐                               │
│     │  FocusService                           │                               │
│     │  ├─ onFocusSessionCompleted()           │                               │
│     │  ├─ incrementa contador de períodos     │                               │
│     │  └─ chama _checkForAchievements()       │                               │
│     └─────────────────────────────────────────┘                               │
│         ↓                                                                   │
│  5️⃣ AVALIA CONDIÇÕES                                                        │
│     ┌─────────────────────────────────────────┐                               │
│     │  • Tem 3 períodos? → Insígnia LATÃO    │                               │
│     │  • Tem 6 períodos? → Insígnia OURO     │                               │
│     │  • Tem 9 períodos? → Insígnia DIAMANTE │                               │
│     │  • Tem 10 períodos? → DISCIPLINUM      │                               │
│     └─────────────────────────────────────────┘                               │
│         ↓                                                                   │
│  6️⃣ CONQUISTA CONCEDIDA → CELEBRAÇÃO 🎉                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### **TIPO B: PASSIVO/BACKGROUND** (Tempo passa → Verificação periódica)

O sistema verifica periodicamente (quando o app abre) se marcos de tempo foram atingidos.

| Módulo | O que é rastreado | Quando verifica |
|--------|-------------------|-----------------|
| **🚭 Smoking** | Dias sem fumar | App abre / sobe da background |
| **🍽️ Diet** | Dias de dieta | App abre / sobe da background |
| **💰 Money Saving** | Valor economizado | Quando usuário registra economia |
| **🛡️ Adult Content** | Dias "limpo" | App abre / background fetch |
| **🍔 Binge Eating** | Dias sem compulsão | App abre / background fetch |
| **💸 Spending** | Dias sem gastar | App abre / background fetch |

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TIPO B: FLUXO PASSIVO/BACKGROUND                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1️⃣ USUÁRIO CONFIGURA MÓDULO (uma vez)                                      │
│     └─▶ "Parei de fumar dia 15/01/2026"                                    │
│         ↓                                                                   │
│  2️⃣ TEMPO PASSA ⏰ (dias/semanas/meses...)                                  │
│     └─▶ Usuário não precisa abrir o app                                     │
│         ↓                                                                   │
│  3️⃣ APP É ABERTO (ou sobe da background)                                    │
│         ↓                                                                   │
│  4️⃣ VERIFICAÇÃO PERIÓDICA ⚡                                                │
│     ┌─────────────────────────────────────────┐                               │
│     │  SmokingModuleNotifier                  │                               │
│     │  ├─ checkDailyProgress()                │                               │
│     │  ├─ calculateDaysSinceQuit()            │                               │
│     │  └─ Verifica marcos atingidos           │                               │
│     └─────────────────────────────────────────┘                               │
│         ↓                                                                   │
│  5️⃣ MARCO DETECTADO?                                                        │
│     ┌─────────────────────────────────────────┐                               │
│     │  Verificação:                           │                               │
│     │  ├─ 1 dia sem fumar? → LATÃO            │                               │
│     │  ├─ 3 dias? → BRONZE                    │                               │
│     │  ├─ 7 dias? → PRATA                     │                               │
│     │  ├─ 30 dias? → OURO                     │                               │
│     │  └─ 90 dias? → DIAMANTE                 │                               │
│     └─────────────────────────────────────────┘                               │
│         ↓                                                                   │
│  6️⃣ SIM! → CONQUISTA CONCEDIDA 🎉                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔍 Smoking - Check-in Diário (Detalhamento Especial)

⚠️ **IMPORTANTE**: O módulo **Smoking** possui **check-in diário obrigatório**, não é apenas "passar dos dias".

### Lógica de Check-in:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    🚭 SMOKING - CHECK-IN DIÁRIO                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CONFIGURAÇÃO:                                                              │
│  ├─ Usuário define horário do check-in (ex: 20:00)                         │
│  └─ App envia notificação no horário configurado                             │
│                                                                             │
│  CHECK-IN DIÁRIO:                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  🔔 NOTIFICAÇÃO: "Como foi seu dia? Fumou hoje?"                   │    │
│  │                                                                     │    │
│  │  [😊 Não Fumei!]  [😔 Fumei...]                                    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│         ↓                                                                   │
│  SE "NÃO FUMEI":                                                            │
│  ├─ ✅ Incrementa streak (dias consecutivos)                                 │
│  ├─ 💾 Salva no ObjectBox                                                    │
│  ├─ ☁️ Sincroniza com Supabase                                               │
│  └─ 🎯 Verifica se atingiu marco para nova insígnia                          │
│                                                                             │
│  SE "FUMEI":                                                                │
│  ├─ ❌ Reseta streak para 0                                                  │
│  ├─ 📝 Registra recaída (para estatísticas)                                  │
│  ├─ 💾 Salva no ObjectBox                                                    │
│  └─ ☁️ Sincroniza com Supabase                                               │
│                                                                             │
│  ARQUIVOS RELACIONADOS:                                                     │
│  ├─ smoking_checkin_section.dart        (UI do check-in)                     │
│  ├─ smoking_checkin_service.dart       (Lógica do check-in)                  │
│  ├─ smoking_gamification_notifier.dart (Gerencia estado)                    │
│  └─ stop_smoking_screen.dart           (Tela principal)                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxo de Detecção de Conquistas (Todos os Módulos)

### Fluxo Unificado:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    🎯 FLUXO UNIFICADO DE CONQUISTA                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────┐      ┌─────────────────────┐                     │
│   │   MÓDULO IN APP     │      │   MÓDULO PASSIVO    │                     │
│   │   (Focus/Reading)   │      │   (Smoking/Diet/    │                     │
│   │                     │      │    Money/Adult/     │                     │
│   │                     │      │    Binge/Spending)  │                     │
│   └──────────┬──────────┘      └──────────┬──────────┘                     │
│              │                            │                                 │
│              ▼                            ▼                                 │
│   ┌─────────────────────┐      ┌─────────────────────┐                     │
│   │  Ação completada    │      │  App aberto/        │                     │
│   │  Timer finalizado   │      │  tempo passou       │                     │
│   └──────────┬──────────┘      └──────────┬──────────┘                     │
│              │                            │                                 │
│              └────────────┬───────────────┘                                 │
│                           │                                                 │
│                           ▼                                                 │
│              ┌─────────────────────┐                                      │
│              │  1. VERIFICAÇÃO DE   │                                      │
│              │     INSÍGNIAS        │                                      │
│              │                      │                                      │
│              │  • Condições atingidas?                                      │
│              │  • Se sim: awardInsignia()                                   │
│              │                      │                                      │
│              │  ┌─────────────────────────────────────┐                   │
│              │  │ {Module}InsigniaService             │                   │
│              │  │ ├─ checkForNewInsignias()           │                   │
│              │  │ │   ├─ Verifica requisitos          │                   │
│              │  │ │   └─ Se atingiu: awardInsignia()  │                   │
│              │  │ └─ awardInsignia(id)                │                   │
│              │  │     ├─ Salva no ObjectBox           │                   │
│              │  │     ├─ Sincroniza com Supabase     │                   │
│              │  │     └─ Chama CelebrationService    │                   │
│              │  └─────────────────────────────────────┘                   │
│              └────────────┬────────────────────┘                          │
│                           │                                                 │
│                           ▼                                                 │
│              ┌─────────────────────┐                                      │
│              │  2. VERIFICAÇÃO DE   │                                      │
│              │     MEDALHAS         │                                      │
│              │                      │                                      │
│              │  • Insígnias novas?  │                                      │
│              │  • Medalha associada? │                                      │
│              │  • Se sim: awardMedalha()                                    │
│              │                      │                                      │
│              │  ┌─────────────────────────────────────┐                   │
│              │  │ {Module}MedalhaService              │                   │
│              │  │ ├─ checkForNewMedalhas()            │                   │
│              │  │ │   ├─ Verifica insígnias           │                   │
│              │  │ │   └─ Se suficiente: awardMedalha()│                   │
│              │  │ └─ awardMedalha(id)               │                   │
│              │  │     ├─ Salva no ObjectBox         │                   │
│              │  │     ├─ Sincroniza com Supabase   │                   │
│              │  │     └─ Chama CelebrationService  │                   │
│              │  └─────────────────────────────────────┘                   │
│              └────────────┬────────────────────┘                          │
│                           │                                                 │
│                           ▼                                                 │
│              ┌─────────────────────┐                                      │
│              │  3. CELEBRAÇÃO       │                                      │
│              │     E NOTIFICAÇÃO    │                                      │
│              │                      │                                      │
│              │  ┌─────────────────────────────────────┐                   │
│              │  │ {Module}CelebrationService          │                   │
│              │  │ ├─ Haptic Feedback (vibração)     │                   │
│              │  │ ├─ EventBus (confetes na UI)      │                   │
│              │  │ ├─ AchievementNotificationService │                   │
│              │  │ │   ├─ Salva pending no ObjectBox │                   │
│              │  │ │   └─ Envia notificação push     │                   │
│              │  │ └─ LoggerService (log)            │                   │
│              │  └─────────────────────────────────────┘                   │
│              └────────────┬────────────────────┘                          │
│                           │                                                 │
│                           ▼                                                 │
│              ┌─────────────────────┐                                      │
│              │  4. DIALOG GLOBAL    │                                      │
│              │     (Qualquer tela)  │                                      │
│              │                      │                                      │
│              │  ┌─────────────────────────────────────┐                   │
│              │  │ GlobalAchievementListener           │                   │
│              │  │ ├─ Verifica a cada 2 segundos       │                   │
│              │  │ ├─ Encontra pending achievements    │                   │
│              │  │ ├─ Mostra Dialog com confetes       │                   │
│              │  │ └─ Marca como exibida               │                   │
│              │  └─────────────────────────────────────┘                   │
│              └────────────┬────────────────────┘                          │
│                           │                                                 │
│                           ▼                                                 │
│              ┌─────────────────────────────────────────────────────┐    │
│              │  🎉 DIALOG APARECE EM QUALQUER TELA!                 │    │
│              │                                                      │    │
│              │  ┌─────────────┐                                     │    │
│              │  │    🏆       │     PARABÉNS! VOCÊ CONQUISTOU!     │    │
│              │  │  (imagem)   │                                     │    │
│              │  └─────────────┘                                     │    │
│              │                                                      │    │
│              │  Insígnia de Ouro / Medalha de Prata                 │    │
│              │  "Descrição da conquista"                            │    │
│              │                                                      │    │
│              │  [    Incrível! 🎉    ]                              │    │
│              └─────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Arquitetura por Módulo

### Estrutura Padrão de Cada Módulo:

```
features/modules/{module_name}/
├── domain/
│   ├── entities/
│   │   ├── {module}_module_state.dart       # Estado do módulo
│   │   └── {module}_config.dart             # Configurações
│   ├── services/
│   │   └── {module}_service.dart            # Lógica principal
│   └── repositories/
│       └── {module}_repository.dart         # Persistência base
│
├── gamification/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── {module}_gamification_entity.dart      # Entity ObjectBox
│   │   │   ├── {module}_medal.dart                      # Enum de medalhas
│   │   │   └── {module}_insignia.dart                   # Enum de insígnias
│   │   ├── services/
│   │   │   ├── {module}_medalha_service.dart           # Lógica de medalhas
│   │   │   ├── {module}_insignia_service.dart          # Lógica de insígnias
│   │   │   ├── {module}_celebration_service.dart       # Celebrações
│   │   │   └── {module}_gamification_events.dart       # Eventos
│   │   └── repositories/
│   │       └── {module}_gamification_repository.dart   # Repo ObjectBox + Supabase
│   └── data/
│       └── repositories/
│           └── {module}_gamification_repository.dart   # Implementação
│
└── presentation/
    ├── notifiers/
    │   └── {module}_gamification_notifier.dart   # StateNotifier Riverpod
    ├── screens/
    │   └── {module}_screen.dart
    └── widgets/
        └── ...
```

---

## 📦 Persistência (ObjectBox + Supabase)

### Padrão de Persistência Dual:

```dart
/// Exemplo: SmokingGamificationRepository

class SmokingGamificationRepository {
  
  // ═══════════════════════════════════════════════════════════
  // PERSISTÊNCIA LOCAL - ObjectBox
  // ═══════════════════════════════════════════════════════════
  
  Future<void> saveSmokingState(SmokingModuleState state) async {
    final entity = SmokingGamificationEntity.fromModuleState(state);
    
    // Salva no ObjectBox local
    box.put(entity);
    
    // Sincroniza com Supabase
    await syncWithSupabase(state);
  }
  
  Future<SmokingModuleState?> getSmokingState() async {
    // Busca do ObjectBox primeiro
    final entity = box.query().build().findFirst();
    return entity?.toModuleState();
  }
  
  // ═══════════════════════════════════════════════════════════
  // PERSISTÊNCIA EM NUVEM - Supabase
  // ═══════════════════════════════════════════════════════════
  
  Future<void> syncWithSupabase(SmokingModuleState state) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId != null) {
      await supabase.from('smoking_gamification_states').upsert({
        'user_id': userId,
        'state_data': entity.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }
  
  Future<SmokingModuleState?> loadFromSupabase() async {
    final response = await supabase
        .from('smoking_gamification_states')
        .select('state_data')
        .eq('user_id', userId)
        .maybeSingle();
    
    if (response != null) {
      return SmokingGamificationEntity
          .fromJson(response['state_data'])
          .toModuleState();
    }
  }
}
```

### Todos os Módulos com ObjectBox + Supabase:

| Módulo | Repository | Tabela Supabase | Entity ObjectBox |
|--------|------------|-----------------|------------------|
| 🚭 Smoking | `SmokingGamificationRepository` | `smoking_gamification_states` | `SmokingGamificationEntity` |
| 📱 Focus | `FocusGamificationRepository` | `focus_gamification_states` | `FocusGamificationEntity` |
| 🍽️ Diet | `DietGamificationRepository` | `diet_gamification_states` | `DietGamificationEntity` |
| 💰 Money | `MoneySavingGamificationRepository` | `money_saving_gamification_states` | `MoneySavingGamificationEntity` |
| 🛡️ Adult | `AdultContentGamificationRepository` | `adult_content_gamification_states` | `AdultContentGamificationEntity` |
| 🍔 Binge | `BingeEatingGamificationRepository` | `binge_eating_gamification_states` | `BingeEatingGamificationEntity` |
| 💸 Spending | `SpendingGamificationRepository` | `spending_gamification_states` | `SpendingGamificationEntity` |
| ✅ Procrast | `ProcrastinationGamificationRepository` | `procrastination_gamification_states` | `ProcrastinationGamificationEntity` |
| 📖 Reading | `ReadingGamificationRepository` | `reading_gamification_states` | `ReadingGamificationEntity` |

---

## 🎊 Notificações e Celebrações

### Arquitetura de Notificação Global:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔔 SISTEMA DE NOTIFICAÇÃO GLOBAL                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  QUANDO CONQUISTA É CONCEDIDA:                                              │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  {Module}CelebrationService.celebrarInsigniaConquistada()           │    │
│  │  {Module}CelebrationService.celebrarMedalhaConquistada()           │    │
│  └──────────────────────────┬──────────────────────────────────────────┘    │
│                             │                                               │
│                             ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  1. EFEITOS LOCAIS (na tela atual)                                  │    │
│  │     ├─ Haptic feedback (vibração do celular)                        │    │
│  │     ├─ EventBus.emit() → Confetes animados na tela                  │    │
│  │     └─ Som de conquista (se habilitado)                             │    │
│  └──────────────────────────┬──────────────────────────────────────────┘    │
│                             │                                               │
│                             ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  2. NOTIFICAÇÃO PUSH (se user fora do app)                           │    │
│  │                                                                     │    │
│  │  AchievementNotificationService                                     │    │
│  │  ├─ showInsigniaNotification() / showMedalhaNotification()        │    │
│  │  │   ├─ Título: "🎉 Você conquistou uma insígnia!"                  │    │
│  │  │   ├─ Corpo: "Parabéns! Insígnia de Ouro conquistada"            │    │
│  │  │   └─ Ação: "Ver no app"                                         │    │
│  │  │                                                                 │    │
│  │  └─ Salva em PendingAchievementsRepository (ObjectBox)            │    │
│  │      ├─ userId, type, moduleId, achievementId                       │    │
│  │      ├─ achievementName, assetPath, rarity                          │    │
│  │      ├─ earnedAt: DateTime.now()                                   │    │
│  │      └─ wasShown: false (aguardando exibição)                     │    │
│  └──────────────────────────┬──────────────────────────────────────────┘    │
│                             │                                               │
│                             ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  3. GLOBAL ACHIEVEMENT LISTENER (verificação contínua)              │    │
│  │                                                                     │    │
│  │  GlobalAchievementListener (envolve todo o app em main.dart)      │    │
│  │  ├─ Timer a cada 2 segundos                                         │    │
│  │  ├─ Verifica PendingAchievementsRepository.hasPendingAchievements() │    │
│  │  ├─ Se encontrar:                                                   │    │
│  │  │   ├─ Cria fila de conquistas pendentes                         │    │
│  │  │   ├─ Mostra dialog sequencialmente                               │    │
│  │  │   └─ Marca como wasShown=true após exibição                    │    │
│  │  └─ Se múltiplas: mostra uma por vez                               │    │
│  │      (user clica "OK" → próxima aparece)                           │    │
│  └──────────────────────────┬──────────────────────────────────────────┘    │
│                             │                                               │
│                             ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  4. DIALOG GLOBAL APARECE                                           │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  🎉 PARABÉNS!                                               │   │    │
│  │  │                                                             │   │    │
│  │  │  ┌─────────────┐                                           │   │    │
│  │  │  │   🏆/🎖️      │    Você conquistou:                        │   │    │
│  │  │  │  (imagem)   │    "Insígnia de Ouro"                     │   │    │
│  │  │  └─────────────┘    "Complete 30 dias sem fumar"           │   │    │
│  │  │                                                             │   │    │
│  │  │  [    Incrível! 🎉    ]                                     │   │    │
│  │  │                                                             │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ✨ OverlayEntry com confetes animados por cima de qualquer tela   │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Hierarquia de Widgets (main.dart):

```dart
return GlobalAchievementListener(      // ← Verifica e mostra dialogs
  child: AuthNavigationListener(        // ← Gerencia navegação auth
    child: MaterialApp(                 // ← App principal
      // ... rotas e telas
    ),
  ),
);
```

---

## 📊 Resumo Visual por Módulo

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    📊 MATRIZ DE MÓDULOS - RESUMO VISUAL                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────┬─────────────┬──────────────┬────────────────────────────────┐ │
│  │ Módulo   │ Tipo        │ Check-in     │ Gatilho Principal              │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 🚭       │ Passivo     │ ✅ Diário    │ Check-in positivo              │ │
│  │ Smoking  │             │ obrigatório  │ ("Não fumei hoje")             │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 📱       │ In App      │ ❌ Não       │ Timer finalizado               │ │
│  │ Focus    │ Action      │              │ (25/50 min completos)          │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 📖       │ In App      │ ❌ Não       │ Meta de páginas atingida       │ │
│  │ Reading  │ Action      │              │                                │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ ✅       │ In App      │ ❌ Não       │ N tarefas completadas          │ │
│  │ Procrast │ Action      │              │                                │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 🍽️       │ Passivo     │ ✅ Diário    │ App abre + dias passaram       │ │
│  │ Diet     │             │ obrigatório  │                                │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 💰       │ Passivo     │ ❌ Não       │ Valor economizado atingiu meta │ │
│  │ Money    │             │ (registro    │                                │ │
│  │ Saving   │             │  manual)     │                                │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 🛡️       │ Passivo     │ ❌ Não       │ App abre + dias limpo          │ │
│  │ Adult    │             │ (tracking   │ (App Monitoring detecta)       │ │
│  │ Content  │             │  automático) │                                │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 🍔       │ Passivo     │ ❌ Não       │ Dias sem compulsão             │ │
│  │ Binge    │             │ (self-       │ (Auto-relato ou tracking)      │ │
│  │ Eating   │             │  reporting)  │                                │ │
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 💸       │ Passivo     │ ❌ Não       │ Dias sem gastar                │ │
│  │ Spending │             │ (App        │ (App Monitoring detecta)       │ │
│  │          │             │  Monitoring) │                                │ │
│  └──────────┴─────────────┴──────────────┴────────────────────────────────┘ │
│                                                                             │
│  LEGENDA:                                                                   │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ✅ Todos os módulos têm:                                            │  │
│  │     • ObjectBox (persistência local)                                  │  │
│  │     • Supabase (sincronização cloud)                                  │  │
│  │     • Insígnias e Medalhas                                            │  │
│  │     • Celebração global com GlobalAchievementListener                 │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Checklist de Implementação

- [x] ObjectBox configurado para todos os módulos
- [x] Supabase sincronização para todos os módulos
- [x] Sistema de insígnias (9 módulos)
- [x] Sistema de medalhas (9 módulos)
- [x] CelebrationService por módulo (9 serviços)
- [x] AchievementNotificationService integrado
- [x] GlobalAchievementListener (verificação global)
- [x] Notificações push para conquistas
- [x] Check-in diário (Smoking, Diet)
- [x] App Monitoring (Adult Content, Spending)

---

**Documento criado em:** Maio 2026  
**Versão:** 1.0  
**Status:** ✅ Completo e atualizado
