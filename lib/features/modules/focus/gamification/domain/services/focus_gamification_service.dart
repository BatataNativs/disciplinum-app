import 'package:disciplinum/core/gamification/interfaces/module_gamification_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart' hide FocusInsignia;
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_insignia_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_medalha_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_medalha.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_insignia.dart';

/// Service principal de gamificação do módulo Focus
/// Orquestra todos os serviços de gamificação do módulo
class FocusGamificationService implements ModuleGamificationInterface {
  final FocusGamificationRepository _repository;
  final FocusService _focusService;
  late final FocusInsigniaService _insigniaService;
  late final FocusMedalhaService _medalhaService;
  
  FocusModuleState? _currentState;
  bool _isInitialized = false;

  FocusGamificationService(this._repository, this._focusService) {
    _insigniaService = FocusInsigniaService(_focusService);
    _medalhaService = FocusMedalhaService();
  }

  /// Inicializa o serviço de gamificação
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _repository.initialize();
      await _insigniaService.initialize();
      await _medalhaService.initialize();
      
      _currentState = await _repository.getFocusState();
      
      if (_currentState == null) {
        _currentState = FocusModuleState.initial();
        await _repository.saveFocusState(_currentState!);
      }

      _isInitialized = true;
      LoggerService.instance.gamification('FocusGamificationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar FocusGamificationService', error: e);
      rethrow;
    }
  }

  /// Processa eventos do módulo (períodos respeitados, etc.)
  @override
  Future<void> processModuleEvent(Map<String, dynamic> eventData) async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('FocusGamificationService não inicializado');
      return;
    }

    try {
      final eventType = eventData['type'] as String?;
      
      switch (eventType) {
        case 'focus_period_completed':
          await _processFocusPeriodCompleted(eventData);
          break;
        case 'focus_session_completed':
          await _processFocusSessionCompleted(eventData);
          break;
        case 'streak_update':
          await _processStreakUpdate(eventData);
          break;
        case 'focus_break':
          await _processFocusBreak(eventData);
          break;
        default:
          LoggerService.instance.w('Tipo de evento não reconhecido: $eventType');
      }
      
      await checkForNewAchievements();
    } catch (e) {
      LoggerService.instance.e('Erro ao processar evento do módulo Focus', error: e);
    }
  }

  /// Processa período de foco completado
  Future<void> _processFocusPeriodCompleted(Map<String, dynamic> eventData) async {
    final respectedPeriodsCount = (eventData['respectedPeriods'] ?? 0) as int;
    final sessionDuration = (eventData['sessionDuration'] ?? 0) as int;
    
    final updatedState = _currentState!.copyWith(
      sessionsCompleted: _currentState!.sessionsCompleted + 1,
      totalFocusMinutes: _currentState!.totalFocusMinutes + sessionDuration,
    );
    
    await _updateState(updatedState);
    
    // Verifica novas insignias baseadas em períodos respeitados
    final moduleData = {'respectedPeriods': respectedPeriodsCount, 'sessionDuration': sessionDuration};
    await _insigniaService.checkForNewInsignias(moduleData);
  }

  /// Processa sessão de foco completada
  Future<void> _processFocusSessionCompleted(Map<String, dynamic> eventData) async {
    final sessionDuration = (eventData['sessionDuration'] ?? 0) as int;
    final productivityScore = (eventData['productivityScore'] ?? 0) as int;
    
    LoggerService.instance.gamification('Sessão de foco completada: ${sessionDuration}min, score: $productivityScore');
    
    // Pode adicionar lógica específica para sessões aqui
    await checkForNewAchievements();
  }

  /// Processa atualização de streak
  Future<void> _processStreakUpdate(Map<String, dynamic> eventData) async {
    final respectedPeriodsCount = (eventData['respectedPeriods'] ?? 0) as int;
    final currentStreak = (eventData['currentStreak'] ?? 0) as int;
    
    final updatedState = _currentState!.copyWith(
      currentStreakDays: currentStreak,
    );
    
    await _updateState(updatedState);
    
    final moduleData = {'respectedPeriods': respectedPeriodsCount, 'currentStreak': currentStreak};
    await _insigniaService.checkForNewInsignias(moduleData);
  }

  /// Processa pausa no foco
  Future<void> _processFocusBreak(Map<String, dynamic> eventData) async {
    final breakDuration = (eventData['breakDuration'] ?? 0) as int;
    final wasProductive = (eventData['wasProductive'] ?? false) as bool;
    
    LoggerService.instance.gamification('Pausa de foco: ${breakDuration}min, produtiva: $wasProductive');
  }

  /// Reseta o progresso do módulo
  @override
  Future<void> resetProgress() async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('FocusGamificationService não inicializado');
      return;
    }

    try {
      final resetState = _currentState!.reset();
      
      await _updateState(resetState);
      await _insigniaService.resetInsignias();
      await _medalhaService.resetMedalhas();
      
      LoggerService.instance.gamification('Progresso do Focus resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso Focus', error: e);
    }
  }

  /// Obtém o estado atual
  @override
  Future<Map<String, dynamic>> getCurrentState() async {
    if (!_isInitialized || _currentState == null) {
      return FocusModuleState.initial().toJson();
    }
    return _currentState!.toJson();
  }

  /// Verifica por novas conquistas
  @override
  Future<void> checkForNewAchievements() async {
    if (!_isInitialized || _currentState == null) return;

    try {
      // Verifica medalhas baseadas em períodos respeitados
      final moduleData = {'respectedPeriods': _currentState!.respectedPeriods};
      await _medalhaService.checkForNewMedalhas(moduleData);
      
      // Sincroniza com Supabase
      await _repository.syncWithSupabase(_currentState!);
      
      LoggerService.instance.gamification('Verificação de conquistas concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na verificação de conquistas', error: e);
    }
  }

  /// Envia notificações especiais
  @override
  Future<void> sendSpecialNotifications() async {
    if (!_isInitialized || _currentState == null) return;

    try {
      // Notificações de milestones
      if (_currentState!.respectedPeriodsCount == 1) {
        LoggerService.instance.gamification('🎯 Primeiro período de foco concluído! Continue assim!');
      }
      
      if (_currentState!.respectedPeriodsCount == 7) {
        LoggerService.instance.gamification('🏆 7 períodos de foco! Sua disciplina está incrível!');
      }
      
      if (_currentState!.respectedPeriodsCount == 30) {
        LoggerService.instance.gamification('💪 30 períodos! Você é um mestre do foco!');
      }
      
      if (_currentState!.respectedPeriodsCount == 100) {
        LoggerService.instance.gamification('👑 100 períodos! Lenda do foco e produtividade!');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificações especiais', error: e);
    }
  }

  /// Atualiza o estado
  Future<void> _updateState(FocusModuleState newState) async {
    _currentState = newState;
    await _repository.saveFocusState(newState);
  }

  /// Getters para acesso rápido
  @override
  ModuleInsigniaInterface get insigniaService => _insigniaService;
  
  @override
  ModuleMedalhaInterface get medalhaService => _medalhaService;
  
  @override
  String get moduleId => 'focus';
  
  @override
  String get moduleName => 'Foco e Produtividade';
  
  int get respectedPeriods => _currentState?.respectedPeriodsCount ?? 0;
  int get disciplinumCount => _currentState?.respectedPeriodsCount ?? 0;
  bool get isActive => _currentState?.isActive ?? false;
  bool get isInStreak => (_currentState?.respectedPeriodsCount ?? 0) > 0;

  FocusInsignia? get currentInsignia {
    final nextId = _currentState?.nextInsignia;
    if (nextId == null) return null;
    return FocusInsignia.values.firstWhere(
      (i) => i.name == nextId,
      orElse: () => FocusInsignia.madeira,
    );
  }

  List<FocusInsignia> get earnedInsignias {
    return _currentState?.earnedInsignias.map((id) {
          return FocusInsignia.values.firstWhere(
            (i) => i.name == id,
            orElse: () => FocusInsignia.madeira,
          );
        }).toList() ??
        [];
  }

  FocusMedalha? get currentMedal {
    // Retorna a primeira medalha não conquistada
    for (final medalha in FocusMedalha.values) {
      if (!_currentState!.hasMedalha(medalha.name)) {
        return medalha;
      }
    }
    return null;
  }

  List<FocusMedalha> get earnedMedals {
    return _currentState?.earnedMedalhas.map((id) {
          return FocusMedalha.values.firstWhere(
            (m) => m.name == id,
            orElse: () => FocusMedalha.bronze,
          );
        }).toList() ??
        [];
  }

  Future<void> checkInsigniaProgress() async {
    await checkForNewAchievements();
  }

  Future<void> checkMedalProgress() async {
    await checkForNewAchievements();
  }

  /// Obtém progresso para próxima insignia
  double getProgressToNextInsignia() {
    if (!_isInitialized || _currentState == null) return 0.0;
    
    final earnedInsignias = _currentState!.earnedInsignias;
    
    // Encontrar próxima insignia não conquistada
    for (final insignia in FocusInsignia.values) {
      final insigniaName = insignia.name;
      if (!earnedInsignias.contains(insigniaName)) {
        // Calcular progresso para esta insignia
        return insignia.calculateProgress(_currentState!.respectedPeriodsCount);
      }
    }
    
    // Todas as insignias conquistadas
    return 1.0;
  }

  /// Obtém progresso para próxima medalha
  double getProgressToNextMedalha() {
    if (!_isInitialized || _currentState == null) return 0.0;
    
    final earnedInsigniasCount = _currentState!.earnedInsignias.length;
    final totalInsignias = FocusInsignia.values.length;
    
    // Progresso baseado em quantas insignias foram conquistadas
    // Medalhas são concedidas baseadas em conquistas específicas
    return (earnedInsigniasCount / totalInsignias).clamp(0.0, 1.0);
  }

  /// Métodos de compatibilidade para FocusGamificationController (VERSÃO NOVA)

  Future<List<String>> getEarnedInsignias() async {
    if (!_isInitialized) await initialize();
    return _currentState?.earnedInsignias ?? [];
  }

  Future<List<String>> getEarnedMedalhas() async {
    if (!_isInitialized) await initialize();
    return _currentState?.earnedMedalhas ?? [];
  }

  Future<int> getRespectedPeriods() async {
    if (!_isInitialized) await initialize();
    return _currentState?.respectedPeriodsCount ?? 0;
  }

  Future<void> processRespectedPeriod() async {
    await processModuleEvent({'type': 'focus_period_completed', 'respectedPeriods': (respectedPeriods + 1)});
  }

  /// Obtém progresso percentual geral
  Future<double> getProgressPercentage() async {
    return getProgressToNextInsignia();
  }

  /// Obtém próxima insignia
  Future<String?> getNextInsignia() async {
    final next = _currentState?.nextInsignia;
    return next;
  }

  /// Tenta conceder insignia Disciplinum (compatibilidade com controller)
  Future<bool> tryAwardDisciplinum() async {
    if (!_isInitialized || _currentState == null) return false;
    
    try {
      final moduleData = {'respectedPeriods': _currentState!.respectedPeriods};
      final newInsignias = await _insigniaService.checkForNewInsignias(moduleData);
      
      return newInsignias.contains('disciplinum');
    } catch (e) {
      LoggerService.instance.e('Erro ao tentar conceder Disciplinum', error: e);
      return false;
    }
  }

  /// Verifica se pode conceder novo Disciplinum (compatibilidade com controller)
  bool canAwardNewDisciplinum() {
    if (!_isInitialized || _currentState == null) return false;
    
    // Implementar lógica para verificar se pode conceder novo Disciplinum
    return _currentState!.respectedPeriodsCount >= 30; // Exemplo: 30 períodos para Disciplinum
  }

  /// Obtém estatísticas detalhadas
  Future<Map<String, dynamic>> getStatistics() async {
    if (!_isInitialized || _currentState == null) {
      return {
        'moduleId': moduleId,
        'moduleName': moduleName,
        'respectedPeriods': 0,
        'disciplinumCount': 0,
        'earnedInsignias': <String>[],
        'earnedMedalhas': <String>[],
        'isActive': false,
        'isInStreak': false,
      };
    }

    return {
      'moduleId': moduleId,
      'moduleName': moduleName,
      'respectedPeriods': _currentState!.respectedPeriodsCount,
      'disciplinumCount': disciplinumCount,
      'earnedInsignias': _currentState!.earnedInsignias,
      'earnedMedalhas': _currentState!.earnedMedalhas,
      'isActive': _currentState!.isActive,
      'isInStreak': isInStreak,
      'lastUpdated': _currentState!.lastUpdated.toIso8601String(),
    };
  }
}
