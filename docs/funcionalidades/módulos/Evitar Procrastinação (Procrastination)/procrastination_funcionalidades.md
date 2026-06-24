É um módulo focado em ajudar usuários a evitar procrastinação através de gerenciamento de tarefas, foco e bloqueio de aplicativos.

### Funcionalidades Principais:

1. **Sistema de Tarefas**
   - Criação de tarefas com títulos, descrições e horários
   - Agendamento com data (scheduledDate), hora de início (startTime) e hora de fim (endTime)
   - Status de tarefas (pendente, em progresso, concluída)
   - Ordem personalizada das tarefas dentro da lista (order)
   - Interface de TaskListWidget para visualização
   - TaskCreationDialog para criar novas tarefas

2. **Repetição de Tarefas**
   - Suporte a tarefas sem repetição (none)
   - Repetição diária, semanal, mensal, anual
   - Repetição personalizada (custom) via RepetitionConfig:
     - Intervalo (ex: a cada 2 semanas)
     - Dias da semana específicos
     - Data de início e fim da repetição
     - Limite por número de ocorrências

3. **Urgência Dinâmica**
   - Cálculo automático de nível de urgência baseado no prazo:
     - 🟢 Verde (Tranquilo): > 48h para tarefas sem horário, > 5h para tarefas com horário
     - 🟡 Amarelo (Atenção): 24–48h sem horário, 1–5h com horário
     - 🔴 Vermelho (Urgente): < 24h sem horário, < 1h com horário
   - Urgência registrada no momento da conclusão (completedUrgencyLevel)

4. **Gerenciamento de Listas**
   - Múltiplas listas de tarefas (TaskList)
   - ID de lista selecionável (selectedListId)
   - Tabs para navegar entre listas
   - Modo de ordenação por lista: personalizado (custom) ou por data (date)
   - Rastreamento de listas 100% concluídas sem atrasos (isFullyCompleted)
   - Tela de listas concluídas (CompletedListsScreen)

5. **Sistema de Foco**
   - Meta diária de minutos de foco (dailyFocusMinutes, padrão: 120)
   - Tracking de tempo de foco
   - Streak de dias focados (streakDays)
   - Data do último foco (lastFocusDate)
   - Total de minutos de foco (totalFocusMinutes)
   - Sessão mais longa de foco (longestFocusSession)

6. **Bloqueio de Aplicativos**
   - Habilitar bloqueio de apps (enableAppBlocking)
   - Lista de aplicativos bloqueados (blockedApps)
   - Duração do bloqueio em minutos (blockDurationMinutes, padrão: 30)
   - Integração com sistema de permissões

7. **Notificações e Lembretes**
   - Notificações habilitadas por padrão (enableNotifications)
   - Horário do lembrete configurável (reminderHour/reminderMinute, padrão: 9:00)
   - Lembretes para tarefas pendentes
   - Alertas de foco
   - Tela de notificações dedicada (ProcrastinationNotificationsScreen)

8. **Gamificação**
   - Sistema de medalhas e insignias
   - Streak tracking (dias consecutivos produtivos)
   - Celebrações ao completar tarefas
   - Conquistas por metas de foco
   - Estatísticas detalhadas de progresso
   - Sistema de estágios (bronze/prata/ouro/diamante)

9. **Interface**
   - Tela principal (ProcrastinationScreen)
   - Tabs: "Evitar procrastinação" e "Como funciona"
   - Tela de notificações (ProcrastinationNotificationsScreen)
   - Tela de estatísticas (ProcrastinationStatsScreen)
   - Tela de listas concluídas (CompletedListsScreen)
   - Widget de progresso (MyProgressProcrastination)
   - Widget de celebração ao atingir metas
   - TaskListWidget para lista de tarefas
   - TaskListHeader para cabeçalho da lista

10. **Persistência**
    - Configurações salvas localmente via ObjectBox
    - Lista de tarefas e listas
    - Dados de foco e streak
    - Sincronização com nuvem (via CloudSyncService)

### Estrutura de Dados:

**ProcrastinationConfigEntity:**
- userId: ID do usuário
- isModuleActive: Status de ativação do módulo
- dailyFocusMinutes: Meta diária de foco em minutos (padrão: 120)
- enableNotifications: Habilita notificações (padrão: true)
- reminderHour/reminderMinute: Horário do lembrete (padrão: 9:00)
- streakDays: Dias consecutivos produtivos
- lastFocusDate: Data do último foco
- totalFocusMinutes: Total acumulado de foco
- longestFocusSession: Sessão mais longa de foco
- enableAppBlocking: Habilita bloqueio de apps
- blockedApps: Lista de package names bloqueados
- blockDurationMinutes: Duração do bloqueio (padrão: 30)
- createdAt/updatedAt: Timestamps

**TaskList:**
- id: Identificador único da lista
- name: Nome da lista
- createdAt: Data de criação
- order: Posição da lista no conjunto (para reordenação)
- sortMode: Modo de ordenação ("custom" ou "date")
- isFullyCompleted: Se a lista foi 100% concluída sem atrasos
- completedAt: Data/hora da conclusão total da lista

**ProcrastinationTask:**
- id: Identificador único da tarefa
- title: Título da tarefa
- description: Descrição opcional
- scheduledDate: Data agendada (sem hora)
- startTime: Hora de início (opcional)
- endTime: Hora de fim (opcional)
- isCompleted: Se foi concluída
- listId: ID da lista à qual pertence
- order: Posição da tarefa na lista
- repetition: Tipo de repetição (none/daily/weekly/monthly/yearly/custom)
- repetitionConfig: Configuração detalhada de repetição personalizada
- completedUrgencyLevel: Nível de urgência no momento da conclusão

**RepetitionConfig:**
- interval: A cada X (número)
- unit: Unidade (day/week/month/year)
- weekDays: Dias da semana para repetição semanal (0=Dom, 1=Seg, etc.)
- startDate: Início da repetição
- endDate: Fim da repetição por data
- occurrences: Fim da repetição por número de ocorrências

**ProcrastinationDay:**
- date: Data do dia
- tasks: Lista de tarefas do dia
- isDayComplete: Se todas as tarefas foram concluídas
- isDayFailed: Se o dia passou sem cumprir as tarefas

**ProcrastinationModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- consecutiveProductiveDays: Dias consecutivos produtivos
- disciplinumCount: Contador de conquistas de disciplina
- totalTasksCompleted: Total de tarefas concluídas
- totalFocusMinutes: Total de minutos de foco acumulados
- isModuleActive: Status de ativação do módulo
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
- Sistema de serialização JSON para sincronização com nuvem

**ProductivityHabit:**
- Entidade de domínio para hábito de produtividade com histórico e métricas

### Enums de Domínio:

**UrgencyLevel:**
- green: Tranquilo (prazo com tempo de sobra)
- yellow: Atenção (prazo se aproximando)
- red: Urgente/Crítico (prazo iminente)

**TaskRepetition:**
- none: Sem repetição
- daily: Diariamente
- weekly: Semanalmente
- monthly: Mensalmente
- yearly: Anualmente
- custom: Personalizado

**SortMode:**
- custom: Ordem personalizada pelo usuário
- date: Agrupado por data

### Requisitos Técnicos:

- Permissão de notificações para lembretes
- Permissão de uso de apps (para bloqueio)
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- GamificationService para sistema de conquistas
- CloudSyncService para sincronização
- ProcrastinationService para lógica de negócio
- ProcrastinationServiceLocal para monitoramento local

### Fluxo de Uso:

1. Usuário cria listas de tarefas
2. Usuário adiciona tarefas às listas (com ou sem horário e repetição)
3. Usuário define meta diária de foco
4. Usuário pode configurar bloqueio de apps
5. Usuário marca tarefas como concluídas
6. Sistema registra nível de urgência no momento da conclusão
7. Sistema tracking tempo de foco
8. Sistema calcula streak de produtividade
9. Gamificação recompensa progresso
10. Notificações lembram de tarefas pendentes

### Seção "Como Funciona":

InfoCards explicativos:
- "Nova Tarefa: organize sua rotina"
- "Foco: elimine distrações"
- "Progresso: acompanhe sua evolução"
- "Bloqueio: apps que atrapalham"
