import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_module_state.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';

/// Controller de UI para gamificação do Binge Eating
/// Duplicado da gamificação central para independência total do módulo
/// Gerencia estado da UI e interage com services de domínio específicos do Binge Eating
class BingeEatingGamificationController extends ChangeNotifier {
  final BingeEatingGamificationRepository _repository;
  final AuthService _authService;
  
  BingeEatingModuleState? _moduleState;
  bool _isLoading = false;
  String? _error;

  BingeEatingGamificationController({
    required BingeEatingGamificationRepository repository,
    required AuthService authService,
  }) : _repository = repository, _authService = authService;

  // Getters públicos
  BingeEatingModuleState? get moduleState => _moduleState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Getters derivados do estado
  int get currentStreak => _moduleState?.consecutivePositiveDays ?? 0;
  int get disciplinumCount => _moduleState?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => _moduleState?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => _moduleState?.earnedMedalhas ?? [];
  bool get isModuleActive => _moduleState?.isModuleActive ?? false;

  /// Carrega o estado do módulo Binge Eating
  Future<void> loadModuleState() async {
    _setLoading(true);
    _clearError();
    
    try {
      _moduleState = await _repository.performFullSync();
      
      LoggerService.instance.i('Binge Eating module state loaded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4, // Binge Eating niche ID
        habitType: 'state_loaded',
        metadata: {
          'streak': _moduleState!.consecutivePositiveDays,
          'active': _moduleState!.isModuleActive,
          'disciplinum_count': _moduleState!.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error loading Binge Eating module state', error: e, stackTrace: stackTrace);
      _setError('Erro ao carregar estado do módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa dia positivo (sem compulsão)
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

      // Verificar se já teve dia positivo hoje
      final now = DateTime.now();
      final lastUpdated = _moduleState!.lastUpdated;
      if (lastUpdated.year == now.year &&
          lastUpdated.month == now.month &&
          lastUpdated.day == now.day) {
        _setError('Dia positivo já registrado hoje');
        return;
      }

      // Atualizar estado com novo dia positivo
      // NOTA: disciplinumCount é calculado dinamicamente a partir das insígnias conquistadas
      final updatedState = _moduleState!.copyWith(
        consecutivePositiveDays: _moduleState!.consecutivePositiveDays + 1,
      );

      // Salvar estado
      await _repository.saveBingeEatingState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Binge Eating positive day recorded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4,
        habitType: 'positive_day',
        metadata: {
          'streak': updatedState.consecutivePositiveDays,
          'disciplinum_count': updatedState.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Binge Eating positive day', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar dia positivo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa recaída (compulsão alimentar)
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
        consecutivePositiveDays: 0,
      );

      // Salvar estado
      await _repository.saveBingeEatingState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Binge Eating relapse processed');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4,
        habitType: 'relapse',
        metadata: {
          'streak': 0,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Binge Eating relapse', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar recaída');
    } finally {
      _setLoading(false);
    }
  }

  /// Ativa o módulo Binge Eating
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
        _moduleState = BingeEatingModuleState(
          isModuleActive: true,
        );
      } else {
        // Ativar estado existente
        _moduleState = _moduleState!.copyWith(
          isModuleActive: true,
        );
      }

      await _repository.saveBingeEatingState(_moduleState!);
      
      LoggerService.instance.i('Binge Eating module activated');
      
      // Analytics
      await AnalyticsService.instance.trackModuleStarted(
        nicheId: 4,
        source: 'controller',
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error activating Binge Eating module', error: e, stackTrace: stackTrace);
      _setError('Erro ao ativar módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Desativa o módulo Binge Eating
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

        await _repository.saveBingeEatingState(_moduleState!);
      }

      LoggerService.instance.i('Binge Eating module deactivated');
      
      // Analytics - Não há método específico para desativação, usar trackHabitCompleted
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4,
        habitType: 'module_deactivated',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error deactivating Binge Eating module', error: e, stackTrace: stackTrace);
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

      var resetState = BingeEatingModuleState.initial();
      resetState = resetState.copyWith(
        isModuleActive: _moduleState?.isModuleActive ?? false,
      );
      
      await _repository.saveBingeEatingState(resetState);
      _moduleState = resetState;

      LoggerService.instance.w('Binge Eating module progress reset');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 4,
        habitType: 'progress_reset',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error resetting Binge Eating progress', error: e, stackTrace: stackTrace);
      _setError('Erro ao resetar progresso');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém mensagem motivacional baseada no streak atual
  String getStreakMessage() {
    final streak = currentStreak;
    if (streak == 0) return 'Comece sua jornada de controle hoje! 💪';
    if (streak == 1) return '1 dia sem compulsão! Parabéns!';
    if (streak == 3) return '3 dias de controle! Continue assim!';
    if (streak == 7) return '7 dias de controle! Sua força de vontade é impressionante!';
    if (streak == 14) return '14 dias de controle! Você está construindo uma vida saudável!';
    if (streak == 21) return '21 dias de controle! Hábito saudável consolidado!';
    if (streak == 30) return '30 dias de controle! Você é um mestre da disciplina!';
    if (streak == 50) return '50 dias de controle! Sua força de vontade é inspiradora!';
    if (streak == 100) return '100 dias de controle! Você é uma lenda da disciplina!!! Parabéns!';
    if (streak == 365) return '365 dias de controle! Um ano de dedicação! Incrível!';
    
    return '$streak dias de controle! Nada pode te parar!';
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

  /// Limpa o estado da gamificação (usado ao desativar módulo)
  void clearGamification() {
    _moduleState = null;
    notifyListeners();
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
