# Guia de Implementação de Gamificação

## Visão Geral

O Sistema de Gamificação do Disciplinum é uma arquitetura modular baseada em plugins que rastreia o progresso do usuário, concede conquistas e fornece feedback motivacional em 10 módulos de hábitos independentes. Cada módulo opera como um plugin autossuficiente com sua própria persistência, gerenciamento de estado e lógica de gamificação.

## Filosofia da Arquitetura

### Design Baseado em Plugins

Cada módulo de hábito (Leitura, Economia de Dinheiro, Parar de Fumar, etc.) opera como um plugin independente com seu próprio:
- Entidade de gamificação (ObjectBox @Entity)
- Repository para acesso local de dados
- StateNotifier para gerenciamento de estado (Riverpod)
- Sistema de conquistas (insígnias e medalhas)
- Rastreamento de streaks
- Zero dependências globais

Este design garante:
- **Zero acoplamento** entre módulos
- **Persistência independente** por módulo (ObjectBox)
- **Sincronização na nuvem** via Supabase
- **Ativação/desativação flexível**
- **Adição fácil de novos módulos**

## Componentes Principais

### 1. Entidade de Gamificação do Módulo

Cada módulo tem sua própria entidade de gamificação armazenada no ObjectBox:

#### Exemplo: ReadingGamificationEntity

```dart
@Entity()
class ReadingGamificationEntity {
  @Id()
  int id = 1; // ID fixo para padrão singleton

  @Index()
  String userId;

  // Rastreamento de streaks
  int currentStreak;
  int longestStreakDays;

  // Rastreamento de conquistas (insígnias)
  List<String> unlockedInsignias;

  // Rastreamento de medalhas
  int bronzeMedals;
  int silverMedals;
  int goldMedals;
  int diamondMedals;

  // Estatísticas
  int totalBooksRead;
  int totalPagesRead;
  int totalReadingDays;

  // Timestamps
  DateTime lastActivityDate;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 2. Repository de Gamificação

Cada módulo tem um repository para acesso local de dados com ObjectBox:

```dart
class ReadingGamificationRepository {
  final Box<ReadingGamificationEntity> _box;

  ReadingGamificationRepository(this._box);

  Future<ReadingGamificationEntity?> getGamification(String userId) async {
    return _box.query(ReadingGamificationEntity_.userId.equals(userId))
        .build()
        .findFirst();
  }

  Future<void> saveGamification(ReadingGamificationEntity entity) async {
    _box.put(entity);
  }

  Future<void> incrementStreak(String userId) async {
    final entity = await getGamification(userId);
    if (entity != null) {
      entity.currentStreak++;
      entity.lastActivityDate = DateTime.now();
      await saveGamification(entity);
    }
  }

  Future<void> unlockInsignia(String userId, String insigniaId) async {
    final entity = await getGamification(userId);
    if (entity != null && !entity.unlockedInsignias.contains(insigniaId)) {
      entity.unlockedInsignias.add(insigniaId);
      await saveGamification(entity);
    }
  }
}
```

### 3. Notificador de Gamificação (StateNotifier)

Cada módulo usa Riverpod StateNotifier para gerenciamento de estado com zero dependências globais:

```dart
class ReadingGamificationNotifier extends StateNotifier<ReadingGamificationState> {
  final ReadingGamificationRepository _repository;

  ReadingGamificationNotifier(this._repository)
      : super(ReadingGamificationState.initial());

  Future<void> loadGamification(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final entity = await _repository.getGamification(userId);
      if (entity != null) {
        state = state.fromEntity(entity);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> recordActivity(String userId) async {
    await _repository.incrementStreak(userId);
    await _checkInsignias(userId);
  }

  Future<void> resetProgress(String userId) async {
    // Reseta gamificação preservando insígnia Madeira
    final entity = await _repository.getGamification(userId);
    if (entity != null) {
      entity.currentStreak = 0;
      entity.unlockedInsignias = 
          entity.unlockedInsignias.where((i) => i == 'madeira').toList();
      entity.bronzeMedals = 0;
      entity.silverMedals = 0;
      entity.goldMedals = 0;
      entity.diamondMedals = 0;
      await _repository.saveGamification(entity);
    }
  }

  Future<void> _checkInsignias(String userId) async {
    final entity = await _repository.getGamification(userId);
    if (entity == null) return;

    final streak = entity.currentStreak;
    
    // Verifica e desbloqueia insígnias baseado no streak
    if (streak >= 1 && !entity.unlockedInsignias.contains('ferro')) {
      await _repository.unlockInsignia(userId, 'ferro');
    }
    if (streak >= 3 && !entity.unlockedInsignias.contains('latao')) {
      await _repository.unlockInsignia(userId, 'latao');
    }
    if (streak >= 30 && !entity.unlockedInsignias.contains('disciplinum')) {
      await _repository.unlockInsignia(userId, 'disciplinum');
      await _awardMedal(userId, 'bronze');
    }
  }

  Future<void> _awardMedal(String userId, String medalType) async {
    final entity = await _repository.getGamification(userId);
    if (entity == null) return;

    switch (medalType) {
      case 'bronze':
        entity.bronzeMedals++;
        break;
      case 'silver':
        entity.silverMedals++;
        break;
      case 'gold':
        entity.goldMedals++;
        break;
      case 'diamond':
        entity.diamondMedals++;
        break;
    }
    await _repository.saveGamification(entity);
  }
}
```

### 4. Gerenciamento de Estado

Cada módulo tem sua própria classe de estado com insígnias e medalhas:

```dart
class ReadingGamificationState {
  final bool isLoading;
  final String? error;
  final int currentStreak;
  final int longestStreakDays;
  final List<String> unlockedInsignias;
  final int bronzeMedals;
  final int silverMedals;
  final int goldMedals;
  final int diamondMedals;
  final int totalBooksRead;
  final int totalPagesRead;
  final int totalReadingDays;

  ReadingGamificationState({
    this.isLoading = false,
    this.error,
    this.currentStreak = 0,
    this.longestStreakDays = 0,
    this.unlockedInsignias = const [],
    this.bronzeMedals = 0,
    this.silverMedals = 0,
    this.goldMedals = 0,
    this.diamondMedals = 0,
    this.totalBooksRead = 0,
    this.totalPagesRead = 0,
    this.totalReadingDays = 0,
  });

  ReadingGamificationState copyWith({
    bool? isLoading,
    String? error,
    int? currentStreak,
    int? longestStreakDays,
    List<String>? unlockedInsignias,
    int? bronzeMedals,
    int? silverMedals,
    int? goldMedals,
    int? diamondMedals,
    int? totalBooksRead,
    int? totalPagesRead,
    int? totalReadingDays,
  }) {
    return ReadingGamificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      unlockedInsignias: unlockedInsignias ?? this.unlockedInsignias,
      bronzeMedals: bronzeMedals ?? this.bronzeMedals,
      silverMedals: silverMedals ?? this.silverMedals,
      goldMedals: goldMedals ?? this.goldMedals,
      diamondMedals: diamondMedals ?? this.diamondMedals,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
      totalPagesRead: totalPagesRead ?? this.totalPagesRead,
      totalReadingDays: totalReadingDays ?? this.totalReadingDays,
    );
  }

  static ReadingGamificationState initial() => ReadingGamificationState();
}
```

## Sistema de Insígnias e Medalhas

### Tipos de Insígnias

#### 1. Insígnias de Streak
Concedidas por dias consecutivos de atividade:
- **🪵 Madeira**: Configurar e ativar o módulo (preservada no reset)
- **🥈 Ferro**: 1-2 dias de streak (varia por módulo)
- **🥈 Alumínio**: 2-3 dias de streak (varia por módulo)
- **🥇 Latão**: 3-5 dias de streak (varia por módulo)
- **🥉 Bronze**: 5-8 dias de streak (varia por módulo)
- **🥈 Prata**: 10-15 dias de streak (varia por módulo)
- **🥇 Ouro**: 15-30 dias de streak (varia por módulo)
- **💎 Diamante**: 20-90 dias de streak (varia por módulo)
- **🎱 Disciplinum**: 30+ dias de streak (específico do módulo)

#### 2. Medalhas
Concedidas por acumular insígnias Disciplinum:
- **Bronze**: 1 insígnia Disciplinum
- **Prata**: 2 insígnias Disciplinum
- **Ouro**: 3 insígnias Disciplinum
- **Diamante**: 4 insígnias Disciplinum

### Lógica de Desbloqueio de Insígnias

```dart
void _checkInsignias(String userId) {
  final currentStreak = state.currentStreak;
  final insignias = List<String>.from(state.unlockedInsignias);

  // Verifica insígnias de streak (limites específicos do módulo)
  if (currentStreak >= 1 && !insignias.contains('ferro')) {
    _unlockInsignia(userId, 'ferro');
  }
  if (currentStreak >= 3 && !insignias.contains('latao')) {
    _unlockInsignia(userId, 'latao');
  }
  if (currentStreak >= 5 && !insignias.contains('bronze')) {
    _unlockInsignia(userId, 'bronze');
  }
  if (currentStreak >= 30 && !insignias.contains('disciplinum')) {
    _unlockInsignia(userId, 'disciplinum');
    _awardMedal(userId, 'bronze');
  }
}

Future<void> _unlockInsignia(String userId, String insigniaId) async {
  final updatedInsignias = [...state.unlockedInsignias, insigniaId];
  state = state.copyWith(unlockedInsignias: updatedInsignias);
  
  await _repository.unlockInsignia(userId, insigniaId);
  
  // Mostra notificação
  _showInsigniaNotification(insigniaId);
}
```

## Rastreamento de Streaks

### Cálculo de Streak

```dart
int calculateStreak(DateTime lastActivity, DateTime today) {
  if (lastActivity == null) return 0;
  
  final difference = today.difference(lastActivity).inDays;
  
  if (difference == 0) {
    // Atividade hoje, streak continua
    return currentStreak;
  } else if (difference == 1) {
    // Atividade ontem, incrementa streak
    return currentStreak + 1;
  } else {
    // Gap de 2+ dias, streak reseta
    return 0;
  }
}
```

### Preservação de Streak

Ao resetar o progresso, certas insígnias (como "Madeira") são preservadas para encorajar os usuários a tentar novamente:

```dart
Future<void> resetProgress(String userId) async {
  final preservedInsignias = state.unlockedInsignias
      .where((i) => i == 'madeira')
      .toList();
  
  state = ReadingGamificationState.initial()
      .copyWith(unlockedInsignias: preservedInsignias);
  
  await _repository.saveGamification(state.toEntity(userId));
}
```

### Lógica Especial de Streak do Digital Detox

O módulo Digital Detox possui um ciclo adicional de 7 dias para "Quebras de Jejum":

```dart
// Dois contadores independentes:
// 1. Streak principal (para insígnias e medalhas)
// 2. Ciclo de 7 dias (para Quebras de Jejum)

// Tipos de dia:
// - Dia válido: +1 para ambos os contadores
// - Dia de Quebra de Jejum: neutro (sem mudança em nenhum contador)
// - Dia de falha: ambos os contadores resetam para 0

// Aquisição de Quebra de Jejum:
// A cada 7 dias válidos consecutivos → ganha 1 Quebra de Jejum
// Armazenamento máximo: 1 Quebra de Jejum
```

## Gamificação Específica por Módulo

### Módulo Leitura

**Entidade**: `ReadingGamificationEntity`
**Métricas**:
- Livros lidos
- Páginas lidas
- Dias de leitura
- Streak atual
- Maior streak

**Insígnias**:
- Madeira (configurar módulo)
- Ferro (2% do livro)
- Alumínio (5% do livro)
- Latão (10% do livro)
- Bronze (50% do livro)
- Prata (80% do livro)
- Ouro (1 livro completo)
- Diamante (2 livros)
- Disciplinum (3 livros)

### Módulo Economia de Dinheiro

**Entidade**: `MoneySavingModuleState`
**Métricas**:
- Total economizado
- Desafios completados
- Streak atual
- Maior streak

**Insígnias**:
- Madeira (configurar módulo)
- Ferro (5% do desafio)
- Alumínio (10% do desafio)
- Latão (15% do desafio)
- Bronze (20% do desafio)
- Prata (40% do desafio)
- Ouro (60% do desafio)
- Diamante (80% do desafio)
- Disciplinum (100% do desafio)

**Especial**: Cada desafio completo concede uma insígnia Disciplinum

### Módulo Parar de Fumar

**Entidade**: `SmokingGamificationEntity`
**Métricas**:
- Dias sem fumar
- Cigarros evitados
- Dinheiro economizado
- Streak atual

**Insígnias**:
- Madeira (configurar módulo)
- Ferro (1 dia)
- Alumínio (2 dias)
- Latão (3 dias)
- Bronze (5 dias)
- Prata (10 dias)
- Ouro (15 dias)
- Diamante (20 dias)
- Disciplinum (30 dias)

**Especial**: Marcos de saúde (20 min, 1 dia, 2 dias, 3 dias, 14 dias, 90 dias)

### Módulo Digital Detox

**Entidade**: `DigitalDetoxGamificationEntity`
**Métricas**:
- Apps bloqueados
- Tempo economizado
- Streak atual
- Maior streak
- Quebras de Jejum (ciclo de 7 dias)

**Insígnias**:
- Madeira (configurar módulo)
- Ferro (1 dia)
- Alumínio (2 dias)
- Latão (3 dias)
- Bronze (5 dias)
- Prata (10 dias)
- Ouro (15 dias)
- Diamante (20 dias)
- Disciplinum (30 dias)

**Especial**: Sistema de Quebras de Jejum (1 dia livre a cada 7 dias válidos consecutivos)

### Módulo Compulsão Alimentar

**Entidade**: `BingeEatingGamificationEntity`
**Métricas**:
- Dias sem abrir apps bloqueados
- Streak atual
- Maior streak

**Insígnias**: Mesmo padrão do Digital Detox (1-30 dias)

### Módulo Conteúdo Adulto

**Entidade**: `AdultContentGamificationEntity`
**Métricas**:
- Dias sem abrir apps bloqueados
- Streak atual
- Maior streak

**Insígnias**: Mesmo padrão do Digital Detox (1-30 dias)

### Módulo Dieta

**Entidade**: `DietGamificationEntity`
**Métricas**:
- Dias seguindo horário das refeições
- Streak atual
- Maior streak

**Insígnias**: Madeira, Ferro (1 dia), Alumínio (2 dias), Latão (4 dias), Bronze (8 dias), Prata (12 dias), Ouro (18 dias), Diamante (26 dias), Disciplinum (30 dias)

### Módulo Foco

**Entidade**: `FocusGamificationEntity`
**Métricas**:
- Períodos de foco completados
- Streak atual
- Maior streak

**Insígnias**: Madeira, Ferro (1 período), Alumínio (2 períodos), Latão (3 períodos), Bronze (4 períodos), Prata (5 períodos), Ouro (6 períodos), Diamante (9 períodos), Disciplinum (10 períodos)

### Módulo Procrastinação

**Entidade**: `ProcrastinationGamificationEntity`
**Métricas**:
- Dias com todas as tarefas completadas
- Streak atual
- Maior streak

**Insígnias**: Madeira, Ferro (1 dia), Alumínio (2 dias), Latão (3 dias), Bronze (5 dias), Prata (12 dias), Ouro (18 dias), Diamante (25 dias), Disciplinum (30 dias)

**Especial**: Sem gamificação se nenhuma tarefa configurada para o dia

### Módulo Controle de Gastos

**Entidade**: `SpendingGamificationEntity`
**Métricas**:
- Meses com todas as contas pagas
- Streak atual
- Maior streak

**Insígnias**: Madeira, Ferro (1 mês), Alumínio (2 meses), Latão (3 meses), Bronze (4 meses), Prata (6 meses), Ouro (8 meses), Diamante (10 meses), Disciplinum (12 meses)

## Persistência de Dados

### Banco de Dados ObjectBox

Os dados de gamificação de cada módulo são armazenados em sua própria entidade ObjectBox:

```dart
// Leitura
@Entity()
class ReadingGamificationEntity { ... }

// Economia de Dinheiro
@Entity()
class MoneySavingModuleState { ... }

// Parar de Fumar
@Entity()
class SmokingGamificationEntity { ... }

// Digital Detox
@Entity()
class DigitalDetoxGamificationEntity { ... }

// ... (todos os 10 módulos)
```

### Sincronização na Nuvem (Supabase)

Os dados de gamificação são sincronizados com Supabase para backup e sincronização entre dispositivos:

```dart
class GamificationSyncService {
  Future<void> syncToCloud(String userId, String moduleId) async {
    final localData = await _repository.getGamification(userId);
    if (localData == null) return;

    await supabase.from('${moduleId}_gamification_states').upsert({
      'user_id': userId,
      'state_data': localData.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> syncFromCloud(String userId, String moduleId) async {
    final response = await supabase
        .from('${moduleId}_gamification_states')
        .select('state_data')
        .eq('user_id', userId)
        .maybeSingle();
    
    if (response != null) {
      final entity = _entityFromJson(response['state_data']);
      await _repository.saveGamification(entity);
    }
  }
}
```

## Integração com Monitoramento de Apps

Quando um app é bloqueado pelo sistema nativo de Monitoramento de Apps (via Accessibility Service ou UsageStats), ele dispara atualizações de gamificação:

```dart
// AppMonitoringService escuta eventos de acessibilidade/uso
void _handleAppEvent(Map event) {
  if (event['type'] == 'app_blocked') {
    final moduleId = event['moduleId'];
    _handleAppBlockedForGamification(moduleId);
  }
}

Future<void> _handleAppBlockedForGamification(String moduleId) async {
  switch (moduleId) {
    case 'digital_detox':
      await _updateDigitalDetoxGamification();
      break;
    case 'adult_content':
      await _updateAdultContentGamification();
      break;
    case 'binge_eating':
      await _updateBingeEatingGamification();
      break;
    case 'spending':
      await _updateSpendingGamification();
      break;
  }
}
```

## Otimização de Performance

### 1. Lazy Loading

Os dados de gamificação são carregados sob demanda quando um módulo é ativado:

```dart
Future<void> activateModule(String userId) async {
  await loadGamification(userId);
  state = state.copyWith(isActive: true);
}
```

### 2. Atualizações Seletivas

Apenas o estado relevante é atualizado para minimizar rebuilds:

```dart
// Ruim - atualiza o estado inteiro
state = state.copyWith(currentStreak: newStreak);

// Bom - usa select do Riverpod
final streak = ref.watch(
  readingGamificationStateProvider.select((s) => s.currentStreak)
);
```

### 3. Escritas Debounced

As atualizações de gamificação são debounced para reduzir escritas no banco de dados:

```dart
Timer? _debounceTimer;

void _scheduleSave() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(seconds: 2), () {
    _repository.saveGamification(state.toEntity(userId));
  });
}
```

### 4. Otimização de Queries ObjectBox

Use campos indexados para dados frequentemente consultados:

```dart
@Entity()
class ReadingGamificationEntity {
  @Id()
  int id = 1;

  @Index() // Índice para buscas rápidas de userId
  String userId;
  
  // ... outros campos
}
```

## Estratégia de Testes

### Testes Unitários

Teste componentes individuais em isolamento:

```dart
test('calculateStreak incrementa para dias consecutivos', () {
  final streak = calculateStreak(
    DateTime.now().subtract(Duration(days: 1)),
    DateTime.now(),
  );
  expect(streak, 1);
});

test('calculateStreak reseta para gap > 1 dia', () {
  final streak = calculateStreak(
    DateTime.now().subtract(Duration(days: 2)),
    DateTime.now(),
  );
  expect(streak, 0);
});

test('desbloqueio de insígnia preserva Madeira no reset', () {
  final state = ReadingGamificationState(
    unlockedInsignias: ['madeira', 'ferro', 'disciplinum'],
  );
  
  final resetState = state.copyWith(
    unlockedInsignias: state.unlockedInsignias.where((i) => i == 'madeira').toList(),
  );
  
  expect(resetState.unlockedInsignias, ['madeira']);
});
```

### Testes de Integração

Teste o fluxo completo de gamificação:

```dart
test('fluxo completo de gamificação', () async {
  await notifier.recordActivity(userId);
  expect(state.currentStreak, 1);
  expect(state.unlockedInsignias, contains('ferro'));
  
  await notifier.recordActivity(userId);
  expect(state.currentStreak, 2);
  
  // Testa reset preserva Madeira
  await notifier.resetProgress(userId);
  expect(state.currentStreak, 0);
  expect(state.unlockedInsignias, contains('madeira'));
});
```

## Estrutura de Plugin

### Layout de Diretórios

Cada módulo segue a estrutura de plugin:

```
lib/features/modules/{module_name}/
├── gamification/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── {module}_gamification_entity.dart      # ObjectBox @Entity
│   │   │   ├── {module}_module_state.dart              # Classe de estado
│   │   │   └── {module}_config.dart                    # Configurações
│   │   ├── repositories/
│   │   │   └── {module}_gamification_repository.dart   # Repository local
│   │   └── services/
│   │       └── {module}_gamification_notifier.dart     # StateNotifier
│   └── presentation/
│       ├── screens/
│       │   └── {module}_screen.dart
│       └── widgets/
│           └── ...
```

### Configuração de Providers

Cada módulo tem seus próprios providers:

```dart
// Provider de autenticação (local)
final readingCurrentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user?.id ?? 'guest_user';
});

// Provider de notificador
final readingGamificationNotifierProvider = StateNotifierProvider.family<
  ReadingGamificationNotifier,
  ReadingGamificationState,
  String
>((ref, userId) {
  final repository = ReadingGamificationRepository();
  return ReadingGamificationNotifier(repository)..loadGamification(userId);
});

// Provider de estado (conveniência)
final readingGamificationStateProvider = Provider<
  ReadingGamificationState
>((ref) {
  final userId = ref.watch(readingCurrentUserIdProvider);
  return ref.watch(readingGamificationNotifierProvider(userId));
});
```

## Melhorias Futuras

### Funcionalidades Planejadas

1. **Conquistas Inter-Módulos**: Conquistas que requerem progresso em múltiplos módulos
2. **Rankings**: Comparar progresso com outros usuários (opcional, focado em privacidade)
3. **Compartilhamento de Conquistas**: Compartilhar conquistas em redes sociais
4. **Dificuldade Dinâmica**: Ajustar requisitos de conquistas baseado no comportamento do usuário
5. **Categorias de Conquistas**: Agrupar conquistas por tipo (streaks, marcos, especiais)

### Dívida Técnica

1. **Cobertura de Testes**: Aumentar para 80%+
2. **Localização de Conquistas**: Suporte a múltiplos idiomas
3. **Animações de Conquistas**: Adicionar efeitos visuais para desbloqueio
4. **Histórico de Conquistas**: Rastrear quando as conquistas foram desbloqueadas

## Conclusão

O Sistema de Gamificação do Disciplinum usa uma arquitetura modular baseada em plugins que permite que cada módulo de hábito tenha seu próprio sistema de gamificação independente enquanto mantém consistência em toda a aplicação. O uso de ObjectBox para persistência local, Riverpod para gerenciamento de estado e Supabase para sincronização na nuvem fornece um sistema flexível e escalável que pode ser estendido com novos módulos e conquistas.

**Benefícios Principais:**
- **Zero acoplamento** entre módulos
- **Persistência independente** por módulo
- **Sincronização na nuvem** para backup e suporte multi-dispositivo
- **Fácil adição** de novos módulos
- **Production-ready** com padrões comprovados

---

**Versão do Documento**: 2.0  
**Última Atualização**: Junho de 2026  
**Status**: ✅ Atualizado para Arquitetura Plugin, ObjectBox e 10 Módulos  
**Mantido Por**: Equipe de Desenvolvimento Disciplinum
