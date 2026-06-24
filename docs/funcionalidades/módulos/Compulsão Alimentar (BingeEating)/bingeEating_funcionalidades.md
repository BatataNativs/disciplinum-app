É um módulo focado em auxiliar pessoas que sofrem de compulsão alimentar, principalmente reduzindo impulsos de pedir comida por aplicativos de delivery.

O módulo combina bloqueio de aplicativos, acompanhamento diário, notificações de check-in, orientação de apoio profissional e gamificação para reforçar períodos de controle.

### Funcionalidades Principais:

1. **Seleção de Aplicativos de Delivery**
   - Interface para selecionar aplicativos instalados no celular
   - Foco em aplicativos de entrega de comida e gatilhos relacionados
   - Suporte a múltiplos aplicativos selecionados
   - Persistência da lista de apps monitorados
   - Exibição dos aplicativos bloqueados na tela principal

2. **Permissões Necessárias**
   - Permissão de acessibilidade para monitoramento em tempo real
   - Permissão de uso de apps para identificar abertura de aplicativos
   - Permissão de notificações para check-ins e alertas
   - Fluxo de solicitação antes de ativar o módulo

3. **Bloqueio de Aplicativos**
   - Bloqueio dos apps selecionados quando o módulo está ativo
   - Integração com AppLock e tela nativa de bloqueio
   - Mensagem personalizada para tentativas de acesso
   - Cooldown após tentativa de violação
   - Configuração para exigir senha no AppLock

4. **Bloqueio por Período e Horários (Pendente)**
   - Definição de período de bloqueio pelo usuário
   - Cálculo de tempo restante até o fim do período
   - Suporte a regras diferentes para dias úteis e finais de semana
   - Notificação quando o período definido terminar
   - Reaproveitamento da lógica do Jejum Digital para janelas de horário

5. **Tela "Segurando a Onda" (Pendente)**
   - Exibição do tempo restante do bloqueio
   - Lista dos apps bloqueados no período atual
   - Estado visual de módulo ativo
   - Ação para encerrar o módulo usando uma vida limitada por dia
   - Mensagem de contenção antes de liberar acesso

6. **Check-in Diário**
   - Notificações configuráveis para perguntar se o usuário resistiu às tentações
   - Registro de resposta positiva ou negativa
   - Atualização de streak conforme comportamento diário
   - Reset ou penalização quando o usuário não resiste
   - Tela de notificações dedicada (BingeEatingNotificationsScreen)

7. **Apoio e Orientação**
   - Mensagens lembrando que o usuário não está sozinho
   - Orientação para buscar ajuda profissional quando necessário
   - Sugestões de procurar médico, nutricionista ou psicólogo
   - Linguagem acolhedora, sem julgamento

8. **Gamificação**
   - Streak de dias sem ceder a pedidos impulsivos
   - Medalhas e insignias próprias do módulo
   - Celebrações ao atingir marcos
   - Frases motivacionais durante o progresso
   - Integração com BingeEatingGamificationController
   - Sistema de estágios (bronze/prata/ouro/diamante)

9. **Estatísticas e Progresso**
   - Dias de controle acumulados
   - Streak atual e melhor streak
   - Total de check-ins positivos
   - Histórico de início do controle
   - Base para dashboards futuros com dados dos apps de delivery bloqueados

10. **Persistência**
    - Configurações salvas localmente via ObjectBox
    - Sincronização com nuvem quando usuário está autenticado
    - Lista de apps monitorados
    - Estado ativo/inativo do módulo
    - Dados de gamificação e progresso

### Estrutura de Dados:

**BingeEatingConfigEntity:**
- userId: ID do usuário
- isModuleActive: Status de ativação do módulo
- blockedUntil: Data/hora de bloqueio temporário após violação
- blockReason: Motivo do bloqueio atual
- dailyLimitMinutes: Limite diário base em minutos
- requirePassword: Exige senha para ações sensíveis
- triggerFoods: Lista de alimentos gatilho
- copingStrategies: Estratégias de enfrentamento
- enableNotifications: Habilita notificações
- reminderHour/reminderMinute: Horário padrão de lembrete
- enableAppLock: Habilita bloqueio de aplicativos
- monitoredApps: Lista de package names monitorados
- appLockRequirePassword: Exige senha no AppLock
- appLockMessage: Mensagem exibida no bloqueio
- appLockCooldownMinutes: Cooldown após tentativa de acesso
- createdAt/updatedAt: Timestamps

**BingeHabit:**
- userId: ID do usuário
- startDate: Data de início do controle
- currentStreak: Streak atual
- longestStreak: Maior streak
- totalDaysControlled: Total de dias em controle
- lastCheckInDate: Data do último check-in

**BingeEatingModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- consecutivePositiveDays: Dias consecutivos de controle positivo
- disciplinumCount: Contador de conquistas de disciplina
- isModuleActive: Status de ativação do módulo
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
- Sistema de serialização JSON para sincronização com nuvem

### Requisitos Técnicos:

- Permissão de acessibilidade (AccessibilityService)
- Permissão de uso de apps (UsageStats)
- Permissão de notificações
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- CloudSyncService para sincronização
- AppLockService para bloqueio em tempo real
- BingeEatingAppLockService para integração específica do módulo
- BingeEatingService para lógica de negócio
- BingeEatingServiceLocal para configurações locais e monitoramento
- BingeEatingGamificationService para progresso e conquistas
- LockActivity (Android) para tela de bloqueio

### Fluxo de Uso:

1. Usuário concede permissões de acessibilidade, uso e notificações
2. Usuário seleciona aplicativos de delivery a bloquear
3. Usuário configura lembretes e, futuramente, horários de bloqueio
4. Usuário inicia o módulo
5. App salva configuração e ativa AppLock para os apps selecionados
6. Service local monitora tentativas de abertura dos apps
7. Ao tentar abrir app bloqueado, o app exibe tela de bloqueio
8. Usuário responde check-ins diários
9. Sistema atualiza streak, estatísticas e gamificação
10. Usuário acompanha progresso na tela do módulo

### Pendências Funcionais:

- Implementar janela de bloqueio com horário inicial e final
- Implementar regras diferentes para dias úteis e finais de semana
- Exibir contagem regressiva até o fim do período definido
- Criar tela "Segurando a Onda" com apps bloqueados e vidas diárias
- Notificar quando o período permitido/liberado começar ou terminar
- Evoluir estatísticas com dados específicos de uso/bloqueio de apps de delivery