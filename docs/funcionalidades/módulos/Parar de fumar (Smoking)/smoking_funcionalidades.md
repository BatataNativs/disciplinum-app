É um módulo focado em ajudar usuários a pararem de fumar através de tracking de cigarros, cálculo de benefícios econômicos e de saúde, e gamificação.

### Funcionalidades Principais:

1. **Sistema de Check-in Diário**
   - Registro diário de cigarros fumados
   - Tracking de progresso ao parar
   - Data de início do processo (quitDate)
   - Cálculo de dias sem fumar
   - SmokingCheckinService para gerenciamento de check-ins

2. **Configuração do Hábito**
   - Número de cigarros por dia (dailyCigarettes)
   - Preço por maço (pricePerPack)
   - Cigarros por maço (cigarettesPerPack, padrão: 20)
   - Moeda (currency, padrão: R$)
   - Data de parada (quitDate)

3. **Cálculo de Benefícios Econômicos**
   - Dinheiro economizado por dia
   - Dinheiro economizado total
   - Maços não fumados
   - Cálculo baseado em preço e quantidade
   - SmokingEconomicBenefit para cálculos

4. **Cálculo de Benefícios de Saúde**
   - Melhoras no corpo ao parar de fumar
   - Timeline de recuperação (20 min, 8h, 24h, 48h, etc.)
   - Benefícios por tempo sem fumar
   - SmokingHealthBenefit para cálculos

5. **Frases Motivacionais**
   - Sistema de frases motivacionais aleatórias
   - Frases específicas para marcos de tempo
   - SmokingMotivationalPhraseService para gerenciamento

6. **Gamificação**
   - Sistema de medalhas e insignias
   - Streak tracking (dias sem fumar)
   - Celebrações ao atingir marcos (1 dia, 1 semana, 1 mês, etc.)
   - Conquistas por benefícios de saúde (earnedHealthBenefits)
   - Estatísticas detalhadas de progresso
   - Notificações especiais para marcos
   - Sistema de estágios (bronze/prata/ouro/diamante)

7. **Interface**
   - Tela principal (StopSmokingScreen)
   - Widget de ações (StopSmokingActionsWidget)
   - Tela de notificações (SmokingNotificationsScreen)
   - Tela de estatísticas de check-ins (DailyCheckinsStats)
   - Tela de detalhe de benefícios de saúde (HealthDetailScreen)
   - Tela de detalhe de economia financeira (SavingsDetailScreen)
   - Widget de progresso (MyProgressSmoking)
   - Widget de celebração ao atingir marcos
   - Display de benefícios econômicos e de saúde

8. **Persistência**
   - Configurações salvas localmente via ObjectBox
   - Histórico de check-ins diários
   - Dados de benefícios calculados
   - Sincronização com nuvem (via CloudSyncService)

9. **Backup de Dados**
   - Último preço do maço (lastPackPrice)
   - Últimos maços por dia (lastPacksPerDay)
   - Última data de parada (lastQuitDate)
   - Última moeda (lastCurrency)
   - Último total economizado (lastSavedTotal)
   - Última data final (lastEndDate)

### Estrutura de Dados:

**SmokingConfigEntity:**
- userId: ID do usuário
- isModuleActive: Status de ativação do módulo
- dailyCigarettes: Cigarros por dia
- pricePerPack: Preço por maço
- cigarettesPerPack: Cigarros por maço (padrão: 20)
- quitDate: Data de parada
- currency: Moeda (padrão: R$)

**Backup de Dados:**
- lastPackPrice: Último preço do maço
- lastPacksPerDay: Últimos maços por dia
- lastQuitDate: Última data de parada
- lastCurrency: Última moeda
- lastSavedTotal: Último total economizado
- lastEndDate: Última data final

**SmokingModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- earnedHealthBenefits: Marcos de saúde alcançados (lista de IDs)
- consecutivePositiveDays: Dias consecutivos sem fumar
- disciplinumCount: Contador de conquistas de disciplina
- lastPositiveCheckIn: Data do último check-in positivo
- startDate: Data de início do controle
- dailyCost: Custo diário do cigarro (para cálculo de economia)
- packCost: Custo por maço
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
- Getters calculados:
  - totalDaysWithoutSmoking: Dias totais sem fumar desde startDate
  - totalMoneySaved: Dinheiro total economizado (dailyCost × consecutivePositiveDays)
  - packsSaved: Número de maços economizados
  - isInStreak: Se está em streak ativo
  - hasSignificantStreak: Se tem 7+ dias de streak

**SmokingSettingsModel:**
- Modelo de configuração auxiliar para a tela de configurações

**SmokingEconomicBenefit:**
- Cálculo de dinheiro economizado
- Cálculo de maços não fumados
- Cálculo de cigarros não fumados

**SmokingHealthBenefit:**
- Timeline de recuperação
- Benefícios por tempo sem fumar
- Melhoras no corpo

### Requisitos Técnicos:

- Permissão de notificações para lembretes e marcos
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- GamificationService para sistema de conquistas
- CloudSyncService para sincronização
- SmokingService para lógica de negócio
- SmokingCheckinService para check-ins diários
- SmokingMotivationalPhraseService para frases motivacionais
- SmokingSpecialNotificationsService para notificações de marcos

### Fluxo de Uso:

1. Usuário configura hábito (cigarros por dia, preço, etc.)
2. Usuário define data de parada
3. Usuário faz check-in diário
4. Sistema calcula dias sem fumar
5. Sistema calcula benefícios econômicos
6. Sistema calcula benefícios de saúde
7. Sistema exibe frases motivacionais
8. Gamificação recompensa marcos
9. Notificações celebram conquistas
10. Estatísticas mostram progresso detalhado

### Benefícios de Saúde (Timeline):

- **20 minutos:** Pressão sanguínea e pulso normalizam
- **8 horas:** Nível de oxigênio no sangue normaliza
- **24 horas:** Nível de monóxido de carbono cai para normal
- **48 horas:** Paladar e olfato melhoram
- **2 semanas:** Circulação melhora
- **1 mês:** Tosse diminui, respiração melhora
- **1 ano:** Risco de doença cardíaca cai pela metade
- **5-15 anos:** Risco de derrame cai para o de não-fumante
- **10 anos:** Risco de câncer de pulmão cai pela metade
- **15 anos:** Risco de doença cardíaca igual a não-fumante

### Benefícios Econômicos:

- Cálculo baseado em: (cigarros por dia / cigarros por maço) × preço por maço × dias sem fumar
- Exemplo: (20 / 20) × R$ 15,00 × 30 dias = R$ 450,00 economizados no primeiro mês
