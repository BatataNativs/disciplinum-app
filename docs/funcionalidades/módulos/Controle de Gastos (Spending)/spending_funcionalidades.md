É um módulo focado em ajudar usuários a controlarem seus gastos, gerenciarem despesas fixas e evitarem compras por impulso através do bloqueio de aplicativos de e-commerce e delivery.

### Funcionalidades Principais:

1. **Seleção de Aplicativos**
   - Interface para selecionar apps de e-commerce, delivery e serviços a monitorar
   - Integração com SelectAppsScreen
   - Suporte a múltiplos aplicativos selecionados
   - Persistência da lista de apps monitorados

2. **Permissões Necessárias**
   - Permissão de acessibilidade para monitoramento em tempo real
   - Permissão de uso de apps (UsageStats) para identificar abertura de aplicativos
   - Permissão de notificações para alertas e lembretes
   - Permissão de sobreposição de tela (overlay) para exibir tela de bloqueio
   - Fluxo de solicitação antes de ativar o módulo

3. **Bloqueio de Aplicativos**
   - Bloqueio dos apps selecionados quando o módulo está ativo
   - Integração com AppLock e LockActivity
   - Monitoramento via AccessibilityService
   - Desativação com diálogo de confirmação e reset de progresso

4. **Gerenciamento de Gastos Fixos (FixedExpensesScreen)**
   - Cadastro de despesas fixas mensais (FixedExpenseModel)
   - Campos: nome, valor, moeda, dia de vencimento, status de pagamento
   - Marcação de despesa como paga/não paga
   - Edição e exclusão de despesas
   - Cálculo do total mensal
   - Exibição de urgência conforme proximidade do vencimento

5. **Estatísticas de Contas Fixas (FixedBillsStatsScreen)**
   - Resumo do mês atual
   - Histórico de pagamentos
   - Comparação de gastos pagos e pendentes
   - Base para gráficos de evolução mensal

6. **Navegação por Abas**
   - Aba "Controlar Gastos": visão geral, apps monitorados, ativação do módulo
   - Aba "Como Funciona": cards explicativos do módulo

7. **Notificações de Vencimento**
   - Notificação mensal no dia de vencimento do gasto
   - Horário padrão de lembrete às 09:00
   - Cancelamento de lembrete ao remover gasto
   - Reagendamento ao editar gasto
   - Possível evolução: notificar 3 dias antes, 1 dia antes e no dia do vencimento
   - Tela de notificações dedicada (SpendingNotificationsScreen)

8. **Estatísticas Financeiras**
   - Tela de estatísticas de gastos fixos (FixedBillsStatsScreen)
   - Resumo do mês atual
   - Histórico de pagamentos
   - Comparação de gastos pagos e pendentes
   - Base para gráficos de evolução mensal

9. **Gamificação**
   - Streak de dias controlando gastos (consecutiveDays)
   - Medalhas e insignias próprias do módulo
   - Registro de gastos evitados (totalExpensesAvoided)
   - Total de dinheiro economizado (totalMoneySaved)
   - Metas financeiras e orçamento mensal (monthlyBudget)
   - Celebrações ao atingir marcos de economia
   - Sistema de estágios (bronze/prata/ouro/diamante)

10. **Persistência**
    - Configurações salvas localmente via ObjectBox
    - Gastos fixos salvos localmente como ExpenseEntity
    - Sincronização de gastos fixos com nuvem
    - Sincronização do estado ativo do módulo
    - Dados de gamificação persistidos por usuário

### Estrutura de Dados:

**SpendingConfigEntity:**
- userId: ID do usuário
- isModuleActive: Status de ativação do módulo
- monthlyBudget: Orçamento mensal
- currency: Moeda padrão (padrão: R$)
- enableNotifications: Habilita notificações (padrão: true)
- reminderDay: Dia do mês para lembrete geral (1-31)
- createdAt/updatedAt: Timestamps

**FixedExpenseModel:**
- id: Identificador do gasto
- name: Nome do gasto fixo
- amount: Valor
- currency: Moeda
- dueDay: Dia de vencimento
- isPaid: Status de pagamento
- lastPaid: Data do último pagamento
- notificationsEnabled: Notificações habilitadas para o gasto

**ExpenseEntity:**
- Persistência local do FixedExpenseModel via ObjectBox
- Conversão para/de domínio
- Base para sincronização local e nuvem

**SpendingModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- consecutiveDays: Dias consecutivos controlando gastos
- disciplinumCount: Contador de conquistas de disciplina
- totalMoneySaved: Total de dinheiro economizado
- totalExpensesAvoided: Total de compras/gastos evitados
- monthlyBudget: Orçamento mensal configurado
- isModuleActive: Status de ativação do módulo
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
- consecutiveMonths: Meses consecutivos controlando gastos
- Sistema de serialização JSON para sincronização com nuvem

### Requisitos Técnicos:

- Permissão de acessibilidade (AccessibilityService)
- Permissão de uso de apps (UsageStats)
- Permissão de notificações
- Permissão de sobreposição de tela (overlay)
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- CloudSyncService para sincronização
- NotificationService para lembretes mensais
- SpendingService para lógica de gastos fixos
- SpendingServiceWrapper para integração com camada de dados
- SpendingConfigRepository para configuração do módulo
- SpendingGamificationService para progresso e conquistas
- LockActivity/AppLock para bloqueio em tempo real

### Fluxo de Uso:

1. Usuário concede permissões de acessibilidade, uso, notificações e sobreposição
2. Usuário seleciona aplicativos de e-commerce/delivery a bloquear
3. Usuário inicia o módulo de controle de gastos
4. App salva configuração e ativa o estado do módulo
5. Service local monitora tentativas de abertura dos apps selecionados
6. Ao tentar abrir app bloqueado, o app exibe tela de bloqueio
7. Usuário cadastra gastos fixos com valor e vencimento
8. App agenda notificações mensais dos gastos
9. Usuário marca despesas como pagas
10. Estatísticas exibem resumo mensal e histórico
11. Gamificação recompensa dias de controle e gastos evitados

### Seção "Como Funciona":

InfoCards explicativos:
- "Selecione Apps de Compras: e-commerce, delivery e serviços a controlar"
- "Acompanhe em Tempo Real: visualize gastos diários, semanais e mensais"
- "Alertas Personalizados: notificações de limites e metas financeiras"
- "Análise de Padrões: entenda seus hábitos de consumo"

### Pendências Funcionais:

- Implementar categoria/tipo de bloqueio: e-commerce, delivery ou ambos
- Persistir apps bloqueados na configuração específica do módulo Spending
- Implementar janela de bloqueio com horário inicial e final
- Implementar regras diferentes para dias úteis e finais de semana
- Exibir contagem regressiva até o fim do período definido
- Criar tela "Segurando a Onda" com apps bloqueados e vidas diárias
- Notificar 3 dias antes, 1 dia antes e no dia do vencimento dos gastos fixos
- Expandir estatísticas com gráficos detalhados e valores economizados