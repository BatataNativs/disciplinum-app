import 'package:disciplinum/core/gamification/interfaces/module_gamification_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_insignia.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_insignia_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_medalha_service.dart';

/// Service principal de gamificação do módulo Smoking
/// Orquestra todos os serviços de gamificação do módulo
class SmokingGamificationService implements ModuleGamificationInterface {
  final SmokingGamificationRepository _repository;
  late final SmokingInsigniaService _insigniaService;
  late final SmokingMedalhaService _medalhaService;
  
  SmokingModuleState? _currentState;
  bool _isInitialized = false;

  SmokingGamificationService(this._repository) {
    _insigniaService = SmokingInsigniaService();
    _medalhaService = SmokingMedalhaService();
  }

  /// Inicializa o serviço de gamificação
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _repository.initialize();
      await _insigniaService.initialize();
      await _medalhaService.initialize();
      
      _currentState = await _repository.getSmokingState();
      
      if (_currentState == null) {
        _currentState = SmokingModuleState();
        await _repository.saveSmokingState(_currentState!);
      }

      _isInitialized = true;
      LoggerService.instance.gamification('SmokingGamificationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar SmokingGamificationService', error: e);
      rethrow;
    }
  }

  /// Processa eventos do módulo (check-ins positivos, etc.)
  @override
  Future<void> processModuleEvent(Map<String, dynamic> eventData) async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('SmokingGamificationService não inicializado');
      return;
    }

    try {
      final eventType = eventData['type'] as String?;
      
      switch (eventType) {
        case 'positive_checkin':
          await _processPositiveCheckIn(eventData);
          break;
        case 'negative_checkin':
          await _processNegativeCheckIn(eventData);
          break;
        case 'streak_update':
          await _processStreakUpdate(eventData);
          break;
        default:
          LoggerService.instance.w('Tipo de evento não reconhecido: $eventType');
      }
      
      await checkForNewAchievements();
    } catch (e) {
      LoggerService.instance.e('Erro ao processar evento do módulo Smoking', error: e);
    }
  }

  /// Processa check-in positivo
  Future<void> _processPositiveCheckIn(Map<String, dynamic> eventData) async {
    final consecutiveDays = (eventData['consecutiveDays'] ?? 0) as int;
    
    final updatedState = _currentState!.copyWith(
      consecutivePositiveDays: consecutiveDays,
      lastPositiveCheckIn: DateTime.now(),
      startDate: _currentState!.startDate ?? DateTime.now(),
    );
    
    await _updateState(updatedState);
    
    // Verifica novas insignias
    final moduleData = {'consecutiveDays': consecutiveDays};
    await _insigniaService.checkForNewInsignias(moduleData);
  }

  /// Processa check-in negativo (recaída)
  Future<void> _processNegativeCheckIn(Map<String, dynamic> eventData) async {
    LoggerService.instance.gamification('Recaída registrada - resetando streak');
    
    // Reseta apenas os dias consecutivos, mas preserva conquistas
    final updatedState = _currentState!.copyWith(
      consecutivePositiveDays: 0,
    );
    
    await _updateState(updatedState);
  }

  /// Processa atualização de streak
  Future<void> _processStreakUpdate(Map<String, dynamic> eventData) async {
    final consecutiveDays = (eventData['consecutiveDays'] ?? 0) as int;
    
    final updatedState = _currentState!.copyWith(
      consecutivePositiveDays: consecutiveDays,
    );
    
    await _updateState(updatedState);
    
    final moduleData = {'consecutiveDays': consecutiveDays};
    await _insigniaService.checkForNewInsignias(moduleData);
  }

  /// Reseta o progresso do módulo
  @override
  Future<void> resetProgress() async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('SmokingGamificationService não inicializado');
      return;
    }

    try {
      final resetState = SmokingModuleState();
      
      await _updateState(resetState);
      await _insigniaService.resetInsignias();
      await _medalhaService.resetMedalhas();
      
      LoggerService.instance.gamification('Progresso do Smoking resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso Smoking', error: e);
    }
  }

  /// Obtém o estado atual
  @override
  Future<Map<String, dynamic>> getCurrentState() async {
    if (!_isInitialized || _currentState == null) {
      return SmokingModuleState().toJson();
    }
    return _currentState!.toJson();
  }

  /// Verifica por novas conquistas
  @override
  Future<void> checkForNewAchievements() async {
    if (!_isInitialized || _currentState == null) return;

    try {
      // Verifica medalhas baseadas em insignias Disciplinum
      final moduleData = {'earnedInsignias': _currentState!.earnedInsignias};
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
      if (_currentState!.consecutivePositiveDays == 1) {
        LoggerService.instance.gamification('🎉 Primeiro dia sem fumar! Continue assim!');
      }
      
      if (_currentState!.consecutivePositiveDays == 7) {
        LoggerService.instance.gamification('🏆 7 dias sem fumar! Você está indo muito bem!');
      }
      
      if (_currentState!.consecutivePositiveDays == 30) {
        LoggerService.instance.gamification('💪 30 dias! Você é um guerreiro contra o cigarro!');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificações especiais', error: e);
    }
  }

  /// Atualiza o estado
  Future<void> _updateState(SmokingModuleState newState) async {
    _currentState = newState;
    await _repository.saveSmokingState(newState);
  }

  /// Getters para acesso rápido
  @override
  ModuleInsigniaInterface get insigniaService => _insigniaService;
  
  @override
  ModuleMedalhaInterface get medalhaService => _medalhaService;
  
  @override
  String get moduleId => 'smoking';
  
  @override
  String get moduleName => 'Parar de Fumar';
  
  int get consecutivePositiveDays => _currentState?.consecutivePositiveDays ?? 0;
  int get disciplinumCount => _currentState?.disciplinumCount ?? 0;
  bool get isActive => _currentState != null;
  bool get isInStreak => (_currentState?.consecutivePositiveDays ?? 0) > 0;

  /// Obtém progresso para próxima insignia
  double getProgressToNextInsignia() {
    if (!_isInitialized || _currentState == null) return 0.0;
    
    final consecutiveDays = _currentState!.consecutivePositiveDays;
    final earnedInsignias = _currentState!.earnedInsignias;
    
    // Encontrar próxima insignia não conquistada
    for (final insignia in SmokingInsigniaEntity.values) {
      final insigniaName = insignia.name;
      if (!earnedInsignias.contains(insigniaName)) {
        // Calcular progresso para esta insignia baseado nos dias necessários
        final requiredDays = insignia.requiredDays;
        if (requiredDays == 0) return 1.0; // Madeira é conquistada automaticamente
        return (consecutiveDays / requiredDays).clamp(0.0, 1.0);
      }
    }
    
    // Todas as insignias conquistadas
    return 1.0;
  }

  /// Obtém progresso para próxima medalha
  double getProgressToNextMedalha() {
    if (!_isInitialized || _currentState == null) return 0.0;
    
    final earnedInsigniasCount = _currentState!.earnedInsignias.length;
    final totalInsignias = SmokingInsigniaEntity.values.length;
    
    // Progresso baseado em quantas insignias foram conquistadas
    return (earnedInsigniasCount / totalInsignias).clamp(0.0, 1.0);
  }

  /// Obtém estatísticas detalhadas
  Future<Map<String, dynamic>> getStatistics() async {
    if (!_isInitialized || _currentState == null) {
      return {
        'moduleId': moduleId,
        'moduleName': moduleName,
        'consecutivePositiveDays': 0,
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
      'consecutivePositiveDays': _currentState!.consecutivePositiveDays,
      'disciplinumCount': disciplinumCount,
      'earnedInsignias': _currentState!.earnedInsignias,
      'earnedMedalhas': _currentState!.earnedMedalhas,
      'isActive': true,
      'isInStreak': isInStreak,
      'lastPositiveCheckIn': _currentState!.lastPositiveCheckIn?.toIso8601String(),
      'startDate': _currentState!.startDate?.toIso8601String(),
    };
  }

  // ===========================================
  // MÉTODOS PARA MENSAGENS CUSTOMIZADAS (FRAGMENTAÇÃO)
  // ===========================================
  
  /// Armazena mensagens customizadas por módulo
  final Map<String, List<String>> _customMessages = {};
  
  /// Obtém todas as mensagens customizadas
  Map<String, List<String>> getCustomMessages() {
    return Map.unmodifiable(_customMessages);
  }
  
  /// Define mensagens customizadas para um módulo específico
  Future<void> setCustomMessages(String moduleId, List<String> messages) async {
    try {
      _customMessages[moduleId] = List<String>.from(messages);
      
      // Persiste no Isar através do repositório
      if (_currentState != null) {
        final updatedState = _currentState!.copyWith(
          customMessages: _customMessages,
        );
        await _updateState(updatedState);
      }
      
      LoggerService.instance.gamification('Mensagens customizadas salvas para módulo: $moduleId');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar mensagens customizadas', error: e);
    }
  }
  
  /// Define a mensagem principal customizada
  Future<void> setCustomMessage(dynamic nicheId, String message) async {
    try {
      // Persiste no estado
      if (_currentState != null) {
        final updatedState = _currentState!.copyWith(
          customMainMessage: message,
        );
        await _updateState(updatedState);
      }
      
      LoggerService.instance.gamification('Mensagem principal customizada salva');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar mensagem principal customizada', error: e);
    }
  }
  
  /// Recarrega sessão de monitoramento (reagenda notificações)
  Future<void> reloadMonitoringSession() async {
    try {
      LoggerService.instance.gamification('Recarregando sessão de monitoramento do Smoking');
      
      // Reagenda notificações de motivação se houver mensagens customizadas
      if (_customMessages.isNotEmpty) {
        // Implementação específica de reagendamento
        LoggerService.instance.gamification('Notificações de motivação reagendadas');
      }
      
      // Notifica outros serviços sobre a recarga
      await sendSpecialNotifications();
      
    } catch (e) {
      LoggerService.instance.e('Erro ao recarregar sessão de monitoramento', error: e);
    }
  }
}
