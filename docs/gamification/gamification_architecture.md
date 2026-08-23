# Sistema de Gamificação - Arquitetura Completa

## Status de Implementação (2026-06-24)

- ✅ Reading: 100% implementado (Plugin Architecture)
- ✅ Money Saving: 100% implementado (Plugin Architecture)
- ✅ BingeEating: 100% implementado (Plugin Architecture)
- ✅ Adult Content: 100% implementado (Plugin Architecture)
- ✅ Diet: 100% implementado (Plugin Architecture)
- ✅ Procrastination: 100% implementado (Plugin Architecture)
- ✅ Smoking: 100% implementado (Plugin Architecture)
- ✅ Focus: 100% implementado (Plugin Architecture)
- ✅ Spending: 100% implementado (Plugin Architecture)
- ✅ Digital Detox (Jejum Digital): 100% implementado (Plugin Architecture)

**Progresso:** 10/10 módulos (100%)

---

## Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura de Plugins](#arquitetura-de-plugins)
3. [Tipos de Módulos](#tipos-de-módulos)
4. [Fluxo de Detecção de Conquistas](#fluxo-de-detecção-de-conquistas)
5. [Arquitetura por Módulo](#arquitetura-por-módulo)
6. [Persistência (ObjectBox + Supabase)](#persistência-objectbox--supabase)
7. [Dependências do Projeto](#dependências-do-projeto)
8. [Notificações e CelebraГУes](#notificaГУes-e-celebraГУes)

---

## Visão Geral

O sistema de gamificação do Disciplinum é composto por **10 módulos independentes** (plugins), cada um com:

- **Arquitetura Plugin** - Módulos 100% independentes
- **Persistência local** via ObjectBox
- **Sincronização em nuvem** via Supabase
- **Sistema de insígnias** (conquistas imediatas)
- **Sistema de medalhas** (conquistas acumulativas)
- **Estado Riverpod puro** - StateNotifier por módulo
- **Zero dependências globais** - Cada plugin é autônomo

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    🎮 SISTEMA DE GAMIFICAÇÃO DISCIPLINUM                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │               ARQUITETURA LOCAL-FIRST COM SYNC/BACKUP               │   │
│   │                                                                     │   │
│   │  ┌─────────────────────┐       (Manual)       ┌──────────────────┐  │   │
│   │  │    OBJECTBOX 📦      │ ──────────────────> │  EXPORT JSON 💾  │  │   │
│   │  │  (Armazenamento)    │ <────────────────── │  (Backup Físico) │  │   │
│   │  │ • Estado do módulo  │                      └──────────────────┘  │   │
│   │  │ • Insígnias         │                                            │   │
│   │  │ • Medalhas          │       (Manual)       ┌──────────────────┐  │   │
│   │  │ • Streaks           │ <──────────────────> │   SUPABASE ☁️    │  │   │
│   │  └─────────────────────┘         Sync         │ (Cloud Backup)   │  │   │
│   │                                               └──────────────────┘  │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    10 MÓDULOS INDEPENDENTES                        │   │
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
│   │  ┌──────────────┐ ┌──────────────────────────────────┐              │   │
│   │  │ 📱 DETOX     │ │                                  │              │   │
│   │  │ Passivo      │ │                                  │              │   │
│   │  └──────────────┘ │                                  │              │   │
│   │                    │                                  │              │   │
│   └────────────────────┴──────────────────────────────────┘              │   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Arquitetura de Plugins

### Visão Geral

O objetivo final da gamificação do Disciplinum é transformar cada módulo em um **plugin independente**. Cada pasta de módulo deve ter sua própria pasta `gamification`, contendo toda a gamificação relacionada exclusivamente àquele módulo.

### Estrutura de Diretórios

```
lib/features/modules/[nome do módulo]/gamification/
```

### Benefícios da Arquitetura Plugin

- **Independência:** Módulos funcionam isoladamente
- **Escalabilidade:** Facilita inclusão de novos módulos
- **Manutenibilidade:** Exclusão de módulos sem afetar outros
- **Organização:** Cada classe, função e objeto pertence ao seu módulo

### Estrutura de Cada Plugin

```
features/modules/{module_name}/
├── gamification/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── {module}_gamification_entity.dart      # Entity ObjectBox
│   │   │   ├── {module}_module_state.dart              # Estado do módulo
│   │   │   └── {module}_config.dart                    # Configurações
│   │   ├── repositories/
│   │   │   └── {module}_gamification_repository.dart   # Repository local
│   │   └── services/
│   │       └── {module}_gamification_notifier.dart     # StateNotifier Riverpod
│   └── presentation/
│       ├── screens/
│       │   └── {module}_screen.dart
│       └── widgets/
│           └── ...
```

### Padrão de Implementação

Cada módulo segue o padrão estabelecido no piloto **Reading**:

1. **Entity ObjectBox** - Persistência nativa via `@Entity()`
2. **Repository Local** - Acesso a dados sem dependências globais
3. **StateNotifier** - Estado gerenciado via Riverpod puro
4. **Autenticação Integrada** - `currentUserIdProvider` local
5. **Persistência de Estado** - Estado de ativação salvo localmente

---

## Tipos de Módulos

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
| **📱 Digital Detox** | Dias respeitando limites | App abre / background fetch |

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

## Arquitetura por Módulo

### Estrutura Padrão de Cada Módulo (Plugin):

```
features/modules/{module_name}/
├── gamification/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── {module}_gamification_entity.dart      # Entity ObjectBox @Entity()
│   │   │   ├── {module}_module_state.dart              # Estado do módulo
│   │   │   └── {module}_config.dart                    # Configurações
│   │   ├── repositories/
│   │   │   └── {module}_gamification_repository.dart   # Repository local
│   │   └── services/
│   │       └── {module}_gamification_notifier.dart     # StateNotifier Riverpod
│   └── presentation/
│       ├── screens/
│       │   └── {module}_screen.dart
│       └── widgets/
│           └── ...
```

### Padrão de Implementação Plugin

Cada módulo segue o padrão estabelecido nos pilotos **Reading** e **Money Saving**:

1. **Entity ObjectBox** - Persistência nativa via `@Entity()` com `@Id()`
2. **Repository Local** - Acesso a dados sem dependências globais
3. **StateNotifier** - Estado gerenciado via Riverpod puro
4. **Autenticação Integrada** - `currentUserIdProvider` local com fallback
5. **Persistência de Estado** - Estado de ativação salvo localmente
6. **Zero Acoplamento** - Nenhuma dependência de services globais

---

## Persistência (Local-First com ObjectBox, Cloud Sync sob Demanda e Backup JSON)

O Disciplinum adota uma arquitetura **Local-First**, priorizando o armazenamento local para performance e total privacidade do usuário.

### Estratégias de Persistência

1. **Persistência Local Primária (ObjectBox):**
   - Todos os dados, estados dos módulos, progresso de gamificação (medalhas/insígnias), históricos de check-ins e escolhas do usuário são salvos localmente e de forma síncrona em boxes do ObjectBox.
   - O funcionamento do aplicativo é 100% offline e independente de rede por padrão.

2. **Sincronização em Nuvem sob Demanda (Supabase):**
   - O processo de sincronização com o Supabase **não é automático** na inicialização do app ou durante a navegação.
   - O usuário aciona manualmente o upload ou a mesclagem de dados (sincronização) por meio de botões específicos nas configurações do app.
   - A autenticação (e-mail/senha ou Google) é opcional e serve principalmente para o vínculo de conta se o usuário desejar usar a sincronização em nuvem.

3. **Backup Manual (JSON):**
   - Para usuários que buscam total privacidade (sem necessidade de criação de conta) ou portabilidade direta de dados, o app fornece exportação e importação manual local.
   - O `LocalBackupService` serializa os dados do ObjectBox para um arquivo JSON compactado e utiliza o Share Sheet nativo do sistema operacional (`share_plus`) para permitir que o usuário envie esse arquivo para onde quiser (como e-mail, nuvens pessoais, WhatsApp, etc.).
   - O processo de restauração é feito selecionando o arquivo JSON exportado por meio de um seletor nativo de arquivos (`file_picker`), substituindo e populando o banco local de forma imediata dentro de uma transação segura (`store.runInTransaction`).

### Padrão de Persistência Local-First (Exemplo Conceitual)

```dart
/// Exemplo: SmokingGamificationRepository

class SmokingGamificationRepository {
  
  // ═══════════════════════════════════════════════════════════
  // PERSISTÊNCIA LOCAL - ObjectBox
  // ═══════════════════════════════════════════════════════════
  
  Future<void> saveSmokingState(SmokingModuleState state) async {
    final entity = SmokingGamificationEntity.fromModuleState(state);
    
    // Salva no ObjectBox local (Síncrono e imediato)
    box.put(entity);
  }
  
  Future<SmokingModuleState?> getSmokingState() async {
    // Busca do ObjectBox primeiro
    final entity = box.query().build().findFirst();
    return entity?.toModuleState();
  }
  
  // ═══════════════════════════════════════════════════════════
  // PERSISTÊNCIA EM NUVEM - Supabase (Disparado sob demanda pelo CloudSyncService)
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

### Todos os Módulos com ObjectBox + Supabase + Backup JSON

| Módulo | Repository | Tabela Supabase | Entity ObjectBox |
|--------|------------|-----------------|------------------|
| 🚭 Smoking | `SmokingGamificationRepository` | `smoking_daily_checkins` & settings | `SmokingGamificationEntity` |
| 📱 Focus | `FocusGamificationRepository` | `focus_intervals` & settings | `FocusGamificationEntity` & `FocusIntervalEntity` |
| 🍽️ Diet | `DietGamificationRepository` | `diet_meals` & settings | `DietGamificationEntity` & `MealEntryEntity` |
| 💰 Money | `MoneySavingGamificationRepository` | Settings | `MoneySavingGamificationEntity` |
| 🛡️ Adult | `AdultContentGamificationRepository` | Settings | `AdultContentGamificationEntity` |
| 🍔 Binge | `BingeEatingGamificationRepository` | Settings | `BingeEatingGamificationEntity` |
| 💸 Spending | `SpendingGamificationRepository` | Settings | `SpendingGamificationEntity` & `ExpenseEntity` |
| ✅ Procrast | `ProcrastinationGamificationRepository` | Settings | `ProcrastinationGamificationEntity` |
| 📖 Reading | `ReadingGamificationRepository` | `reading_books` & settings | `ReadingGamificationEntity` & `ReadingBookEntity` |
| 📱 Detox | `DigitalDetoxGamificationRepository` | Settings | `DigitalDetoxGamificationEntity` |

---

## Dependências do Projeto

### Dependências Principais (pubspec.yaml)

#### Gerenciamento de Estado
- **flutter_riverpod:** ^2.6.1 - Gerenciamento de estado reativo
- **riverpod_annotation:** ^2.6.1 - Code generation para Riverpod
- **riverpod_generator:** ^2.4.0 - Gerador de código Riverpod
- **provider:** ^6.1.2 - Provider legacy (em desuso)

#### Persistência de Dados
- **objectbox:** ^4.1.0 - Banco de dados local de alta performance
- **objectbox_flutter_libs:** ^4.1.0 - Bibliotecas ObjectBox para Flutter
- **objectbox_generator:** ^4.1.0 - Code generation para ObjectBox
- **shared_preferences:** ^2.3.5 - Preferências simples (uso residual)
- **path_provider:** ^2.1.4 - Acesso a diretórios do sistema

#### Backend e Autenticação
- **supabase_flutter:** ^2.12.4 - Backend as a Service e autenticação
- **google_sign_in:** ^7.2.0 - Autenticação Google

#### Firebase
- **firebase_core:** ^4.7.0 - Core do Firebase
- **firebase_crashlytics:** ^5.2.0 - Crash reporting
- **firebase_analytics:** ^12.3.0 - Analytics

#### Notificações
- **flutter_local_notifications:** ^21.0.0 - Notificações locais

#### Monitoramento e Permissões
- **installed_apps:** ^2.1.1 - Lista de apps instalados
- **permission_handler:** ^12.0.1 - Gerenciamento de permissões

#### Utilitários
- **equatable:** ^2.0.5 - Comparação de objetos
- **logger:** ^2.0.2 - Logging profissional
- **uuid:** ^4.5.2 - Geração de UUIDs
- **url_launcher:** ^6.3.1 - Abrir URLs
- **in_app_review:** ^2.0.9 - Reviews na app store

#### UI e Gráficos
- **confetti:** ^0.8.0 - Efeitos de confetes
- **fl_chart:** ^1.2.0 - Gráficos
- **shimmer:** ^3.0.0 - Efeitos de loading
- **google_fonts:** ^6.2.1 - Fontes Google

#### Anúncios e IAP
- **google_mobile_ads:** ^8.0.0 - Anúncios AdMob
- **in_app_purchase:** ^3.0.0 - Compras in-app

#### Background Processing
- **workmanager:** ^0.9.0+3 - Tarefas em background

#### Dev Dependencies
- **build_runner:** ^2.4.13 - Code generation
- **flutter_lints:** ^6.0.0 - Linting
- **objectbox_generator:** ^4.1.0 - Geração ObjectBox
- **mockito:** ^5.4.4 - Mocking para testes

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

## Resumo Visual por Módulo

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
│  ├──────────┼─────────────┼──────────────┼────────────────────────────────┤ │
│  │ 📱       │ Passivo     │ ❌ Não       │ Dias respeitando limites       │ │
│  │ Detox    │             │ (App        │ (App Monitoring detecta)       │ │
│  │          │             │  Monitoring) │                                │ │
│  └──────────┴─────────────┴──────────────┴────────────────────────────────┘ │
│                                                                             │
│  LEGENDA:                                                                   │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ✅ Todos os módulos têm:                                            │  │
│  │     • ObjectBox (persistência local)                                  │  │
│  │     • Supabase (sincronização cloud)                                  │  │
│  │     • Insígnias e Medalhas                                            │  │
│  │     • Arquitetura Plugin independente                                 │  │
│  │     • StateNotifier Riverpod puro                                     │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Checklist de Implementação

- [x] ObjectBox configurado para todos os módulos
- [x] Supabase sincronização para todos os módulos
- [x] Sistema de insígnias (10 módulos)
- [x] Sistema de medalhas (10 módulos)
- [x] Arquitetura Plugin implementada (10 módulos)
- [x] StateNotifier Riverpod puro (10 módulos)
- [x] Autenticação integrada local (10 módulos)
- [x] Zero dependências globais (10 módulos)
- [x] Check-in diário (Smoking, Diet)
- [x] App Monitoring (Adult Content, Spending, Digital Detox)
- [x] Sistema de Quebras de Jejum (Digital Detox)

---

**Documento atualizado em:** Junho 2026  
**Versão:** 2.0  
**Status:** ✅ Completo e atualizado com Arquitetura Plugin
