import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';

/// Controller de UI para gamificação do Money Saving
/// Duplicado da gamificação central para independência total do módulo
/// Gerencia estado da UI e interage com services de domínio específicos do Money Saving
class MoneySavingGamificationController extends ChangeNotifier {
  final MoneySavingGamificationRepository _repository;
  final AuthService _authService;
  
  // Estado privado
  MoneySavingModuleState? _moduleState;
  bool _isLoading = false;
  String? _error;
  
  // Getters públicos
  MoneySavingModuleState? get moduleState => _moduleState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Estatísticas específicas do Money Saving
  bool get hasActiveStreak => _moduleState?.isInStreak ?? false;
  int get currentStreak => _moduleState?.consecutiveDays ?? 0;
  int get totalCheckIns => _moduleState?.completedChallenges ?? 0;
  double get successRate => _moduleState?.gridPercentage.toDouble() ?? 0.0;
  List<String> get earnedInsignias => _moduleState?.earnedInsignias ?? [];
  String? get maxMedal => (_moduleState?.earnedMedalhas.isNotEmpty == true) ? _moduleState!.earnedMedalhas.last : null;
  bool get needsCheckInToday => _moduleState?.streakBroken ?? true;
  double get savingProgress => _moduleState?.gridPercentage.toDouble() ?? 0.0;

  MoneySavingGamificationController({
    required MoneySavingGamificationRepository repository,
    required AuthService authService,
  }) : _repository = repository,
       _authService = authService;

  /// Carrega o estado do módulo Money Saving
  Future<void> loadModuleState() async {
    _setLoading(true);
    _clearError();
    
    try {
      LoggerService.instance.d('Loading Money Saving module state...');
      
      final userId = _getCurrentUserId();
      if (userId == null) {
        _setError('Usuário não autenticado');
        return;
      }

      final state = await _repository.getMoneySavingState();
      _moduleState = state ?? MoneySavingModuleState.initial();
      
      LoggerService.instance.i('Money Saving module state loaded: streak=${_moduleState!.consecutiveDays}');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 8,
        habitType: 'state_loaded',
        metadata: {
          'streak': _moduleState!.consecutiveDays,
          'active': _moduleState!.isModuleActive,
          'check_ins': _moduleState!.completedChallenges,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error loading Money Saving module state', error: e, stackTrace: stackTrace);
      _setError('Erro ao carregar estado do módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa check-in diário de economia
  Future<void> performCheckIn() async {
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

      // Verificar se já fez check-in hoje
      if (!_moduleState!.streakBroken) {
        _setError('Você já registrou sua economia hoje!');
        return;
      }

      // Atualizar streak - implementar lógica de incremento
      final updatedState = _moduleState!.copyWith(
        consecutiveDays: _moduleState!.consecutiveDays + 1,
        completedChallenges: _moduleState!.completedChallenges + 1,
        lastSavingDate: DateTime.now(),
      );

      // Salvar estado atualizado
      await _repository.saveMoneySavingState(updatedState);
      _moduleState = updatedState;
      
      LoggerService.instance.i('Money Saving check-in performed: new streak=${updatedState.consecutiveDays}');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 8,
        habitType: 'check_in',
        metadata: {
          'streak': updatedState.consecutiveDays,
          'total_check_ins': updatedState.completedChallenges,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Money Saving check-in', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar economia');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa recaída (gasto excessivo)
  Future<void> performRelapse() async {
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

      // Resetar streak em caso de recaída
      final updatedState = _moduleState!.copyWith(
        consecutiveDays: 0,
        lastSavingDate: null,
      );

      // Salvar estado atualizado
      await _repository.saveMoneySavingState(updatedState);
      _moduleState = updatedState;
      
      LoggerService.instance.w('Money Saving relapse performed: streak reset to ${updatedState.consecutiveDays}');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 8,
        habitType: 'relapse',
        metadata: {
          'streak': updatedState.consecutiveDays,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Money Saving relapse', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar recaída');
    } finally {
      _setLoading(false);
    }
  }

  /// Ativa o módulo Money Saving
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
        _moduleState = MoneySavingModuleState(
          isModuleActive: true,
        );
      } else {
        // Ativar estado existente
        _moduleState = _moduleState!.copyWith(
          isModuleActive: true,
        );
      }

      await _repository.saveMoneySavingState(_moduleState!);
      
      LoggerService.instance.i('Money Saving module activated');
      
      // Analytics
      await AnalyticsService.instance.trackModuleStarted(
        nicheId: 8,
        source: 'controller',
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error activating Money Saving module', error: e, stackTrace: stackTrace);
      _setError('Erro ao ativar módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Desativa o módulo Money Saving
  Future<void> deactivateModule() async {
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

      final updatedState = _moduleState!.copyWith(
        isModuleActive: false,
      );

      await _repository.saveMoneySavingState(updatedState);
      _moduleState = updatedState;
      
      LoggerService.instance.i('Money Saving module deactivated');
      
      // Analytics - Não há método específico para desativação, usar trackHabitCompleted
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 8,
        habitType: 'module_deactivated',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error deactivating Money Saving module', error: e, stackTrace: stackTrace);
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

      final resetState = MoneySavingModuleState(
        isModuleActive: _moduleState?.isModuleActive ?? false,
      );

      await _repository.saveMoneySavingState(resetState);
      _moduleState = resetState;
      
      LoggerService.instance.w('Money Saving module progress reset');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 8,
        habitType: 'progress_reset',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error resetting Money Saving progress', error: e, stackTrace: stackTrace);
      _setError('Erro ao resetar progresso');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém mensagem motivacional baseada no streak atual
  String getStreakMessage() {
    final streak = currentStreak;
    if (streak == 0) return 'Comece sua jornada de economia hoje! 💪';
    if (streak == 1) return '1 dia economizando. Parabéns!';
    if (streak == 3) return '3 dias economizando! Continue assim!';
    if (streak == 7) return '7 dias economizando! Sua disciplina financeira é impressionante!';
    if (streak == 14) return '14 dias economizando! Você está construindo um futuro próspero!';
    if (streak == 21) return '21 dias economizando! Hábito financeiro consolidado!';
    if (streak == 30) return '30 dias economizando! Você é um mestre da poupança!';
    if (streak == 50) return '50 dias economizando! Sua força de vontade é inspiradora!';
    if (streak == 100) return '100 dias economizando! Você é uma lenda da disciplina financeira!!! Parabéns!';
    if (streak == 365) return '365 dias economizando! Um ano de dedicação financeira! Incrível!';
    
    return '$streak dias economizando! Nada pode te parar!';
  }

  /// Verifica se alcançou milestone
  bool reachedMilestone() {
    const milestones = [1, 3, 7, 14, 21, 30, 50, 100, 365];
    return milestones.contains(currentStreak);
  }

  /// Obtém próximo milestone
  int getNextMilestone() {
    const milestones = [1, 3, 7, 14, 21, 30, 50, 100, 365];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    
    // Se passou todos os milestones, próximo é a cada 100 dias
    return ((currentStreak ~/ 100) + 1) * 100;
  }

  /// Métodos privados
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
}
