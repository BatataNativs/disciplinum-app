/// Contrato para eventos de módulos
///
/// Padroniza como eventos são estruturados e propagados
/// no sistema, permitindo:
/// - Logging consistente
/// - Analytics unificados
/// - Reações cruzadas entre módulos (quando necessário)
/// - Debug e tracing
///
/// Eventos são imutáveis e representam fatos que ocorreram.
abstract class ModuleEventContract {
  /// Tipo do evento (snake_case)
  ///
  /// Exemplos:
  /// - 'session_started'
  /// - 'goal_reached'
  /// - 'streak_broken'
  /// - 'achievement_unlocked'
  String get eventType;

  /// ID do módulo que emitiu o evento
  String get moduleId;

  /// ID do usuário relacionado ao evento
  String get userId;

  /// Timestamp do evento (quando ocorreu)
  DateTime get timestamp;

  /// Payload específico do evento
  ///
  /// Cada tipo de evento define sua própria estrutura.
  /// Exemplo para 'session_completed':
  /// ```json
  /// {
  ///   "duration_minutes": 25,
  ///   "was_successful": true,
  ///   "interruptions": 0
  /// }
  /// ```
  Map<String, dynamic> get payload;

  /// Versão do schema do evento
  ///
  /// Permite evolução do formato de eventos.
  int get eventVersion;

  /// Categoria do evento para agrupamento
  ModuleEventCategory get category;

  /// Converte para JSON para persistência/transmissão
  Map<String, dynamic> toJson();
}

/// Categorias de eventos padronizadas
///
/// Permite filtragem e processamento em lote por tipo.
enum ModuleEventCategory {
  /// Início de sessão/atividade
  sessionStarted,

  /// Conclusão bem-sucedida
  sessionCompleted,

  /// Atualização de métrica de progresso
  progressUpdated,

  /// Alcançou novo nível/estágio
  stageAchieved,

  /// Atualização de streak
  streakUpdated,

  /// Meta atingida
  goalReached,

  /// Recaída/regressão (quando aplicável)
  relapseDetected,

  /// Configuração alterada
  configurationChanged,

  /// Estado do módulo alterado (ativado/desativado)
  moduleStateChanged,

  /// Outros eventos não categorizados
  other,
}

/// Factory base para criar eventos
///
/// Cada módulo pode ter sua própria factory especializada.
abstract class ModuleEventFactory<T extends ModuleEventContract> {
  /// ID do módulo que esta factory cria eventos
  String get moduleId;

  /// Cria evento de início de sessão
  T createSessionStarted({
    required String userId,
    Map<String, dynamic>? payload,
  });

  /// Cria evento de conclusão de sessão
  T createSessionCompleted({
    required String userId,
    required bool wasSuccessful,
    Map<String, dynamic>? payload,
  });

  /// Cria evento de atualização de progresso
  T createProgressUpdated({
    required String userId,
    required String metricName,
    required dynamic newValue,
    Map<String, dynamic>? payload,
  });

  /// Cria evento de meta alcançada
  T createGoalReached({
    required String userId,
    required String goalName,
    Map<String, dynamic>? payload,
  });

  /// Cria evento genérico customizado
  T createCustom({
    required String eventType,
    required String userId,
    required ModuleEventCategory category,
    Map<String, dynamic>? payload,
  });
}

/// Bus de eventos para comunicação entre módulos
///
/// Permite reação a eventos sem acoplamento direto.
/// Implementação pode usar Riverpod, EventBus, ou outro mecanismo.
abstract class ModuleEventBus {
  /// Emite um evento para o sistema
  void emit(ModuleEventContract event);

  /// Stream de todos os eventos
  Stream<ModuleEventContract> get events;

  /// Stream filtrado por módulo
  Stream<ModuleEventContract> eventsForModule(String moduleId);

  /// Stream filtrado por categoria
  Stream<ModuleEventContract> eventsByCategory(ModuleEventCategory category);

  /// Stream filtrado por módulo E categoria
  Stream<ModuleEventContract> eventsForModuleAndCategory(
    String moduleId,
    ModuleEventCategory category,
  );
}

/// Mixin para facilitar emissão de eventos
///
/// Classes que precisam emitir eventos podem usar este mixin
/// para simplificar a implementação.
mixin EventEmitterMixin {
  ModuleEventBus? _eventBus;

  void setEventBus(ModuleEventBus bus) {
    _eventBus = bus;
  }

  void emitEvent(ModuleEventContract event) {
    _eventBus?.emit(event);
  }

  bool get canEmitEvents => _eventBus != null;
}
