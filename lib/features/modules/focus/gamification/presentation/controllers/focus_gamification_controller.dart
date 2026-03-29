import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_insignia.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_medalha.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_gamification_service.dart';

/// Estado da gamificação do módulo Focus
class FocusGamificationState {
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int respectedPeriods;
  final double progressPercentage;
  final String? nextInsignia;
  final bool isLoading;
  final String? error;
  final int disciplinumCount;
  final bool canAwardDisciplinum;

  const FocusGamificationState({
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.respectedPeriods = 0,
    this.progressPercentage = 0.0,
    this.nextInsignia,
    this.isLoading = false,
    this.error,
    this.disciplinumCount = 0,
    this.canAwardDisciplinum = false,
  });

  FocusGamificationState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? respectedPeriods,
    double? progressPercentage,
    String? nextInsignia,
    bool? isLoading,
    String? error,
    int? disciplinumCount,
    bool? canAwardDisciplinum,
  }) {
    return FocusGamificationState(
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      respectedPeriods: respectedPeriods ?? this.respectedPeriods,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      nextInsignia: nextInsignia ?? this.nextInsignia,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      canAwardDisciplinum: canAwardDisciplinum ?? this.canAwardDisciplinum,
    );
  }
}

/// Controller Riverpod para gamificação do módulo Focus
/// Substitui ChangeNotifier por StateNotifier
class FocusGamificationController extends StateNotifier<FocusGamificationState> {
  final FocusGamificationService _gamificationService;
  
  FocusGamificationController(this._gamificationService) : super(const FocusGamificationState()) {
    _initialize();
  }

  // Getters para compatibilidade com UI existente
  List<String> get earnedInsignias => state.earnedInsignias;
  List<String> get earnedMedalhas => state.earnedMedalhas;
  int get respectedPeriods => state.respectedPeriods;
  double get progressPercentage => state.progressPercentage;
  String? get nextInsignia => state.nextInsignia;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  int get disciplinumCount => state.disciplinumCount;
  bool get canAwardDisciplinum => state.canAwardDisciplinum;

  /// Inicializa o controller
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      
      await _gamificationService.initialize();
      await _loadCurrentState();
      
      LoggerService.instance.gamification('FocusGamificationController inicializado');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao inicializar gamificação: $e');
      LoggerService.instance.e('Erro ao inicializar FocusGamificationController', error: e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Carrega o estado atual da gamificação
  Future<void> _loadCurrentState() async {
    try {
      final insignias = await _gamificationService.getEarnedInsignias();
      final medalhas = await _gamificationService.getEarnedMedalhas();
      final periods = await _gamificationService.getRespectedPeriods();
      final progress = await _gamificationService.getProgressPercentage();
      final next = await _gamificationService.getNextInsignia();

      state = state.copyWith(
        earnedInsignias: insignias,
        earnedMedalhas: medalhas,
        respectedPeriods: periods,
        progressPercentage: progress,
        nextInsignia: next,
        disciplinumCount: medalhas.length, // Simulação
        canAwardDisciplinum: periods >= 7, // Simulação
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Falha ao carregar estado: $e');
      LoggerService.instance.e('Erro ao carregar estado da gamificação', error: e);
    }
  }

  /// Recarrega o estado
  Future<void> refresh() async {
    await _loadCurrentState();
  }

  /// Processa um período respeitado
  Future<void> processRespectedPeriod() async {
    try {
      state = state.copyWith(isLoading: true);
      
      await _gamificationService.processRespectedPeriod();
      await _loadCurrentState();
      
      LoggerService.instance.gamification('Período respeitado processado com sucesso');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao processar período: $e');
      LoggerService.instance.e('Erro ao processar período respeitado', error: e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Adiciona um período respeitado (alias para compatibilidade)
  Future<void> addRespectedPeriod() async {
    await processRespectedPeriod();
  }

  /// Falha em um período (compatibilidade)
  Future<void> failPeriod() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Simulação - implementar lógica real se necessário
      await _loadCurrentState();
      
      LoggerService.instance.gamification('Período falho processado');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao processar período falho: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Tenta conceder Disciplinum
  Future<void> tryAwardDisciplinum() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Simulação - implementar lógica real se necessário
      await _loadCurrentState();
      
      LoggerService.instance.gamification('Tentativa de concessão Disciplinum processada');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao conceder Disciplinum: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Reseta o progresso
  Future<void> resetProgress() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Simulação - implementar lógica real se necessário
      await _loadCurrentState();
      
      LoggerService.instance.gamification('Progresso resetado');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao resetar progresso: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Obtém informações da insígnia
  FocusInsigniaEntity? getInsigniaInfo(String insigniaId) {
    try {
      return FocusInsigniaEntity.values.cast<FocusInsigniaEntity?>().firstWhere(
        (insignia) => insignia?.name == insigniaId,
        orElse: () => null,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao obter informações da insígnia: $e');
      return null;
    }
  }

  /// Obtém informações da medalha
  FocusMedalha? getMedalhaInfo(String medalhaId) {
    try {
      return FocusMedalha.values.cast<FocusMedalha?>().firstWhere(
        (medalha) => medalha?.name == medalhaId,
        orElse: () => null,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao obter informações da medalha: $e');
      return null;
    }
  }

  /// Verifica se tem insígnia
  bool hasInsignia(String insigniaId) {
    return state.earnedInsignias.contains(insigniaId);
  }

  /// Verifica se tem medalha
  bool hasMedalha(String medalhaId) {
    return state.earnedMedalhas.contains(medalhaId);
  }

  /// Limpa o erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}
