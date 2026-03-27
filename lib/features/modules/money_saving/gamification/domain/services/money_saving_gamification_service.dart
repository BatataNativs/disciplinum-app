import 'package:disciplinum/core/gamification/interfaces/module_gamification_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_insignia.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/services/money_saving_insignia_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/services/money_saving_medalha_service.dart';

/// Service principal de gamificação do módulo Money Saving Challenge
/// Orquestra todos os serviços de gamificação do módulo
class MoneySavingGamificationService implements ModuleGamificationInterface {
  final MoneySavingGamificationRepository _repository;
  late final MoneySavingInsigniaService _insigniaService;
  late final MoneySavingMedalhaService _medalhaService;
  
  MoneySavingModuleState? _currentState;
  bool _isInitialized = false;

  MoneySavingGamificationService(this._repository) {
    _insigniaService = MoneySavingInsigniaService(_repository);
    _medalhaService = MoneySavingMedalhaService(_repository);
  }

  /// Inicializa o serviço de gamificação
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _repository.initialize();
      await _insigniaService.initialize();
      await _medalhaService.initialize();
      
      _currentState = await _repository.getMoneySavingState();
      
      if (_currentState == null) {
        _currentState = MoneySavingModuleState.initial();
        await _repository.saveMoneySavingState(_currentState!);
      }

      _isInitialized = true;
      LoggerService.instance.gamification('MoneySavingGamificationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar MoneySavingGamificationService', error: e);
      rethrow;
    }
  }

  /// Processa eventos do módulo (economias, metas, etc.)
  @override
  Future<void> processModuleEvent(Map<String, dynamic> eventData) async {
    if (!_isInitialized || _currentState == null) {
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
      
      await checkForNewAchievements();
    } catch (e) {
      LoggerService.instance.e('Erro ao processar evento do módulo Money Saving', error: e);
    }
  }

  /// Processa economia diária
  Future<void> _processDailySave(Map<String, dynamic> eventData) async {
    final amount = (eventData['amount'] ?? 0.0) as double;
    final consecutiveDays = (eventData['consecutiveDays'] ?? 0) as int;
    
    final updatedState = _currentState!.copyWith(
      consecutiveDays: consecutiveDays,
      totalSavedAmount: _currentState!.totalSavedAmount + amount,
      lastSavingDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      startDate: _currentState!.startDate ?? DateTime.now(),
      bestStreak: consecutiveDays > _currentState!.bestStreak ? consecutiveDays : _currentState!.bestStreak,
    );
    
    await _updateState(updatedState);
    
    // Verifica novas insignias
    await _insigniaService.checkAndAwardInsignias(consecutiveDays);
  }

  /// Processa conclusão de meta
  Future<void> _processGoalCompleted(Map<String, dynamic> eventData) async {
    final goalAmount = (eventData['goalAmount'] ?? 0.0) as double;
    
    LoggerService.instance.gamification('Meta concluída: R\$ $goalAmount');
    
    // Pode adicionar lógica específica para metas aqui
    await checkForNewAchievements();
  }

  /// Processa atualização de streak
  Future<void> _processStreakUpdate(Map<String, dynamic> eventData) async {
    final consecutiveDays = (eventData['consecutiveDays'] ?? 0) as int;
    final totalSaved = (eventData['totalSaved'] ?? 0.0) as double;
    
    final updatedState = _currentState!.copyWith(
      consecutiveDays: consecutiveDays,
      totalSavedAmount: totalSaved,
      lastUpdated: DateTime.now(),
    );
    
    if (consecutiveDays > _currentState!.bestStreak) {
      updatedState.copyWith(bestStreak: consecutiveDays);
    }
    
    await _updateState(updatedState);
    await _insigniaService.checkAndAwardInsignias(consecutiveDays);
  }

  /// Reseta o progresso do módulo
  @override
  Future<void> resetProgress() async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingGamificationService não inicializado');
      return;
    }

    try {
      final resetState = MoneySavingModuleState.initial();
      
      await _updateState(resetState);
      await _insigniaService.resetInsignias();
      await _medalhaService.resetMedalhas();
      
      LoggerService.instance.gamification('Progresso do Money Saving resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso Money Saving', error: e);
    }
  }

  /// Obtém o estado atual
  @override
  Future<Map<String, dynamic>> getCurrentState() async {
    if (!_isInitialized || _currentState == null) {
      return MoneySavingModuleState.initial().toJson();
    }
    return _currentState!.toJson();
  }

  /// Verifica por novas conquistas
  @override
  Future<void> checkForNewAchievements() async {
    if (!_isInitialized || _currentState == null) return;

    try {
      // Atualiza contador de insignias Disciplinum
      final disciplinumCount = MoneySavingInsignia.countDisciplinumInsignias(_currentState!.earnedInsignias);
      
      // Verifica medalhas baseadas em insignias Disciplinum
      await _medalhaService.checkAndAwardMedalhas(disciplinumCount);
      
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
      if (_currentState!.consecutiveDays == 7) {
        LoggerService.instance.gamification('🎉 7 dias economizando! Continue assim!');
      }
      
      if (_currentState!.consecutiveDays == 30) {
        LoggerService.instance.gamification('🏆 30 dias! Você é um mestre da economia!');
      }
      
      if (_currentState!.totalSavedAmount >= 1000) {
        LoggerService.instance.gamification('💰 R\$ 1.000 acumulados! Parabéns!');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificações especiais', error: e);
    }
  }

  /// Atualiza o estado
  Future<void> _updateState(MoneySavingModuleState newState) async {
    _currentState = newState;
    await _repository.saveMoneySavingState(newState);
  }

  /// Getters para acesso rápido
  @override
  ModuleInsigniaInterface get insigniaService => _insigniaService;
  
  @override
  ModuleMedalhaInterface get medalhaService => _medalhaService;
  
  @override
  String get moduleId => 'money_saving';
  
  @override
  String get moduleName => 'Money Saving Challenge';
  
  int get consecutiveDays => _currentState?.consecutiveDays ?? 0;
  double get totalSavedAmount => _currentState?.totalSavedAmount ?? 0.0;
  int get disciplinumCount => MoneySavingInsignia.countDisciplinumInsignias(_currentState?.earnedInsignias ?? []);
  bool get isActive => _currentState?.isActive ?? false;
  bool get isInStreak => _currentState?.isInStreak ?? false;

  /// Obtém progresso para próxima insignia
  double getProgressToNextInsignia() {
    return _insigniaService.getProgressToNextInsignia();
  }

  /// Obtém progresso para próxima medalha
  double getProgressToNextMedalha() {
    return _medalhaService.getProgressToNextMedalha();
  }

  /// Obtém estatísticas detalhadas
  Future<Map<String, dynamic>> getStatistics() async {
    if (!_isInitialized || _currentState == null) {
      return {
        'moduleId': moduleId,
        'moduleName': moduleName,
        'consecutiveDays': 0,
        'totalSavedAmount': 0.0,
        'bestStreak': 0,
        'earnedInsignias': <String>[],
        'earnedMedalhas': <String>[],
        'disciplinumCount': 0,
        'isActive': false,
        'isInStreak': false,
      };
    }

    return {
      'moduleId': moduleId,
      'moduleName': moduleName,
      'consecutiveDays': _currentState!.consecutiveDays,
      'totalSavedAmount': _currentState!.totalSavedAmount,
      'bestStreak': _currentState!.bestStreak,
      'earnedInsignias': _currentState!.earnedInsignias,
      'earnedMedalhas': _currentState!.earnedMedalhas,
      'disciplinumCount': disciplinumCount,
      'isActive': _currentState!.isActive,
      'isInStreak': _currentState!.isInStreak,
      'lastSavingDate': _currentState!.lastSavingDate?.toIso8601String(),
      'startDate': _currentState!.startDate?.toIso8601String(),
      'lastUpdated': _currentState!.lastUpdated.toIso8601String(),
    };
  }
}
