É um módulo focado em ajudar usuários a manterem foco e produtividade através de sessões de trabalho, bloqueio de aplicativos e gamificação.

### Funcionalidades Principais:

1. **Sistema de Sessões de Foco**
   - Meta diária de minutos de foco (dailyGoalMinutes, padrão: 120)
   - Tracking de tempo em sessões de foco
   - Intervalos configuráveis (pausas entre sessões)
   - Registro de início e fim de período de foco (focusStart/focusEnd)
   - Sessões concluídas (sessionsCompleted)
   - Períodos respeitados (respectedPeriods)

2. **Seleção de Aplicativos**
   - Interface para selecionar apps a serem bloqueados durante foco
   - Integração com SelectAppsScreen
   - Suporte a múltiplos aplicativos
   - Persistência da lista de apps

3. **Sistema de Bloqueio**
   - Bloqueio de aplicativos selecionados durante período de foco
   - Período de foco configurável (horário início e fim)
   - Integração com AccessibilityService
   - AppLock para bloqueio em tempo real

4. **Permissões Necessárias**
   - Permissão de acessibilidade (AccessibilityService)
   - Permissão de uso de apps (UsageStats)
   - Permissão de notificações
   - Diálogos de solicitação de permissão

5. **Gamificação**
   - Sistema de medalhas e insignias
   - Streak tracking (dias consecutivos com foco)
   - Celebrações ao atingir metas de foco
   - Conquistas por sessões longas
   - Estatísticas detalhadas de progresso
   - FocusGamificationController para gerenciamento
   - Sistema de estágios (bronze/prata/ouro/diamante)
   - Lista de conquistas desbloqueadas (unlockedAchievements)

6. **Interface**
   - Tela principal de configuração (FocusScreen)
   - Tabs: "Foco e produtividade" e "Como funciona"
   - Seleção de horários de foco (TimePicker)
   - Tela de notificações (FocusNotificationsScreen)
   - Tela de streak (FocusStreakScreen) — placeholder futuro
   - Widget de progresso (MyProgressFocus)
   - Widget de celebração ao atingir metas
   - Diálogo de desativação do módulo

7. **Persistência**
   - Configurações salvas localmente via ObjectBox
   - Lista de aplicativos monitorados
   - Horários de foco configurados
   - Histórico de sessões (FocusIntervalEntity)
   - Sincronização com nuvem (via CloudSyncService)

8. **Monitoramento em Tempo Real**
   - Service local detecta abertura de apps durante foco
   - Exibe tela de bloqueio LockActivity
   - Registra tempo de foco
   - Remove intervalo quando período é cumprido

### Estrutura de Dados:

**FocusConfigEntity:**
- userId: ID do usuário
- isModuleActive: Status de ativação do módulo
- enableNotifications: Habilita notificações (padrão: true)
- dailyGoalMinutes: Meta diária de foco em minutos (padrão: 120)
- reminderHour/reminderMinute: Horário do lembrete (padrão: 9:00)
- streakDays: Dias consecutivos com foco
- lastFocusDate: Data do último foco
- totalFocusMinutes: Total acumulado de foco
- longestFocusSession: Sessão mais longa de foco
- createdAt/updatedAt: Timestamps

**FocusIntervalEntity:**
- Registro de intervalos de foco
- Início e fim de cada sessão
- Duração calculada automaticamente

**FocusModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- sessionsCompleted: Total de sessões de foco concluídas
- totalFocusMinutes: Total acumulado de minutos de foco
- currentStreakDays: Dias consecutivos com foco (streak atual)
- longestStreakDays: Maior streak de foco atingido
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
- unlockedAchievements: Lista de conquistas desbloqueadas
- respectedPeriods: Períodos de foco respeitados integralmente
- isModuleActive: Status de ativação do módulo
- Getters: respectedPeriodsCount, nextInsignia, disciplinumCount
- Sistema de serialização JSON para sincronização com nuvem

### Requisitos Técnicos:

- Permissão de acessibilidade (AccessibilityService)
- Permissão de uso de apps (UsageStats)
- Permissão de notificações
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- GamificationService para sistema de conquistas
- CloudSyncService para sincronização
- LockActivity (Android) para tela de bloqueio
- FocusService para lógica de negócio
- FocusServiceLocal para monitoramento local

### Fluxo de Uso:

1. Usuário concede permissões (acessibilidade, uso, notificações)
2. Usuário seleciona aplicativos a bloquear
3. Usuário define horário de início e fim do foco
4. Usuário ativa o módulo
5. Service local monitora abertura de apps durante período
6. Ao tentar abrir app bloqueado, exibe tela de bloqueio
7. Sistema tracking tempo de foco e registra sessões (FocusIntervalEntity)
8. Sistema calcula streak de dias focados
9. Gamificação recompensa progresso
10. Estatísticas mostram progresso

### Seção "Como Funciona":

InfoCards explicativos:
- "Selecione Apps: escolha o que bloquear"
- "Defina Horários: período de foco"
- "Inicie Foco: comece sua sessão"
- "Acompanhe: veja seu progresso"
