import 'package:disciplinum/core/gamification/base/base_module_gamification_service.dart';
import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_module_state.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_insignia_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_medalha_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_notification_service.dart';

/// Service principal de gamificação do módulo Focus
/// Orquestra todos os serviços de gamificação do módulo
class FocusGamificationService extends BaseModuleGamificationService {
  final FocusService _focusService;
  late final FocusInsigniaService _insigniaService;
  late final FocusMedalhaService _medalhaService;
  late final FocusNotificationService _notificationService;
  FocusModuleState? _currentState;

  FocusGamificationService(this._focusService) {
    _insigniaService = FocusInsigniaService(_focusService);
    _medalhaService = FocusMedalhaService();
    _notificationService = FocusNotificationService();
  }

  @override
  String get moduleId => 'focus';

  @override
  String get moduleName => 'Foco e Produtividade';

  @override
  ModuleInsigniaInterface get insigniaService => _insigniaService;

  @override
  ModuleMedalhaInterface get medalhaService => _medalhaService;

  @override
  Future<void> initializeModuleSpecific() async {
    await _insigniaService.initialize();
    await _medalhaService.initialize();
    
    // Carrega estado atual
    _currentState = await _insigniaService.getCurrentState();
    
    // Sincroniza medalha service com estado atual
    _medalhaService.updateFromModuleState(_currentState!);
    
    LoggerService.instance.gamification('FocusGamificationService inicializado');
  }

  @override
  Future<void> initialize() async {
    await initializeModuleSpecific();
  }

  Future<void> updateFromModuleState(FocusModuleState state) async {
    _currentState = state;
    _medalhaService.updateFromModuleState(state);
  }

  @override
  Future<void> processModuleSpecificEvent(Map<String, dynamic> eventData) async {
    final eventType = eventData['type'] as String?;
    
    switch (eventType) {
      case 'period_respected':
        await _handlePeriodRespected();
        break;
      case 'period_failed':
        await _handlePeriodFailed();
        break;
      case 'module_activated':
        await _handleModuleActivated();
        break;
      case 'module_deactivated':
        await _handleModuleDeactivated();
        break;
      default:
        LoggerService.instance.gamification('Evento desconhecido no Focus: $eventType');
    }
  }

  @override
  Future<void> resetModuleSpecificProgress() async {
    await _insigniaService.resetInsignias();
    await _medalhaService.resetMedalhas();
    
    // Reset no FocusService principal
    await _focusService.resetProgress();
    
    _currentState = await _insigniaService.getCurrentState();
  }

  @override
  Future<Map<String, dynamic>> getCurrentState() async {
    final state = await _insigniaService.getCurrentState();
    
    return {
      'moduleId': moduleId,
      'moduleName': moduleName,
      'earnedInsignias': state.earnedInsignias,
      'earnedMedalhas': await _medalhaService.getEarnedMedalhas(),
      'respectedPeriods': state.respectedPeriods,
      'lastUpdated': state.lastUpdated.toIso8601String(),
      'isActive': state.isActive,
      'disciplinumCount': state.disciplinumCount,
    };
  }

  @override
  Future<void> sendSpecialNotifications() async {
    // Focus não tem notificações especiais como saúde/economia
    // Mas poderia ter notificações de milestones, motivação, etc.
    await _checkForMilestoneNotifications();
  }

  /// Processa um período de foco respeitado
  Future<void> _handlePeriodRespected() async {
    try {
      // Adiciona período respeitado no FocusService
      await _focusService.addRespectedPeriod();
      
      // Atualiza estado local
      _currentState = await _insigniaService.getCurrentState();
      
      LoggerService.instance.gamification('Período de foco respeitado processado');
    } catch (e) {
      LoggerService.instance.e('Erro ao processar período respeitado', error: e);
    }
  }

  /// Processa uma falha no período de foco
  Future<void> _handlePeriodFailed() async {
    try {
      // Reset do progresso (regra de negócio)
      await resetProgress();
      
      LoggerService.instance.gamification('Falha no período de foco - progresso resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao processar falha no período', error: e);
    }
  }

  /// Processa ativação do módulo
  Future<void> _handleModuleActivated() async {
    try {
      // Garante que a insígnia Madeira foi concedida
      await _insigniaService.awardInsignia('madeira');
      
      LoggerService.instance.gamification('Módulo Focus ativado');
    } catch (e) {
      LoggerService.instance.e('Erro ao ativar módulo Focus', error: e);
    }
  }

  /// Processa desativação do módulo
  Future<void> _handleModuleDeactivated() async {
    try {
      await resetProgress();
      LoggerService.instance.gamification('Módulo Focus desativado');
    } catch (e) {
      LoggerService.instance.e('Erro ao desativar módulo Focus', error: e);
    }
  }

  /// Verifica por notificações de milestones
  Future<void> _checkForMilestoneNotifications() async {
    final state = _currentState!;
    
    // Exemplo: Notificar quando alcançar 50% do progresso
    if (state.respectedPeriods == 5 && !state.hasInsignia('prata')) {
      await _notificationService.sendMilestoneNotification(5, 'Prata');
      LoggerService.instance.gamification('Milestone alcançado: 5 períodos de foco');
    }
    
    // Exemplo: Notificar quando estiver perto do Disciplinum
    if (state.respectedPeriods == 8 && !state.hasInsignia('diamante')) {
      await _notificationService.sendMotivationalNotification(8, 'Diamante');
      LoggerService.instance.gamification('Próximo do Disciplinum: 8 períodos');
    }
  }

  /// Obtém o progresso percentual geral
  double getProgressPercentage() {
    if (_currentState == null) return 0.0;
    
    final maxPeriods = 10; // Disciplinum
    final currentPeriods = _currentState!.respectedPeriods;
    
    return (currentPeriods / maxPeriods).clamp(0.0, 1.0);
  }

  /// Obtém a próxima insígnia a ser conquistada
  String? getNextInsignia() {
    if (_currentState == null) return null;
    return _currentState!.nextInsignia;
  }

  /// Verifica se o usuário pode conceder nova insígnia Disciplinum
  bool canAwardNewDisciplinum() {
    if (_currentState == null) return false;
    
    // Se já tem 4 disciplinums, não pode mais
    if (_currentState!.disciplinumCount >= 4) return false;
    
    // Se completou 10 períodos, pode conceder
    return _currentState!.respectedPeriods >= 10;
  }

  /// Concede nova insígnia Disciplinum se possível
  Future<bool> tryAwardDisciplinum() async {
    if (!canAwardNewDisciplinum()) return false;
    
    try {
      await _insigniaService.awardInsignia('disciplinum');
      
      // Atualiza estado
      _currentState = await _insigniaService.getCurrentState();
      
      // Verifica medalhas
      _medalhaService.checkDisciplinumMedalhas(_currentState!.disciplinumCount);
      
      LoggerService.instance.gamification('Nova insígnia Disciplinum concedida!');
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro ao conceder insígnia Disciplinum', error: e);
      return false;
    }
  }
}
