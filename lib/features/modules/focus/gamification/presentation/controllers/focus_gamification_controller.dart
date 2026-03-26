import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/gamification/domain/entities/insignia.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_insignia.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_medalha.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_gamification_service.dart';

/// Controller de UI para gamificação do módulo Focus
/// Gerencia o estado da UI relacionado à gamificação do Focus
class FocusGamificationController extends ChangeNotifier {
  final FocusGamificationService _gamificationService;
  
  // Estado da gamificação
  List<String> _earnedInsignias = [];
  List<String> _earnedMedalhas = [];
  int _respectedPeriods = 0;
  double _progressPercentage = 0.0;
  String? _nextInsignia;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<String> get earnedInsignias => List.unmodifiable(_earnedInsignias);
  List<String> get earnedMedalhas => List.unmodifiable(_earnedMedalhas);
  int get respectedPeriods => _respectedPeriods;
  double get progressPercentage => _progressPercentage;
  String? get nextInsignia => _nextInsignia;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FocusGamificationController(this._gamificationService) {
    _initialize();
  }

  /// Inicializa o controller
  Future<void> _initialize() async {
    try {
      _setLoading(true);
      
      await _gamificationService.initialize();
      await _loadCurrentState();
      
      LoggerService.instance.gamification('FocusGamificationController inicializado');
    } catch (e) {
      _setError('Falha ao inicializar gamificação: $e');
      LoggerService.instance.e('Erro ao inicializar FocusGamificationController', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega o estado atual da gamificação
  Future<void> _loadCurrentState() async {
    try {
      final state = await _gamificationService.getCurrentState();
      
      _earnedInsignias = List<String>.from(state['earnedInsignias'] ?? []);
      _earnedMedalhas = List<String>.from(state['earnedMedalhas'] ?? []);
      _respectedPeriods = state['respectedPeriods'] ?? 0;
      _progressPercentage = _gamificationService.getProgressPercentage();
      _nextInsignia = _gamificationService.getNextInsignia();
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Falha ao carregar estado: $e');
      LoggerService.instance.e('Erro ao carregar estado da gamificação', error: e);
    }
  }

  /// Processa um evento do módulo Focus
  Future<void> processModuleEvent(Map<String, dynamic> eventData) async {
    try {
      _setLoading(true);
      
      await _gamificationService.processModuleEvent(eventData);
      await _loadCurrentState();
      
      LoggerService.instance.gamification('Evento processado: ${eventData['type']}');
    } catch (e) {
      _setError('Falha ao processar evento: $e');
      LoggerService.instance.e('Erro ao processar evento do módulo', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona um período de foco respeitado
  Future<void> addRespectedPeriod() async {
    await processModuleEvent({
      'type': 'period_respected',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Falha em um período de foco
  Future<void> failPeriod() async {
    await processModuleEvent({
      'type': 'period_failed',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Ativa o módulo
  Future<void> activateModule() async {
    await processModuleEvent({
      'type': 'module_activated',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Desativa o módulo
  Future<void> deactivateModule() async {
    await processModuleEvent({
      'type': 'module_deactivated',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Reseta todo o progresso
  Future<void> resetProgress() async {
    try {
      _setLoading(true);
      
      await _gamificationService.resetProgress();
      await _loadCurrentState();
      
      LoggerService.instance.gamification('Progresso do Focus resetado');
    } catch (e) {
      _setError('Falha ao resetar progresso: $e');
      LoggerService.instance.e('Erro ao resetar progresso', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Tenta conceder nova insígnia Disciplinum
  Future<bool> tryAwardDisciplinum() async {
    try {
      final awarded = await _gamificationService.tryAwardDisciplinum();
      
      if (awarded) {
        await _loadCurrentState();
        LoggerService.instance.gamification('Nova insígnia Disciplinum concedida!');
      }
      
      return awarded;
    } catch (e) {
      _setError('Falha ao conceder insígnia Disciplinum: $e');
      LoggerService.instance.e('Erro ao conceder insígnia Disciplinum', error: e);
      return false;
    }
  }

  /// Recarrega o estado atual
  Future<void> refresh() async {
    await _loadCurrentState();
  }

  /// Obtém informações de uma insígnia específica
  Map<String, String> getInsigniaInfo(String insigniaId) {
    final insigniaEntity = FocusInsigniaEntity.values.firstWhere(
      (e) => e.name == insigniaId,
      orElse: () => FocusInsigniaEntity.madeira,
    );
    
    final baseInsignia = insigniaEntity.toBaseInsignia();
    
    return {
      'id': insigniaId,
      'name': baseInsignia.nameBr,
      'asset': baseInsignia.asset,
      'requirement': baseInsignia.requirementDescription,
      'progress': '${insigniaEntity.progressPercentage.toStringAsFixed(0)}%',
    };
  }

  /// Obtém informações de uma medalha específica
  Map<String, String> getMedalhaInfo(String medalhaId) {
    final medalha = FocusMedalha.values.firstWhere(
      (m) => m.name == medalhaId,
      orElse: () => FocusMedalha.bronze,
    );
    
    return {
      'id': medalhaId,
      'name': medalha.nameBr,
      'asset': medalha.asset,
      'requirement': medalha.requirementDescription,
    };
  }

  /// Verifica se uma insígnia foi conquistada
  bool hasInsignia(String insigniaId) {
    return _earnedInsignias.contains(insigniaId);
  }

  /// Verifica se uma medalha foi conquistada
  bool hasMedalha(String medalhaId) {
    return _earnedMedalhas.contains(medalhaId);
  }

  /// Obtém o número de insígnias Disciplinum conquistadas
  int get disciplinumCount {
    return _earnedInsignias.where((id) => id == 'disciplinum').length;
  }

  /// Verifica se pode conceder nova insígnia Disciplinum
  bool get canAwardDisciplinum {
    return _gamificationService.canAwardNewDisciplinum();
  }

  /// Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    LoggerService.instance.gamification('FocusGamificationController disposed');
    super.dispose();
  }
}
