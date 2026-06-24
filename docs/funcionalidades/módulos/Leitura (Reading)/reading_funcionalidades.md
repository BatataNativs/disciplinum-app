É um módulo focado em ajudar usuários a desenvolverem o hábito de leitura através de tracking de livros, metas diárias e gamificação.

### Funcionalidades Principais:

1. **Sistema de Livros**
   - Adição de livros à estante pessoal
   - Tracking de progresso de leitura por livro
   - Registro de páginas lidas
   - Registro de data de início e fim de leitura
   - Categorização por tema/gênero literário (ReadingTheme)
   - Logs de leitura por sessão (ReadingLog)
   - Cálculo de data estimada de conclusão
   - Interface MyShelfScreen para estante de livros
   - AddBookDialog para adicionar novos livros

2. **Gêneros Literários (ReadingTheme)**
   - Ficção Científica
   - Terror & Mistério
   - Romance
   - Suspense/Thriller
   - Policial/Investigação
   - True Crime
   - Fantasia
   - Aventura
   - Guerra/Militar
   - Biografia/Autobiografia
   - Autoajuda
   - Outros

3. **Metas de Leitura**
   - Meta diária de páginas (dailyPagesGoal, padrão: 20)
   - Meta semanal de livros (weeklyBooksGoal, padrão: 1)
   - Tracking de progresso vs metas
   - Visualização de progresso em estatísticas

4. **Sistema de Streak**
   - Streak atual de dias de leitura (currentStreak)
   - Streak mais longo (longestStreakDays)
   - Data da última leitura (lastReadingDate)
   - Período do streak mais longo (longestStreakStart/End)
   - Cálculo automático de streak

5. **Notificações e Lembretes**
   - Notificações habilitadas por padrão (enableNotifications)
   - Horário do lembrete configurável (reminderHour/reminderMinute, padrão: 20:00)
   - Lembrete diário de leitura (enableDailyReminder)
   - Lembrete de streak (enableStreakReminder)
   - Alertas de progresso

6. **Gamificação**
   - Sistema de medalhas e insignias
   - Streak tracking (dias consecutivos lendo)
   - Celebrações ao completar livros
   - Conquistas por metas de leitura
   - Estatísticas detalhadas de progresso
   - Provider local para gamificação (ReadingGamificationNotifier)
   - Sistema plugin independente (sem dependências globais)
   - Sistema de estágios (bronze/prata/ouro/diamante)

7. **Interface**
   - Tela principal (ReadingScreen)
   - Tabs: "Leitura" e "Como funciona"
   - Tela de estante (MyShelfScreen)
   - Tela de configurações (ReadingSettingsScreen)
   - Tela de estatísticas (ReadingStatsScreen)
   - Tela de notificações (ReadingNotificationsScreen)
   - Tela de livros finalizados (FinishedBooksScreen)
   - Widget de progresso (MyProgressReading)
   - Widget de celebração ao completar livros

8. **Persistência**
   - Configurações salvas localmente via ObjectBox
   - Lista de livros da estante
   - Progresso de leitura por livro
   - Dados de streak e metas
   - Sincronização com nuvem (via CloudSyncService)

9. **Sistema Plugin Independente**
   - ReadingGamificationEntity para gamificação local
   - ReadingGamificationRepository para persistência local
   - ReadingGamificationNotifier para estado Riverpod puro
   - Zero dependências de services globais
   - Autenticação integrada (currentUserIdProvider)
   - Persistência de estado de ativação (ReadingConfigEntity)

### Estrutura de Dados:

**ReadingConfigEntity:**
- userId: ID do usuário
- enableNotifications: Habilita notificações (padrão: true)
- reminderHour/reminderMinute: Horário do lembrete (padrão: 20:00)
- enableDailyReminder: Lembrete diário (padrão: true)
- enableStreakReminder: Lembrete de streak (padrão: true)
- isModuleActive: Status de ativação do módulo
- currentStreak: Streak atual
- lastReadingDate: Data da última leitura
- longestStreakStart/End: Período do streak mais longo
- longestStreakDays: Dias do streak mais longo
- dailyPagesGoal: Meta diária de páginas (padrão: 20)
- weeklyBooksGoal: Meta semanal de livros (padrão: 1)
- createdAt/updatedAt: Timestamps

**ReadingBook:**
- id: Identificador único do livro
- title: Título do livro
- author: Autor (opcional)
- totalPages: Total de páginas
- currentPage: Página atual
- theme: Gênero literário (enum ReadingTheme)
- createdAt: Data de adição à estante
- completedAt: Data de conclusão
- logs: Lista de logs de leitura (ReadingLog)
- Getters:
  - isCompleted: Se o livro foi concluído
  - progress: Progresso de 0.0 a 1.0
  - progressPercentage: Percentual formatado (ex: "75%")
  - estimatedCompletionDate: Data estimada de conclusão baseada no ritmo atual

**ReadingLog:**
- timestamp: Momento da sessão de leitura
- pageNumber: Página lida nessa sessão
- notes: Anotações da sessão (opcional)

**ReadingDailyProgressEntity:**
- Data do progresso
- Páginas lidas no dia
- Livros lidos no dia
- Tempo de leitura

**ReadingModuleState:**
- earnedInsignias: Lista de insígnias conquistadas
- earnedMedalhas: Lista de medalhas conquistadas
- consecutiveDays: Dias consecutivos de leitura (streak atual)
- lastReadingDate: Data da última leitura
- startDate: Data de início do módulo
- isModuleActive: Status de ativação do módulo
- currentStageId: Estágio atual de gamificação (bronze/prata/ouro)
- Sistema de serialização JSON para sincronização com nuvem

### Requisitos Técnicos:

- Permissão de notificações para lembretes
- ObjectBox para persistência local
- Riverpod para gerenciamento de estado
- GamificationService para sistema de conquistas
- CloudSyncService para sincronização
- ReadingService para lógica de negócio
- ReadingServiceLocal para monitoramento local
- Sistema plugin independente (ReadingGamificationNotifier)

### Fluxo de Uso:

1. Usuário adiciona livros à estante (com gênero literário)
2. Usuário define metas de leitura
3. Usuário configura horários de lembretes
4. Usuário registra progresso de leitura (página atual)
5. Sistema registra log de leitura com timestamp
6. Sistema tracking páginas lidas
7. Sistema calcula streak de dias
8. Sistema estima data de conclusão baseada no ritmo
9. Gamificação recompensa progresso
10. Notificações lembram de ler
11. Estatísticas mostram progresso detalhado

### Seção "Como Funciona":

InfoCards explicativos:
- "Adicione Livros: construa sua estante"
- "Defina Metas: páginas diárias, livros semanais"
- "Registre Progresso: acompanhe sua leitura"
- "Mantenha Streak: leia todos os dias"
