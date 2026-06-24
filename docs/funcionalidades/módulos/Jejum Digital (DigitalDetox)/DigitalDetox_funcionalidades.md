É um módulo focado em ajudar usuários a reduzir o tempo de uso de redes sociais e apps através de múltiplas estratégias de controle e gamificação.

### Funcionalidades Principais:

1. **Seleção de Aplicativos**
   - Interface para selecionar apps de redes sociais a monitorar
   - Apps comuns pré-configurados (Instagram, Facebook, TikTok, Snapchat, Twitter, WhatsApp, YouTube, Discord, Pinterest, LinkedIn, Reddit, Telegram, Twitch)
   - Carregamento de ícones reais dos apps
   - Persistência da lista de apps monitorados

2. **Bloqueio por Horário (FASE 2)**
   - Janela de tempo permitido (enableTimeWindow)
   - Horário de início permitido (allowedStartTime, padrão: 08:00)
   - Horário de fim permitido (allowedEndTime, padrão: 22:00)
   - Bloqueio diferente em finais de semana (blockOnWeekends)
   - Horários específicos para finais de semana (weekendAllowedStartTime/endTime)

3. **Limite de Tempo Diário (FASE 3)**
   - Limite diário de uso em minutos (enableDailyLimit)
   - Valor do limite (dailyLimitMinutes, padrão: 60)
   - Tipo de limite: global ou por app (limitType)
   - Aviso antes de atingir limite (warnBeforeLimitMinutes, padrão: 5)

4. **Notificação Pré-Detox (FASE 4)**
   - Aviso antes do período de bloqueio (enablePreDetoxWarning)
   - Minutos antes do aviso (preDetoxWarningMinutes, padrão: 5)
   - Mensagem personalizada de aviso (preDetoxWarningMessage)

5. **Horas Cumulativas - Rollover (FASE 6A)**
   - Acúmulo de minutos não usados (enableRolloverMinutes)
   - Máximo de minutos acumulados (maxRolloverMinutes, padrão: 60)
   - Expiração do acúmulo em dias (rolloverExpirationDays, padrão: 7)

6. **Limite Semanal (FASE 6B)**
   - Limite semanal de uso (enableWeeklyLimit)
   - Valor do limite semanal (weeklyLimitMinutes, padrão: 540 = 9 horas)
   - Estratégia: strict ou flexible (weeklyLimitStrategy)

7. **Sessões Controladas (FASE 6C)**
   - Modo de sessões controladas (enableSessionMode)
   - Duração de cada sessão (sessionDurationMinutes, padrão: 10)
   - Cooldown entre sessões (sessionCooldownHours, padrão: 2)
   - Máximo de sessões por dia (maxSessionsPerDay, padrão: 4)
   - Limite diário em modo sessão (sessionDailyLimitMinutes, padrão: 40)

8. **Gamificação / Streaks (FASE 4)**
   - Streak atual de dias disciplinados (currentDisciplinedStreak)
   - Streak mais longo (longestDisciplinedStreak)
   - Total de dias disciplinados (totalDisciplinedDays)
   - Data do último dia disciplinado (lastDisciplinedDate)
   - Sistema de conquistas e medalhas

9. **Quebra de Jejum (FASE 7)**
   - Dias de disciplina necessários para quebra (fastingBreakDaysRequired, padrão: 7)
   - Validade da quebra em dias (fastingBreakValidityDays, padrão: 30)
   - Tela de Fasting Breaks Screen
   - Registro de quebras de jejum

10. **Interface**
    - Tela principal (DigitalDetoxScreen)
    - Tela de configuração de tempo (DigitalDetoxTimeSettingsScreen)
    - Tela de limites/estatísticas (DigitalDetoxStatsScreen)
    - Tela de quebras de jejum (DigitalDetoxFastingBreaksScreen)
    - Tela de horas acumuladas/rollover (DigitalDetoxRolloverScreen)
    - Tela de sessões controladas (DigitalDetoxSessionsScreen)
    - Tela de limite semanal (DigitalDetoxWeeklyScreen)
    - Tela de progresso (MyProgressDigitalDetox)
    - Widget de celebração ao atingir metas

11. **Persistência**
    - Configurações salvas localmente via ObjectBox
    - Lista de aplicativos monitorados
    - Histórico de sessões e streaks
    - Registro de quebras de jejum
    - Estatísticas diárias agregadas (DigitalDetoxStatsEntity)
    - Sincronização com nuvem (via CloudSyncService)

### Estrutura de Dados:

**DigitalDetoxConfigEntity:**
- userId: ID do usuário
- isModuleActive: Status de ativação do módulo
- monitoredApps: Lista de package names monitorados

**Bloqueio por Horário:**
- enableTimeWindow: Habilita bloqueio por horário
- allowedStartTime/endTime: Janela de tempo permitido
- blockOnWeekends: Bloqueio diferente em finais de semana
- weekendAllowedStartTime/endTime: Horários específicos finais de semana

**Limite Diário:**
- enableDailyLimit: Habilita limite diário
- dailyLimitMinutes: Valor do limite (padrão: 60)
- limitType: "global" ou "perApp"
- warnBeforeLimitMinutes: Aviso antes do limite (padrão: 5)

**Notificação Pré-Detox:**
- enablePreDetoxWarning: Habilita aviso pré-detox
- preDetoxWarningMinutes: Minutos antes do aviso (padrão: 5)
- preDetoxWarningMessage: Mensagem personalizada

**Rollover:**
- enableRolloverMinutes: Habilita acúmulo
- maxRolloverMinutes: Máximo acumulado (padrão: 60)
- rolloverExpirationDays: Expiração em dias (padrão: 7)

**Limite Semanal:**
- enableWeeklyLimit: Habilita limite semanal
- weeklyLimitMinutes: Valor do limite (padrão: 540)
- weeklyLimitStrategy: "strict" ou "flexible"

**Sessões Controladas:**
- enableSessionMode: Habilita modo sessão
- sessionDurationMinutes: Duração da sessão (padrão: 10)
- sessionCooldownHours: Cooldown entre sessões (padrão: 2)
- maxSessionsPerDay: Máximo de sessões (padrão: 4)
- sessionDailyLimitMinutes: Limite diário em modo sessão (padrão: 40)

**Gamificação:**
- currentDisciplinedStreak: Streak atual
- longestDisciplinedStreak: Streak mais longo
- totalDisciplinedDays: Total de dias disciplinados
- lastDisciplinedDate: Data do último dia disciplinado

**Quebra de Jejum:**
- fastingBreakDaysRequired: Dias necessários (padrão: 7)
- fastingBreakValidityDays: Validade em dias (padrão: 30)

**DigitalDetoxSessionEntity:**
- userId: ID do usuário
- appPackageName: Package do app usado
- appName: Nome legível do app
- sessionStart: Início da sessão
- sessionEnd: Fim da sessão (null se ativa)
- durationMinutes: Duração em minutos (calculada ao finalizar)
- date: Data da sessão (sem hora, para queries por dia)
- wasBlocked: Se terminou por bloqueio do AppLock
- sessionType: "free" ou "controlled" (modo sessão controlada)
- wasSessionCompleted: Se a sessão controlada usou todo o tempo

**DigitalDetoxStatsEntity:**
- userId: ID do usuário
- date: Data (sem hora), indexada para queries rápidas
- totalScreenTimeMinutes: Tempo total de tela no dia em minutos
- appBreakdownJson: JSON com tempo por app (ex: {"com.instagram.android": 45})
- openCount: Quantas vezes abriu apps monitorados
- longestSessionMinutes: Sessão mais longa do dia em minutos
- weekNumber: Número da semana (1-53) para queries semanais
- monthNumber: Número do mês (1-12) para queries mensais
- year: Ano
- wasDisciplinedDay: Se foi um dia "disciplinado" (para streak)
- usedFastingBreak: Se usou Quebra de Jejum neste dia

### Requisitos Técnicos:

- Permissão de acessibilidade (AccessibilityService)
- Permissão de uso de apps (UsageStats)
- Permissão de notificações
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- GamificationService para sistema de conquistas
- CloudSyncService para sincronização
- LockActivity (Android) para tela de bloqueio
- DigitalDetoxServiceLocal para monitoramento local
- DigitalDetoxSessionManager para gerenciamento de sessões
- DigitalDetoxTimeTracker para tracking de tempo
- DigitalDetoxTimeChecker para verificação de janelas de horário
- DigitalDetoxWeeklyManager para gerenciamento semanal
- DigitalDetoxRolloverManager para acúmulo de minutos
- DigitalDetoxAppLockService para integração com AppLock

### Fluxo de Uso:

1. Usuário concede permissões (acessibilidade, uso, notificações)
2. Usuário seleciona apps de redes sociais a monitorar
3. Usuário configura estratégias (horário, limite diário, sessões, etc.)
4. Usuário ativa o módulo
5. Service local monitora uso dos apps
6. Sistema aplica bloqueios conforme configurações
7. Sistema tracking tempo de uso (DigitalDetoxTimeTracker)
8. Sistema registra cada sessão (DigitalDetoxSessionEntity)
9. Sistema salva estatísticas diárias (DigitalDetoxStatsEntity)
10. Sistema calcula streak de dias disciplinados
11. Gamificação recompensa progresso
12. Usuário pode solicitar quebras de jejum após atingir requisitos
