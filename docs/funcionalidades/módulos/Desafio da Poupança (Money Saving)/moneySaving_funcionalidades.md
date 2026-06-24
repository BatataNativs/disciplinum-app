É um módulo focado em ajudar pessoas a economizar dinheiro através de desafios de poupança gamificados.

Funciona através de um sistema de grid onde o usuário marca células conforme economiza valores específicos.

### Funcionalidades Principais:

1. **Sistema de Desafios de Poupança**
   - O usuário pode criar desafios com metas de economia (ex: economizar R$ 1000 em 30 dias)
   - Cada desafio possui um grid de células que representam valores a serem economizados
   - O usuário marca as células conforme economiza os valores correspondentes
   - O sistema calcula automaticamente o progresso e total economizado

2. **Configuração do Desafio**
   - Título personalizado do desafio
   - Valor alvo (targetAmount)
   - Período do desafio (periodValue + periodType: dias/semanas/meses)
   - Tamanho do grid (gridSize)
   - Valor mínimo por célula (minValue)
   - Valor máximo por célula (maxValue)
   - Moeda (currency, padrão: R$)

3. **Sistema de Grid de Células**
   - Cada célula representa um valor específico a ser economizado
   - O usuário marca as células conforme economiza
   - Cada célula registra se foi marcada (isMarked) e quando (markedAt)
   - Valores das células podem variar entre minValue e maxValue
   - Visualização do grid em tela cheia (FullScreenGridPage)

4. **Cálculos Automáticos**
   - Total economizado baseado nas células marcadas
   - Progresso do desafio (0.0 a 1.0)
   - Percentual de conclusão

5. **Metas e Transações (SavingHabit)**
   - Criação de metas de economia com título, valor alvo e prazo (SavingGoal)
   - Registro de transações financeiras: depósitos e saques (TransactionRecord)
   - Categorização de depósitos por categoria
   - Cálculo de progresso por meta
   - Cálculo de economia por categoria
   - Taxa de economia mensal
   - Verificação de metas atingidas no dia

6. **Gamificação**
   - Sistema de medalhas e insignias
   - Streak tracking (dias consecutivos economizando)
   - Celebrações ao atingir metas
   - Estatísticas detalhadas de progresso
   - Sistema de estágios (bronze/prata/ouro/diamante)
   - Mensagens motivacionais por marcos (1 dia, 7, 14, 21, 30, 90, 180, 365 dias)

7. **Notificações**
   - Lembretes diários para economizar
   - Alertas de progresso
   - Notificações de conclusão de desafio
   - Configuração de frequência (diário/semanal)
   - Configuração de horário do lembrete

8. **Persistência**
   - Desafios salvos localmente via ObjectBox
   - Estado de ativação do desafio
   - Histórico de desafios completados
   - Dados sincronizados com nuvem (via CloudSyncService)

9. **Interface**
   - Tela principal com grid interativo (MoneySavingChallengeScreen)
   - Tela de grid em tela cheia (FullScreenGridPage)
   - Tela de contribuições sobre o desafio (MoneySavingChallengeAboutContributions)
   - Tela de total de contribuições (MoneySavingChallengeTotalContributions)
   - Tela de notificações (MoneySavingChallengeNotificationsScreen)
   - Tela de estatísticas e progresso (MoneySavingChallengeStats)
   - Widget de celebração ao completar metas

### Estrutura de Dados:

**MoneySavingChallengeEntity:**
- challengeId: Identificador único do desafio
- userId: ID do usuário
- title: Título do desafio
- targetAmount: Valor alvo a economizar
- periodValue: Valor do período (ex: 30)
- periodType: Tipo de período (dias/semanas/meses)
- gridSize: Tamanho do grid (número de células)
- minValue: Valor mínimo por célula
- maxValue: Valor máximo por célula
- currency: Moeda (padrão: R$)
- isActive: Status de ativação
- createdAt/updatedAt: Timestamps

**MoneySavingGridCellEntity:**
- challengeId: ID do desafio relacionado
- cellIndex: Índice da célula no grid
- value: Valor da célula
- isMarked: Se foi marcada
- markedAt: Quando foi marcada
- createdAt/updatedAt: Timestamps

**MoneySavingConfigEntity:**
- Configuração geral do módulo (separada dos desafios individuais)
- isModuleActive: Status de ativação do módulo
- userId: ID do usuário

**SavingHabit:**
- userId: ID do usuário
- startDate: Data de início do hábito
- goals: Lista de metas de economia (SavingGoal)
- transactions: Histórico de transações (TransactionRecord)
- preferences: Preferências do usuário
- currentStreak: Streak atual de dias economizando
- lastDeposit: Data do último depósito
- totalSaved: Total economizado
- depositsThisMonth: Depósitos no mês atual
- averageDepositAmount: Valor médio de depósito
- Getters: hasStartedSaving, daysSinceLastDeposit, monthlySavingRate
- Métodos: depositedToday(), getMotivationalMessage(), getNextMilestone(), reachedMilestone(), getGoalsProgress(), getSavingsByCategory()

**SavingGoal:**
- id: Identificador único da meta
- title: Título da meta
- description: Descrição
- targetAmount: Valor alvo
- createdAt: Data de criação
- deadline: Prazo (opcional)
- category: Categoria da meta (padrão: "Geral")
- icon: Ícone opcional
- isCompleted: Se foi concluída
- Getters: isOverdue (atrasada), isUrgent (vence em 7 dias)

**TransactionRecord:**
- id: Identificador único da transação
- timestamp: Momento da transação
- amount: Valor
- type: Tipo (deposit/withdrawal)
- category: Categoria opcional
- description: Descrição opcional
- goalId: ID da meta associada (opcional)

**MoneySavingModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- consecutiveDays: Dias consecutivos economizando
- disciplinumCount: Contador de conquistas de disciplina
- totalSavedAmount: Total acumulado economizado
- bestStreak: Melhor streak atingido
- lastSavingDate: Data do último registro de economia
- startDate: Data de início do módulo
- isModuleActive: Status de ativação do módulo
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
- gridPercentage: Percentual de conclusão do grid atual
- streakBroken: Se o streak foi quebrado
- Sistema de serialização JSON para sincronização com nuvem

### Requisitos Técnicos:

- Permissão de notificações para lembretes
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- GamificationService para sistema de conquistas
- CloudSyncService para sincronização
- MoneySavingChallengeService para lógica de negócio

### Fluxo de Uso:

1. Usuário cria um desafio de poupança com meta e período
2. Sistema gera grid de células com valores aleatórios dentro da faixa configurada
3. Usuário marca células conforme economiza os valores
4. Sistema calcula progresso e total economizado
5. Gamificação recompensa marcos e streaks
6. Notificações lembram de economizar regularmente
7. Estatísticas mostram progresso e histórico de contribuições
