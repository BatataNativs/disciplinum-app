import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/entities/procrastination_module_state.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/repositories/procrastination_gamification_repository.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';

/// Controller de UI para gamificação do Procrastination
/// Segue o padrão dos outros módulos para independência total
/// Gerencia estado da UI e interage com services de domínio específicos do Procrastination
class ProcrastinationGamificationController extends ChangeNotifier {
  final ProcrastinationGamificationRepository _repository;
  final AuthService _authService;
  
  ProcrastinationModuleState? _moduleState;
  bool _isLoading = false;
  String? _error;

  ProcrastinationGamificationController({
    required ProcrastinationGamificationRepository repository,
    required AuthService authService,
  }) : _repository = repository, _authService = authService;

  // Getters públicos
  ProcrastinationModuleState? get moduleState => _moduleState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Getters derivados do estado
  int get currentStreak => _moduleState?.consecutiveDays ?? 0;
  int get disciplinumCount => _moduleState?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => _moduleState?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => _moduleState?.earnedMedalhas ?? [];
  bool get isActive => _moduleState?.isActive ?? false;

  /// Carrega o estado do módulo Procrastination
  Future<void> loadModuleState() async {
    _setLoading(true);
    _clearError();
    
    try {
      _moduleState = await _repository.performFullSync();
      
      LoggerService.instance.i('Procrastination module state loaded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4, // Procrastination niche ID
        habitType: 'state_loaded',
        metadata: {
          'streak': _moduleState!.consecutiveDays,
          'active': _moduleState!.isActive,
          'disciplinum_count': _moduleState!.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error loading Procrastination module state', error: e, stackTrace: stackTrace);
      _setError('Erro ao carregar estado do módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa dia produtivo (todas as tarefas concluídas)
  Future<void> performProductiveDay() async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_moduleState == null) {
        _setError('Módulo não carregado');
        return;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        _setError('Usuário não autenticado');
        return;
      }

      // Verificar se já teve check-in hoje
      final today = DateTime.now();
      final lastUpdated = _moduleState?.lastUpdated;
      if (lastUpdated != null &&
          lastUpdated.year == today.year &&
          lastUpdated.month == today.month &&
          lastUpdated.day == today.day) {
        // Já fez check-in hoje, apenas loga
        LoggerService.instance.d('Check-in já registrado hoje no Procrastination');
        _setLoading(false);
        return;
      }

      // Atualizar estado com novo dia produtivo
      final updatedState = _moduleState!.copyWith(
        consecutiveDays: _moduleState!.consecutiveDays + 1,
        disciplinumCount: _moduleState!.disciplinumCount + 1,
        lastUpdated: DateTime.now(),
      );

      // Salvar estado
      await _repository.saveProcrastinationState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Procrastination productive day recorded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4,
        habitType: 'productive_day',
        metadata: {
          'streak': updatedState.consecutiveDays,
          'disciplinum_count': updatedState.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Procrastination productive day', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar dia produtivo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa dia improdutivo (procrastinou)
  Future<void> performProcrastinationDay() async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_moduleState == null) {
        _setError('Módulo não carregado');
        return;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        _setError('Usuário não autenticado');
        return;
      }

      // Resetar streak em caso de procrastinação
      final updatedState = _moduleState!.copyWith(
        consecutiveDays: 0,
        lastUpdated: DateTime.now(),
      );

      // Salvar estado
      await _repository.saveProcrastinationState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Procrastination day processed');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4,
        habitType: 'procrastination_day',
        metadata: {
          'streak': 0,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Procrastination day', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar dia de procrastinação');
    } finally {
      _setLoading(false);
    }
  }

  /// Ativa o módulo Procrastination
  Future<void> activateModule() async {
    _setLoading(true);
    _clearError();
    
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        _setError('Usuário não autenticado');
        return;
      }

      if (_moduleState == null) {
        // Criar novo estado
        _moduleState = ProcrastinationModuleState(
          earnedInsignias: const [],
          earnedMedalhas: const [],
          consecutiveDays: 0,
          disciplinumCount: 0,
          lastUpdated: DateTime.now(),
          isActive: true,
        );
      } else {
        // Ativar estado existente
        _moduleState = _moduleState!.copyWith(
          isActive: true,
          lastUpdated: DateTime.now(),
        );
      }

      await _repository.saveProcrastinationState(_moduleState!);
      
      LoggerService.instance.i('Procrastination module activated');
      
      // Analytics
      await AnalyticsService.instance.trackModuleStarted(
        nicheId: 4,
        source: 'controller',
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error activating Procrastination module', error: e, stackTrace: stackTrace);
      _setError('Erro ao ativar módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Desativa o módulo Procrastination
  Future<void> deactivateModule() async {
    _setLoading(true);
    _clearError();
    
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        _setError('Usuário não autenticado');
        return;
      }

      if (_moduleState != null) {
        // Desativar estado existente
        _moduleState = _moduleState!.copyWith(
          isActive: false,
          lastUpdated: DateTime.now(),
        );

        await _repository.saveProcrastinationState(_moduleState!);
      }

      LoggerService.instance.i('Procrastination module deactivated');
      
      // Analytics - Não há método específico para desativação, usar trackHabitCompleted
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4,
        habitType: 'module_deactivated',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error deactivating Procrastination module', error: e, stackTrace: stackTrace);
      _setError('Erro ao desativar módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Reseta progresso do módulo
  Future<void> resetProgress() async {
    _setLoading(true);
    _clearError();
    
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        _setError('Usuário não autenticado');
        return;
      }

      final resetState = ProcrastinationModuleState.initial();
      
      await _repository.saveProcrastinationState(resetState);
      _moduleState = resetState;

      LoggerService.instance.w('Procrastination module progress reset');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4,
        habitType: 'progress_reset',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error resetting Procrastination progress', error: e, stackTrace: stackTrace);
      _setError('Erro ao resetar progresso');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém mensagem motivacional baseada no streak atual
  String getStreakMessage() {
    final streak = currentStreak;
    if (streak == 0) return 'Comece sua jornada contra a procrastinação hoje! 💪';
    if (streak == 1) return '1 dia produtivo! Parabéns!';
    if (streak == 2) return '2 dias produtivos! Continue assim!';
    if (streak == 3) return '3 dias produtivos! Sua disciplina é impressionante!';
    if (streak == 5) return '5 dias produtivos! Você está vencendo a procrastinação!';
    if (streak == 12) return '12 dias produtivos! Quase na medalha de Bronze!';
    if (streak == 18) return '18 dias produtivos! Medalha de Bronze conquistada!';
    if (streak == 25) return '25 dias produtivos! Quase na medalha de Prata!';
    if (streak == 30) return '30 dias produtivos! Medalha de Prata conquistada!';
    
    return '$streak dias produtivos! Nada pode te parar!';
  }

  /// Verifica se alcançou milestone
  bool reachedMilestone() {
    const milestones = [1, 2, 3, 5, 12, 18, 25, 30];
    return milestones.contains(currentStreak);
  }

  /// Obtém próximo milestone
  int getNextMilestone() {
    const milestones = [1, 2, 3, 5, 12, 18, 25, 30];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    
    // Se passou todos os milestones, próximo é a cada 30 dias
    return ((currentStreak ~/ 30) + 1) * 30;
  }

  /// Obtém ID do usuário atual
  String? _getCurrentUserId() {
    return _authService.currentUser?.id;
  }

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

  /// Reinicializa o controller
  @override
  void dispose() {
    _moduleState = null;
    _isLoading = false;
    _error = null;
    super.dispose();
  }
}
