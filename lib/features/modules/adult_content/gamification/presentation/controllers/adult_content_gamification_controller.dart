import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/entities/adult_content_module_state.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/repositories/adult_content_gamification_repository.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';

/// Controller de UI para gamificação do Adult Content
/// Duplicado da gamificação central para independência total do módulo
/// Gerencia estado da UI e interage com services de domínio específicos do Adult Content
class AdultContentGamificationController extends ChangeNotifier {
  final AdultContentGamificationRepository _repository;
  final AuthService _authService;
  
  AdultContentModuleState? _moduleState;
  bool _isLoading = false;
  String? _error;

  AdultContentGamificationController({
    required AdultContentGamificationRepository repository,
    required AuthService authService,
  }) : _repository = repository, _authService = authService;

  // Getters públicos
  AdultContentModuleState? get moduleState => _moduleState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Getters derivados do estado
  int get currentStreak => _moduleState?.consecutiveDays ?? 0;
  int get disciplinumCount => _moduleState?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => _moduleState?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => _moduleState?.earnedMedalhas ?? [];
  bool get isActive => _moduleState?.isActive ?? false;

  /// Carrega o estado do módulo Adult Content
  Future<void> loadModuleState() async {
    _setLoading(true);
    _clearError();
    
    try {
      _moduleState = await _repository.performFullSync();
      
      LoggerService.instance.i('Adult Content module state loaded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5, // Adult Content niche ID
        habitType: 'state_loaded',
        metadata: {
          'streak': _moduleState!.consecutiveDays,
          'active': _moduleState!.isActive,
          'disciplinum_count': _moduleState!.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error loading Adult Content module state', error: e, stackTrace: stackTrace);
      _setError('Erro ao carregar estado do módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa dia livre (sem conteúdo adulto)
  Future<void> performFreeDay() async {
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

      // Verificar se já teve dia livre hoje
      final now = DateTime.now();
      final lastUpdated = _moduleState!.lastUpdated;
      if (lastUpdated.year == now.year &&
          lastUpdated.month == now.month &&
          lastUpdated.day == now.day) {
        _setError('Dia livre já registrado hoje');
        return;
      }

      // Atualizar estado com novo dia livre
      final updatedState = _moduleState!.copyWith(
        consecutiveDays: _moduleState!.consecutiveDays + 1,
        disciplinumCount: _moduleState!.disciplinumCount + 1,
        lastUpdated: DateTime.now(),
      );

      // Salvar estado
      await _repository.saveAdultContentState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Adult Content free day recorded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5,
        habitType: 'free_day',
        metadata: {
          'streak': updatedState.consecutiveDays,
          'disciplinum_count': updatedState.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Adult Content free day', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar dia livre');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa recaída (acesso a conteúdo adulto)
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
        lastUpdated: DateTime.now(),
      );

      // Salvar estado
      await _repository.saveAdultContentState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Adult Content relapse processed');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5,
        habitType: 'relapse',
        metadata: {
          'streak': 0,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Adult Content relapse', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar recaída');
    } finally {
      _setLoading(false);
    }
  }

  /// Ativa o módulo Adult Content
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
        _moduleState = AdultContentModuleState(
          isActive: true,
          lastUpdated: DateTime.now(),
        );
      } else {
        // Ativar estado existente
        _moduleState = _moduleState!.copyWith(
          isActive: true,
          lastUpdated: DateTime.now(),
        );
      }

      await _repository.saveAdultContentState(_moduleState!);
      
      LoggerService.instance.i('Adult Content module activated');
      
      // Analytics
      await AnalyticsService.instance.trackModuleStarted(
        nicheId: 5,
        source: 'controller',
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error activating Adult Content module', error: e, stackTrace: stackTrace);
      _setError('Erro ao ativar módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Desativa o módulo Adult Content
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

        await _repository.saveAdultContentState(_moduleState!);
      }

      LoggerService.instance.i('Adult Content module deactivated');
      
      // Analytics - Não há método específico para desativação, usar trackHabitCompleted
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5,
        habitType: 'module_deactivated',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error deactivating Adult Content module', error: e, stackTrace: stackTrace);
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

      var resetState = AdultContentModuleState.initial();
      resetState = resetState.copyWith(
        isActive: _moduleState?.isActive ?? false,
      );
      
      await _repository.saveAdultContentState(resetState);
      _moduleState = resetState;

      LoggerService.instance.w('Adult Content module progress reset');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5,
        habitType: 'progress_reset',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error resetting Adult Content progress', error: e, stackTrace: stackTrace);
      _setError('Erro ao resetar progresso');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém mensagem motivacional baseada no streak atual
  String getStreakMessage() {
    final streak = currentStreak;
    if (streak == 0) return 'Comece sua jornada de disciplina hoje! 💪';
    if (streak == 1) return '1 dia livre! Parabéns!';
    if (streak == 3) return '3 dias livres! Continue assim!';
    if (streak == 7) return '7 dias livres! Sua força de vontade é impressionante!';
    if (streak == 14) return '14 dias livres! Você está construindo uma vida melhor!';
    if (streak == 21) return '21 dias livres! Hábito de disciplina consolidado!';
    if (streak == 30) return '30 dias livres! Você é um mestre da disciplina!';
    if (streak == 50) return '50 dias livres! Sua força de vontade é inspiradora!';
    if (streak == 100) return '100 dias livres! Você é uma lenda da disciplina!!! Parabéns!';
    if (streak == 365) return '365 dias livres! Um ano de dedicação! Incrível!';
    
    return '$streak dias livres! Nada pode te parar!';
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

  /// Reinicializa o controller
  @override
  void dispose() {
    _moduleState = null;
    _isLoading = false;
    _error = null;
    super.dispose();
  }
}
