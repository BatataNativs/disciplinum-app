import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/presentation/controllers/auth_controller.dart';

/// Controller de UI para gamificação do Focus (versão plugin)
/// Segue o padrão dos outros módulos para independência total
/// Gerencia estado da UI e interage com services de domínio específicos do Focus
class FocusGamificationController extends ChangeNotifier {
  final FocusGamificationRepository _repository;
  final AuthController _authService;
  
  FocusModuleState? _moduleState;
  bool _isLoading = false;
  String? _error;

  FocusGamificationController({
    required FocusGamificationRepository repository,
    required AuthController authService,
  }) : _repository = repository, _authService = authService;

  // Getters públicos
  FocusModuleState? get moduleState => _moduleState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Getters derivados do estado
  int get currentStreak => _moduleState?.respectedPeriodsCount ?? 0;
  int get disciplinumCount => _moduleState?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => _moduleState?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => _moduleState?.earnedMedalhas ?? [];
  bool get isModuleActive => _moduleState?.isModuleActive ?? false;

  /// Carrega o estado do módulo Focus
  Future<void> loadModuleState() async {
    _setLoading(true);
    _clearError();
    
    try {
      _moduleState = await _repository.performFullSync();
      
      LoggerService.instance.i('Focus module state loaded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 3, // Focus niche ID
        habitType: 'state_loaded',
        metadata: {
          'streak': _moduleState!.respectedPeriods,
          'active': _moduleState!.isModuleActive,
          'disciplinum_count': _moduleState!.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error loading Focus module state', error: e, stackTrace: stackTrace);
      _setError('Erro ao carregar estado do módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa período de foco respeitado
  Future<void> performRespectedPeriod() async {
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

      // Verificar se já teve foco hoje
      final today = DateTime.now();
      final lastUpdated = _moduleState?.lastUpdated;
      if (lastUpdated != null &&
          lastUpdated.year == today.year &&
          lastUpdated.month == today.month &&
          lastUpdated.day == today.day) {
        // Já registrou foco hoje, verificar se quer contabilizar novo período
        LoggerService.instance.d('Foco já registrado hoje, incrementando período adicional');
      }

      // Atualizar estado com novo período respeitado
      final updatedState = _moduleState!.copyWith(
        respectedPeriods: [..._moduleState!.respectedPeriods, 'period_${_moduleState!.respectedPeriods.length + 1}'],
      );

      // Salvar estado
      await _repository.saveFocusState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Focus respected period recorded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 3,
        habitType: 'respected_period',
        metadata: {
          'streak': updatedState.respectedPeriods,
          'disciplinum_count': updatedState.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Focus respected period', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar período respeitado');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa período não respeitado (quebrou o foco)
  Future<void> performBrokenPeriod() async {
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

      // Resetar streak em caso de período quebrado
      final updatedState = _moduleState!.copyWith(
        respectedPeriods: const [],
      );

      // Salvar estado
      await _repository.saveFocusState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Focus broken period processed');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 3,
        habitType: 'broken_period',
        metadata: {
          'streak': 0,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Focus broken period', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar período quebrado');
    } finally {
      _setLoading(false);
    }
  }

  /// Ativa o módulo Focus
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
        _moduleState = FocusModuleState.initial();
      } else {
        // Ativar estado existente
        _moduleState = _moduleState!.copyWith(
          isModuleActive: true,
        );
      }

      await _repository.saveFocusState(_moduleState!);
      
      LoggerService.instance.i('Focus module activated');
      
      // Analytics
      await AnalyticsService.instance.trackModuleStarted(
        nicheId: 3,
        source: 'controller',
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error activating Focus module', error: e, stackTrace: stackTrace);
      _setError('Erro ao ativar módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Desativa o módulo Focus
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
          isModuleActive: false,
        );

        await _repository.saveFocusState(_moduleState!);
      }

      LoggerService.instance.i('Focus module deactivated');
      
      // Analytics - Não há método específico para desativação, usar trackHabitCompleted
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 3,
        habitType: 'module_deactivated',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error deactivating Focus module', error: e, stackTrace: stackTrace);
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

      final resetState = (_moduleState ?? FocusModuleState.initial()).reset();
      
      await _repository.saveFocusState(resetState);
      _moduleState = resetState;

      LoggerService.instance.w('Focus module progress reset');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 3,
        habitType: 'progress_reset',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error resetting Focus progress', error: e, stackTrace: stackTrace);
      _setError('Erro ao resetar progresso');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém mensagem motivacional baseada no streak atual
  String getStreakMessage() {
    final streak = currentStreak;
    if (streak == 0) return 'Comece sua jornada de foco hoje! 💪';
    if (streak == 1) return '1 período focado! Parabéns!';
    if (streak == 2) return '2 períodos focados! Continue assim!';
    if (streak == 3) return '3 períodos focados! Sua disciplina é impressionante!';
    if (streak == 4) return '4 períodos focados! Você está construindo o hábito!';
    if (streak == 5) return '5 períodos focados! Quase na medalha de Bronze!';
    if (streak == 6) return '6 períodos focados! Medalha de Bronze conquistada!';
    if (streak == 9) return '9 períodos focados! Quase na medalha de Prata!';
    if (streak == 10) return '10 períodos focados! Medalha de Prata conquistada!';
    
    return '$streak períodos focados! Nada pode te parar!';
  }

  /// Verifica se alcançou milestone
  bool reachedMilestone() {
    const milestones = [1, 2, 3, 4, 5, 6, 9, 10];
    return milestones.contains(currentStreak);
  }

  /// Obtém próximo milestone
  int getNextMilestone() {
    const milestones = [1, 2, 3, 4, 5, 6, 9, 10];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    
    // Se passou todos os milestones, próximo é a cada 10 períodos
    return ((currentStreak ~/ 10) + 1) * 10;
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
