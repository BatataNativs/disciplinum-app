É um módulo focado em ajudar usuários a manterem uma dieta saudável através de tracking de refeições, metas nutricionais e gamificação.

### Funcionalidades Principais:

1. **Tracking de Refeições**
   - Registro de refeições ao longo do dia
   - Organização por períodos: Madrugada, Manhã, Tarde, Noite
   - Horários configuráveis para cada refeição (mealTimes)
   - Registro da última data de refeição (lastMealDate)
   - Rastreamento de refeições planejadas vs realizadas (MealEntryEntity)
   - Confirmação de refeição completada no horário previsto

2. **Metas Nutricionais**
   - Meta diária de calorias (calories, padrão: 2000)
   - Meta de proteínas (proteins, padrão: 150g)
   - Meta de carboidratos (carbs, padrão: 250g)
   - Meta de gorduras (fats, padrão: 65g)
   - Meta de fibras (fiber, padrão: 25g)
   - Meta de água (water, padrão: 2000ml)

3. **Sistema de Streak**
   - Contagem de dias consecutivos mantendo a dieta (streakDays)
   - Registro da última data de refeição
   - Cálculo automático de streak
   - Tela de Meal Streak Screen para visualização

4. **Tracking de Peso**
   - Registro de peso total perdido (totalWeightLost)
   - Histórico de progresso
   - Visualização em estatísticas

5. **Notificações e Lembretes**
   - Notificações habilitadas por padrão (enableNotifications)
   - Horário do lembrete configurável (reminderHour/reminderMinute, padrão: 12:00)
   - Lembretes para registrar refeições
   - Alertas de streak
   - Tela de notificações dedicada (DietNotificationsScreen)

6. **Gamificação**
   - Sistema de medalhas e insignias
   - Celebrações ao atingir metas nutricionais
   - Conquistas por streaks
   - Estatísticas detalhadas de progresso
   - Sistema de estágios (bronze/prata/ouro/diamante)

7. **Interface**
   - Tela principal de configuração da dieta (DietSettingsScreen)
   - Tela de notificações (DietNotificationsScreen)
   - Tela de Meal Streak (visualização de streaks)
   - Widget de progresso (MyProgressDiet)
   - Widget de celebração ao atingir metas

8. **Persistência**
   - Configurações salvas localmente via ObjectBox
   - Histórico de refeições (MealEntryEntity)
   - Dados de streak e progresso
   - Sincronização com nuvem (via CloudSyncService)

### Estrutura de Dados:

**DietConfigEntity:**
- userId: ID do usuário
- calories: Meta diária de calorias (padrão: 2000)
- proteins: Meta de proteínas (padrão: 150g)
- carbs: Meta de carboidratos (padrão: 250g)
- fats: Meta de gorduras (padrão: 65g)
- fiber: Meta de fibras (padrão: 25g)
- water: Meta de água (padrão: 2000ml)
- enableNotifications: Habilita notificações (padrão: true)
- reminderHour/reminderMinute: Horário do lembrete (padrão: 12:00)
- mealTimes: Lista de horários das refeições (padrão: ['08:00', '12:00', '18:00'])
- streakDays: Dias consecutivos mantendo dieta
- lastMealDate: Data da última refeição
- totalWeightLost: Peso total perdido
- createdAt/updatedAt: Timestamps

**MealEntryEntity:**
- userId: ID do usuário
- date: Data da refeição
- mealName: Nome/tipo da refeição (ex: "Café da manhã")
- plannedTime: Horário planejado da refeição
- actualTime: Horário real em que foi realizada (opcional)
- wasOnTime: Se a refeição foi feita no horário planejado
- wasCompleted: Se a refeição foi completada
- calories: Calorias da refeição (opcional)
- notes: Anotações (opcional)
- createdAt/updatedAt: Timestamps
- Métodos: isLastMealOfDay(), allMealsCompletedOnTime()

**DietModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- consecutiveDays: Dias consecutivos mantendo a dieta
- disciplinumCount: Contador de conquistas de disciplina
- isModuleActive: Status de ativação do módulo
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
- Sistema de serialização JSON para sincronização com nuvem

### Requisitos Técnicos:

- Permissão de notificações para lembretes
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- GamificationService para sistema de conquistas
- CloudSyncService para sincronização
- DietService para lógica de negócio
- Integração com módulo Schedule

### Fluxo de Uso:

1. Usuário configura metas nutricionais
2. Usuário define horários das refeições
3. Usuário registra refeições ao longo do dia (com horário planejado)
4. Sistema registra se a refeição foi feita no horário e se foi completada
5. Sistema calcula progresso vs metas nutricionais
6. Sistema mantém streak de dias com alimentação controlada
7. Gamificação recompensa progresso
8. Notificações lembram de registrar refeições
