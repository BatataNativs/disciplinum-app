É um módulo focado em ajudar usuários a evitar conteúdo adulto através de bloqueio de aplicativos e sistema AppLock.

### Funcionalidades Principais:

1. **Sistema AppLock**
   - Bloqueio de aplicativos selecionados (enableAppLock)
   - Lista de aplicativos monitorados (monitoredApps)
   - Tela de bloqueio ao tentar abrir apps restritos
   - Mensagem personalizada de bloqueio (appLockMessage)
   - Requerimento de senha para desbloqueio (appLockRequirePassword)
   - Cooldown após tentativa de acesso (appLockCooldownMinutes, padrão: 10 minutos)

2. **Seleção de Aplicativos**
   - Interface para selecionar apps a serem monitorados
   - Integração com SelectAppsScreen
   - Suporte a múltiplos aplicativos
   - Persistência da lista de apps

3. **Sistema de Bloqueio**
   - Bloqueio por período (blockedUntil)
   - Motivo do bloqueio (blockReason)
   - Limite diário de uso (dailyLimitMinutes, padrão: 60 minutos)
   - Requerimento de senha para desbloqueio (requirePassword)

4. **Permissões Necessárias**
   - Permissão de acessibilidade (AccessibilityService)
   - Permissão de uso de apps (UsageStats)
   - Permissão de notificações
   - Diálogos de solicitação de permissão

5. **Gamificação**
   - Sistema de medalhas e insignias
   - Streak tracking (dias sem acessar conteúdo adulto)
   - Celebrações ao atingir metas
   - Estatísticas detalhadas de progresso
   - Service local para gamificação (adultContentServiceLocalProvider)
   - Sistema de estágios (bronze/prata/ouro/diamante)

6. **Interface**
   - Tela principal de configuração (AvoidAdultContentScreen)
   - Tela de notificações (AvoidAdultContentNotificationsScreen)
   - Widget de progresso (MyProgressAdultContent)
   - Widget de celebração ao atingir metas
   - Diálogo de desativação do módulo

7. **Persistência**
   - Configurações salvas localmente via ObjectBox
   - Lista de aplicativos monitorados
   - Estado de ativação do módulo
   - Histórico de bloqueios
   - Sincronização com nuvem (via CloudSyncService)

8. **Monitoramento em Tempo Real**
   - Service local detecta abertura de apps monitorados
   - Exibe tela de bloqueio LockActivity
   - Registra tentativas de acesso
   - Aplica cooldown após tentativas

### Estrutura de Dados:

**AdultContentConfigEntity:**
- userId: ID do usuário
- isModuleActive: Status de ativação do módulo
- blockedUntil: Data/hora até quando está bloqueado
- blockReason: Motivo do bloqueio
- dailyLimitMinutes: Limite diário em minutos (padrão: 60)
- requirePassword: Requer senha para desbloqueio
- enableAppLock: Habilita sistema AppLock
- monitoredApps: Lista de package names monitorados
- appLockRequirePassword: Requer senha no AppLock
- appLockMessage: Mensagem da tela de bloqueio
- appLockCooldownMinutes: Cooldown em minutos (padrão: 10)
- createdAt/updatedAt: Timestamps

**AdultContentModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- consecutiveDays: Dias consecutivos sem acessar conteúdo adulto
- disciplinumCount: Contador de conquistas de disciplina
- lastBlockedDate: Data do último bloqueio registrado
- startDate: Data de início do módulo
- isModuleActive: Status de ativação
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
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
- AdultContentService para lógica de negócio
- AdultContentServiceLocal para monitoramento local
- AdultContentAppLockService para integração com AppLock

### Fluxo de Uso:

1. Usuário concede permissões (acessibilidade, uso, notificações)
2. Usuário seleciona aplicativos a monitorar
3. Usuário ativa o módulo
4. Service local monitora abertura de apps
5. Ao tentar abrir app monitorado, exibe tela de bloqueio
6. Usuário pode desbloquear com senha (se configurado)
7. Sistema aplica cooldown após tentativa
8. Gamificação recompensa dias sem acessar conteúdo
9. Estatísticas mostram progresso

### Mensagem Padrão de Bloqueio:
"Pare! Você está tentando acessar apps restritos durante seu Jejum 18+."

### Pendências Funcionais:

- Implementar janela de bloqueio com horário inicial e final
- Implementar regras diferentes para dias úteis e finais de semana
- Expandir tela de notificações com configurações completas
- Implementar tela de estatísticas detalhadas
