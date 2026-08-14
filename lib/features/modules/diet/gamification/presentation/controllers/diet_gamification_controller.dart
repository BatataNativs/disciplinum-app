import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_module_state.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/presentation/controllers/auth_controller.dart';

/// Controller de UI para gamificação do Diet
/// Segue o padrão dos outros módulos para independência total
/// Gerencia estado da UI e interage com services de domínio específicos do Diet
class DietGamificationController extends ChangeNotifier {
  final DietGamificationRepository _repository;
  final AuthController _authService;
  
  DietModuleState? _moduleState;
  bool _isLoading = false;
  String? _error;

  DietGamificationController({
    required DietGamificationRepository repository,
    required AuthController authService,
  }) : _repository = repository, _authService = authService;

  // Getters públicos
  DietModuleState? get moduleState => _moduleState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Getters derivados do estado
  int get currentStreak => _moduleState?.consecutiveDays ?? 0;
  int get disciplinumCount => _moduleState?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => _moduleState?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => _moduleState?.earnedMedalhas ?? [];
  bool get isModuleActive => _moduleState?.isModuleActive ?? false;

  /// Carrega o estado do módulo Diet
  Future<void> loadModuleState() async {
    _setLoading(true);
    _clearError();
    
    try {
      _moduleState = await _repository.performFullSync();
      
      LoggerService.instance.i('Diet module state loaded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 2, // Diet niche ID
        habitType: 'state_loaded',
        metadata: {
          'streak': _moduleState!.consecutiveDays,
          'active': _moduleState!.isModuleActive,
          'disciplinum_count': _moduleState!.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error loading Diet module state', error: e, stackTrace: stackTrace);
      _setError('Erro ao carregar estado do módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa check-in positivo (refeições nos horários)
  Future<void> performPositiveDay() async {
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
      final now = DateTime.now();
      final lastUpdated = _moduleState!.lastUpdated;
      if (lastUpdated.year == now.year &&
          lastUpdated.month == now.month &&
          lastUpdated.day == now.day) {
        _setError('Check-in já registrado hoje');
        return;
      }

      // Atualizar estado com novo check-in positivo
      final updatedState = _moduleState!.copyWith(
        consecutiveDays: _moduleState!.consecutiveDays + 1,
        disciplinumCount: _moduleState!.disciplinumCount + 1,
      );

      // Salvar estado
      await _repository.saveDietState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Diet positive day recorded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 2,
        habitType: 'positive_day',
        metadata: {
          'streak': updatedState.consecutiveDays,
          'disciplinum_count': updatedState.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Diet positive day', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar dia positivo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa recaída (errou dieta)
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
      );

      // Salvar estado
      await _repository.saveDietState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Diet relapse processed');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 2,
        habitType: 'relapse',
        metadata: {
          'streak': 0,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Diet relapse', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar recaída');
    } finally {
      _setLoading(false);
    }
  }

  /// Ativa o módulo Diet
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
        _moduleState = DietModuleState(
          earnedInsignias: const [],
          earnedMedalhas: const [],
          consecutiveDays: 0,
          disciplinumCount: 0,
          isModuleActive: true,
        );
      } else {
        // Ativar estado existente
        _moduleState = _moduleState!.copyWith(
          isModuleActive: true,
        );
      }

      await _repository.saveDietState(_moduleState!);
      
      LoggerService.instance.i('Diet module activated');
      
      // Analytics
      await AnalyticsService.instance.trackModuleStarted(
        nicheId: 2,
        source: 'controller',
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error activating Diet module', error: e, stackTrace: stackTrace);
      _setError('Erro ao ativar módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Desativa o módulo Diet
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

        await _repository.saveDietState(_moduleState!);
      }

      LoggerService.instance.i('Diet module deactivated');
      
      // Analytics - Não há método específico para desativação, usar trackHabitCompleted
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 2,
        habitType: 'module_deactivated',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error deactivating Diet module', error: e, stackTrace: stackTrace);
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

      final resetState = DietModuleState.initial();
      
      await _repository.saveDietState(resetState);
      _moduleState = resetState;

      LoggerService.instance.w('Diet module progress reset');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 2,
        habitType: 'progress_reset',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error resetting Diet progress', error: e, stackTrace: stackTrace);
      _setError('Erro ao resetar progresso');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém mensagem motivacional baseada no streak atual
  String getStreakMessage() {
    final streak = currentStreak;
    if (streak == 0) return 'Comece sua jornada de disciplina alimentar hoje! 💪';
    if (streak == 1) return '1 dia com dieta! Parabéns!';
    if (streak == 2) return '2 dias com dieta! Continue assim!';
    if (streak == 4) return '4 dias com dieta! Sua força de vontade é impressionante!';
    if (streak == 8) return '8 dias com dieta! Você está construindo hábitos saudáveis!';
    if (streak == 12) return '12 dias com dieta! Sua disciplina é inspiradora!';
    if (streak == 18) return '18 dias com dieta! Você é um exemplo de dedicação!';
    if (streak == 26) return '26 dias com dieta! Quase um mês de consistência!';
    if (streak == 30) return '30 dias com dieta! Você é um mestre da disciplina alimentar!';
    
    return '$streak dias com dieta! Nada pode te parar!';
  }

  /// Verifica se alcançou milestone
  bool reachedMilestone() {
    const milestones = [1, 2, 4, 8, 12, 18, 26, 30];
    return milestones.contains(currentStreak);
  }

  /// Obtém próximo milestone
  int getNextMilestone() {
    const milestones = [1, 2, 4, 8, 12, 18, 26, 30];
    
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
