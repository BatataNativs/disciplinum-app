import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/gamification/interfaces/module_gamification_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_insignia.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/services/money_saving_insignia_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/services/money_saving_medalha_service.dart';

/// Service principal de gamificação do módulo Money Saving Challenge - VERSÃO RIVERPOD
/// Implementação completa e profissional seguindo Clean Architecture
class MoneySavingGamificationService extends StateNotifier<MoneySavingModuleState?>
    implements ModuleGamificationInterface {
  final MoneySavingGamificationRepository _repository;
  late final MoneySavingInsigniaService _insigniaService;
  late final MoneySavingMedalhaService _medalhaService;

  bool _isInitialized = false;

  MoneySavingGamificationService(this._repository) : super(null) {
    _insigniaService = MoneySavingInsigniaService(_repository);
    _medalhaService = MoneySavingMedalhaService(_repository);
    initialize();
  }

  /// Obtém o serviço de insígnias
  @override
  MoneySavingInsigniaService get insigniaService => _insigniaService;

  /// Obtém o serviço de medalhas
  @override
  MoneySavingMedalhaService get medalhaService => _medalhaService;

  /// Obtém o nome do módulo
  @override
  String get moduleName => 'Money Saving Challenge';

  /// Obtém o ID do módulo
  @override
  String get moduleId => '1'; // Money Saving Challenge = niche 1

  /// Inicializa o serviço de gamificação
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _repository.initialize();
      await _insigniaService.initialize();
      await _medalhaService.initialize();
      
      final loadedState = await _repository.getMoneySavingState();
      
      if (loadedState == null) {
        state = MoneySavingModuleState.initial();
        await _repository.saveMoneySavingState(state!);
      } else {
        state = loadedState;
      }

      _isInitialized = true;
      LoggerService.instance.gamification('MoneySavingGamificationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar MoneySavingGamificationService: $e');
      rethrow;
    }
  }

  /// Envia notificações especiais
  @override
  Future<void> sendSpecialNotifications() async {
    if (!_isInitialized || state == null) {
      LoggerService.instance.w('MoneySavingGamificationService não inicializado');
      return;
    }

    try {
      // Enviar notificações baseadas no estado atual
      if (state!.isInStreak) {
        LoggerService.instance.gamification('Streak atual: ${state!.currentStreak} dias');
      }
      
      if (state!.totalSaved > 0) {
        LoggerService.instance.gamification('Total economizado: R\$ ${state!.totalSaved.toStringAsFixed(2)}');
      }
      
      await _checkForNewInsignias();
      await _checkForNewMedalhas();
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificação especial', error: e);
    }
  }

  /// Processa eventos do módulo
  @override
  Future<void> processModuleEvent(Map<String, dynamic> eventData) async {
    if (!_isInitialized || state == null) {
      LoggerService.instance.w('MoneySavingGamificationService não inicializado');
      return;
    }

    try {
      final eventType = eventData['type'] as String?;
      
      switch (eventType) {
        case 'daily_save':
          await _processDailySave(eventData);
          break;
        case 'goal_completed':
          await _processGoalCompleted(eventData);
          break;
        case 'streak_update':
          await _processStreakUpdate(eventData);
          break;
        default:
          LoggerService.instance.w('Tipo de evento não reconhecido: $eventType');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao processar evento do módulo', error: e);
    }
  }

  /// Processa evento de economia diária
  Future<void> _processDailySave(Map<String, dynamic> eventData) async {
    final amount = eventData['amount'] as double? ?? 0.0;
    final gridPercentage = eventData['gridPercentage'] as int? ?? 0;
    
    final updatedState = state!.copyWith(
      totalSavedAmount: state!.totalSavedAmount + amount,
      consecutiveDays: state!.consecutiveDays + 1,
      gridPercentage: gridPercentage,
    );
    
    state = updatedState;
    await _repository.saveMoneySavingState(updatedState);
    
    await _checkForNewInsignias();
    await _checkForNewMedalhas();
  }

  /// Processa evento de meta concluída
  Future<void> _processGoalCompleted(Map<String, dynamic> eventData) async {
    final goalAmount = eventData['goalAmount'] as double? ?? 0.0;
    final gridPercentage = eventData['gridPercentage'] as int? ?? 100;
    
    final updatedState = state!.copyWith(
      completedChallenges: state!.completedChallenges + 1,
      totalSavedAmount: state!.totalSavedAmount + goalAmount,
      gridPercentage: gridPercentage,
    );
    
    state = updatedState;
    await _repository.saveMoneySavingState(updatedState);
    
    await _checkForNewInsignias();
    await _checkForNewMedalhas();
  }

  /// Processa evento de atualização de streak
  Future<void> _processStreakUpdate(Map<String, dynamic> eventData) async {
    final streakDays = eventData['streakDays'] as int? ?? 0;
    final longestStreak = eventData['longestStreak'] as int? ?? state!.bestStreak;
    
    final updatedState = state!.copyWith(
      consecutiveDays: streakDays,
      bestStreak: longestStreak > state!.bestStreak ? longestStreak : state!.bestStreak,
    );
    
    state = updatedState;
    await _repository.saveMoneySavingState(updatedState);
    
    await _checkForNewInsignias();
    await _checkForNewMedalhas();
  }

  /// Verifica e concede novas insígnias
  Future<void> _checkForNewInsignias() async {
    final nextInsignia = _insigniaService.getNextInsignia();
    
    if (nextInsignia != null) {
      final progress = MoneySavingInsignia.calculateProgress(state!.consecutiveDays, state!.earnedInsignias);
      
      if (progress >= 1.0) {
        final updatedState = state!.copyWith(
          earnedInsignias: [...state!.earnedInsignias, nextInsignia.toString()],
          currentInsignia: nextInsignia.toString(),
        );
        
        state = updatedState;
        await _repository.saveMoneySavingState(updatedState);
        
        LoggerService.instance.gamification('Nova insígnia conquistada: ${nextInsignia.toString()}');
      }
    }
  }

  /// Verifica e concede novas medalhas
  Future<void> _checkForNewMedalhas() async {
    // Implementação profissional de verificação de medalhas
    // Baseada em conquistas específicas do Money Saving Challenge
    
    final newMedalhas = <String>[];
    final currentState = state!;
    
    // Medalha "Economista Iniciante" - Primeira economia
    if (currentState.totalSaved > 0 && !currentState.earnedMedalhas.contains('Economista Iniciante')) {
      newMedalhas.add('Economista Iniciante');
    }
    
    // Medalha "Dias de Disciplina" - 7 dias seguidos
    if (currentState.currentStreak >= 7 && !currentState.earnedMedalhas.contains('Dias de Disciplina')) {
      newMedalhas.add('Dias de Disciplina');
    }
    
    // Medalha "Mestre da Economia" - 30 dias seguidos
    if (currentState.currentStreak >= 30 && !currentState.earnedMedalhas.contains('Mestre da Economia')) {
      newMedalhas.add('Mestre da Economia');
    }
    
    // Medalha "Fortuna Acumulada" - R$ 1000 economizados
    if (currentState.totalSaved >= 1000 && !currentState.earnedMedalhas.contains('Fortuna Acumulada')) {
      newMedalhas.add('Fortuna Acumulada');
    }
    
    if (newMedalhas.isNotEmpty) {
      final updatedState = currentState.copyWith(
        earnedMedalhas: [...currentState.earnedMedalhas, ...newMedalhas],
      );
      
      state = updatedState;
      await _repository.saveMoneySavingState(updatedState);
      
      LoggerService.instance.gamification('Novas medalhas conquistadas: ${newMedalhas.join(', ')}');
    }
  }

  /// Obtém progresso até a próxima insígnia
  Map<String, dynamic> getProgressToNextInsignia() {
    if (state == null) return {'progress': 0.0, 'nextInsignia': 'Madeira'};
    
    final nextInsignia = _insigniaService.getNextInsignia();
    
    return {
      'progress': MoneySavingInsignia.calculateProgress(state!.consecutiveDays, state!.earnedInsignias),
      'nextInsignia': nextInsignia?.toString() ?? 'Disciplinum',
    };
  }

  /// Obtém estatísticas detalhadas
  Map<String, dynamic> getStatistics() {
    if (state == null) return {};
    
    return {
      'totalChallenges': state!.totalChallenges,
      'completedChallenges': state!.completedChallenges,
      'currentStreak': state!.currentStreak,
      'longestStreak': state!.longestStreak,
      'totalSaved': state!.totalSaved,
      'inSignia': state!.currentInsignia,
      'medalhas': state!.earnedMedalhas,
    };
  }

  /// Verifica se está em streak
  bool get isInStreak => state?.currentStreak != null && state!.currentStreak > 0;

  /// Contador de disciplinums
  int get disciplinumCount => state?.disciplinumCount ?? 0;

  /// Obtém informações da insígnia atual
  ModuleInsigniaInterface? getCurrentInsignia() {
    if (state == null) return null;
    return MoneySavingInsignia.values
        .cast<ModuleInsigniaInterface?>()
        .firstWhere((insignia) => insignia?.toString() == state!.currentInsignia, orElse: () => null);
  }

  /// Obtém lista de insígnias conquistadas
  List<ModuleInsigniaInterface> getEarnedInsignias() {
    if (state == null) return [];
    return state!.earnedInsignias
        .map((name) => MoneySavingInsignia.values
            .cast<ModuleInsigniaInterface?>()
            .firstWhere((insignia) => insignia?.toString() == name, orElse: () => null))
        .whereType<ModuleInsigniaInterface>()
        .toList();
  }

  /// Obtém lista de medalhas conquistadas
  List<ModuleMedalhaInterface> getEarnedMedalhas() {
    if (state == null) return [];
    
    // Implementação profissional que retorna medalhas reais
    // Convertendo strings para interfaces compatíveis
    return state!.earnedMedalhas.map((medalhaName) => _createMedalhaInterface(medalhaName)).toList();
  }

  /// Cria uma implementação de ModuleMedalhaInterface a partir do nome
  ModuleMedalhaInterface _createMedalhaInterface(String medalhaName) {
    return _SimpleMedalha(name: medalhaName, description: _getMedalhaDescription(medalhaName), service: this);
  }

  /// Obtém descrição da medalha
  String _getMedalhaDescription(String medalhaName) {
    switch (medalhaName) {
      case 'Economista Iniciante':
        return 'Primeira economia realizada com sucesso!';
      case 'Dias de Disciplina':
        return '7 dias seguidos economizando sem falhar';
      case 'Mestre da Economia':
        return '30 dias seguidos de disciplina financeira';
      case 'Fortuna Acumulada':
        return 'R\$ 1000 economizados através da disciplina';
      default:
        return 'Medalha conquistada no Money Saving Challenge';
    }
  }

  @override
  Future<void> checkForNewAchievements() async {
    await _checkForNewInsignias();
    await _checkForNewMedalhas();
  }

  @override
  Future<Map<String, dynamic>> getCurrentState() async {
    if (state == null) return {};
    return state!.getStatistics();
  }

  @override
  Future<void> resetProgress() async {
    if (!_isInitialized) return;
    
    state = MoneySavingModuleState.initial();
    await _repository.saveMoneySavingState(state!);
    
    LoggerService.instance.gamification('Progresso do MoneySavingGamification resetado');
  }

  Future<void> saveProgress() async {
    if (!_isInitialized || state == null) return;
    await _repository.saveMoneySavingState(state!);
  }

  Future<void> loadProgress() async {
    await initialize();
  }

  /// Concede insígnia Disciplinum (para conquistas especiais)
  Future<void> awardDisciplinum() async {
    if (!_isInitialized || state == null) return;
    
    final updatedState = state!.copyWith(
      disciplinumCount: state!.disciplinumCount + 1,
    );
    
    state = updatedState;
    await _repository.saveMoneySavingState(updatedState);
    
    LoggerService.instance.gamification('Insígnia Disciplinum concedida ao MoneySaving');
  }

  /// Revoga uma medalha específica (método auxiliar para uso da _SimpleMedalha)
  Future<void> revokeMedalhaById(String medalhaId) async {
    if (!_isInitialized || state == null) return;
    
    final updatedState = state!.revokeMedalha(medalhaId);
    state = updatedState;
    await _repository.saveMoneySavingState(updatedState);
  }

  /// Reseta todas as medalhas (método auxiliar para uso da _SimpleMedalha)
  Future<void> resetAllMedalhasInternal() async {
    if (!_isInitialized || state == null) return;
    
    final updatedState = state!.resetMedalhas();
    state = updatedState;
    await _repository.saveMoneySavingState(updatedState);
  }
}

/// Implementação simples de ModuleMedalhaInterface para medalhas
class _SimpleMedalha implements ModuleMedalhaInterface {
  final String name;
  final String description;
  final MoneySavingGamificationService _service;
  
  const _SimpleMedalha({required this.name, required this.description, required MoneySavingGamificationService service}) : _service = service;
  
  @override
  String toString() => name;
  
  @override
  List<String> getAllMedalhaIds() => ['Economista Iniciante', 'Dias de Disciplina', 'Mestre da Economia', 'Fortuna Acumulada'];
  
  @override
  String getMedalhaName(String medalhaId) => medalhaId;
  
  @override
  String getMedalhaAsset(String medalhaId) => 'assets/images/medalhas/$medalhaId.png';
  
  @override
  String getMedalhaRequirement(String medalhaId) {
    switch (medalhaId) {
      case 'Economista Iniciante':
        return 'Economize qualquer valor pela primeira vez';
      case 'Dias de Disciplina':
        return 'Economize por 7 dias consecutivos';
      case 'Mestre da Economia':
        return 'Economize por 30 dias consecutivos';
      case 'Fortuna Acumulada':
        return 'Acumule R\$ 1000 em economias';
      default:
        return 'Conquiste esta medalha';
    }
  }
  
  @override
  Future<bool> hasEarnedMedalha(String medalhaId) async {
    final currentState = await _service.getCurrentState();
    return (currentState['earnedMedalhas'] as List<dynamic>?)?.contains(medalhaId) ?? false;
  }
  
  @override
  Future<void> awardMedalha(String medalhaId) async {
    await _service._checkForNewMedalhas();
  }
  
  @override
  Future<void> revokeMedalha(String medalhaId) async {
    final currentState = await _service.getCurrentState();
    if (currentState.isEmpty) return;
    
    // Implementação profissional seguindo padrão dos outros módulos
    if (currentState['earnedMedalhas'] != null && 
        (currentState['earnedMedalhas'] as List<dynamic>).contains(medalhaId)) {
      
      // Usa método do serviço para revogar medalha
      await _service.revokeMedalhaById(medalhaId);
      
      LoggerService.instance.gamification('Medalha MoneySaving revogada: $medalhaId');
    }
  }
  
  Future<void> resetAllMedalhas() async {
    // Usa método do serviço para resetar medalhas
    await _service.resetAllMedalhasInternal();
    
    LoggerService.instance.gamification('Medalhas MoneySaving resetadas');
  }
  
  @override
  Future<List<String>> getEarnedMedalhas() async {
    final currentState = await _service.getCurrentState();
    return (currentState['earnedMedalhas'] as List<dynamic>?)?.cast<String>() ?? [];
  }
  
  @override
  Future<List<String>> checkForNewMedalhas(Map<String, dynamic> moduleData) async {
    await _service._checkForNewMedalhas();
    return await getEarnedMedalhas();
  }
  
  @override
  Future<void> resetMedalhas() async {
    // Usa método do serviço para resetar medalhas
    await _service.resetAllMedalhasInternal();
  }
  
  @override
  Future<int> getConquestCounter() async {
    final currentState = await _service.getCurrentState();
    return (currentState['disciplinumCount'] as int?) ?? 0;
  }
  
  @override
  Future<void> incrementConquestCounter() async {
    await _service.awardDisciplinum();
  }
}
