import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_module_state.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/repositories/spending_gamification_repository.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';

/// Controller de UI para gamificação do Spending
/// Segue o padrão dos outros módulos para independência total
/// Gerencia estado da UI e interage com services de domínio específicos do Spending
class SpendingGamificationController extends ChangeNotifier {
  final SpendingGamificationRepository _repository;
  final AuthService _authService;
  
  SpendingModuleState? _moduleState;
  bool _isLoading = false;
  String? _error;

  SpendingGamificationController({
    required SpendingGamificationRepository repository,
    required AuthService authService,
  }) : _repository = repository, _authService = authService;

  // Getters públicos
  SpendingModuleState? get moduleState => _moduleState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Getters derivados do estado
  int get currentStreak => _moduleState?.consecutiveMonths ?? 0;
  int get disciplinumCount => _moduleState?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => _moduleState?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => _moduleState?.earnedMedalhas ?? [];
  bool get isActive => _moduleState?.isActive ?? false;

  /// Carrega o estado do módulo Spending
  Future<void> loadModuleState() async {
    _setLoading(true);
    _clearError();
    
    try {
      _moduleState = await _repository.performFullSync();
      
      LoggerService.instance.i('Spending module state loaded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5, // Spending niche ID
        habitType: 'state_loaded',
        metadata: {
          'streak': _moduleState!.consecutiveMonths,
          'active': _moduleState!.isActive,
          'disciplinum_count': _moduleState!.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error loading Spending module state', error: e, stackTrace: stackTrace);
      _setError('Erro ao carregar estado do módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa mês com todas as contas pagas
  Future<void> performSuccessfulMonth() async {
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

      // Verificar se já teve check-in este mês
      final now = DateTime.now();
      final lastUpdated = _moduleState!.lastUpdated;
      if (lastUpdated.year == now.year &&
          lastUpdated.month == now.month) {
        _setError('Check-in já registrado este mês');
        return;
      }

      // Atualizar estado com novo mês bem-sucedido
      final updatedState = _moduleState!.copyWith(
        consecutiveMonths: _moduleState!.consecutiveMonths + 1,
        disciplinumCount: _moduleState!.disciplinumCount + 1,
        lastUpdated: DateTime.now(),
      );

      // Salvar estado
      await _repository.saveSpendingState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Spending successful month recorded');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5,
        habitType: 'successful_month',
        metadata: {
          'streak': updatedState.consecutiveMonths,
          'disciplinum_count': updatedState.disciplinumCount,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Spending successful month', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar mês bem-sucedido');
    } finally {
      _setLoading(false);
    }
  }

  /// Processa mês com contas em atraso
  Future<void> performFailedMonth() async {
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

      // Resetar streak em caso de falha
      final updatedState = _moduleState!.copyWith(
        consecutiveMonths: 0,
        lastUpdated: DateTime.now(),
      );

      // Salvar estado
      await _repository.saveSpendingState(updatedState);
      _moduleState = updatedState;

      LoggerService.instance.i('Spending failed month processed');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5,
        habitType: 'failed_month',
        metadata: {
          'streak': 0,
        },
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error performing Spending failed month', error: e, stackTrace: stackTrace);
      _setError('Erro ao registrar mês falhado');
    } finally {
      _setLoading(false);
    }
  }

  /// Ativa o módulo Spending
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
        _moduleState = SpendingModuleState(
          earnedInsignias: const [],
          earnedMedalhas: const [],
          consecutiveMonths: 0,
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

      await _repository.saveSpendingState(_moduleState!);
      
      LoggerService.instance.i('Spending module activated');
      
      // Analytics
      await AnalyticsService.instance.trackModuleStarted(
        nicheId: 5,
        source: 'controller',
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error activating Spending module', error: e, stackTrace: stackTrace);
      _setError('Erro ao ativar módulo');
    } finally {
      _setLoading(false);
    }
  }

  /// Desativa o módulo Spending
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

        await _repository.saveSpendingState(_moduleState!);
      }

      LoggerService.instance.i('Spending module deactivated');
      
      // Analytics - Não há método específico para desativação, usar trackHabitCompleted
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5,
        habitType: 'module_deactivated',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error deactivating Spending module', error: e, stackTrace: stackTrace);
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

      final resetState = SpendingModuleState.initial();
      
      await _repository.saveSpendingState(resetState);
      _moduleState = resetState;

      LoggerService.instance.w('Spending module progress reset');
      
      // Analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: 5,
        habitType: 'progress_reset',
        metadata: {'user_id': userId},
      );
      
    } catch (e, stackTrace) {
      LoggerService.instance.e('Error resetting Spending progress', error: e, stackTrace: stackTrace);
      _setError('Erro ao resetar progresso');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém mensagem motivacional baseada no streak atual
  String getStreakMessage() {
    final streak = currentStreak;
    if (streak == 0) return 'Comece sua jornada de controle financeiro hoje! 💪';
    if (streak == 1) return '1 mês com contas em dia! Parabéns!';
    if (streak == 2) return '2 meses com contas em dia! Continue assim!';
    if (streak == 3) return '3 meses com contas em dia! Sua disciplina é impressionante!';
    if (streak == 4) return '4 meses com contas em dia! Você está construindo estabilidade!';
    if (streak == 6) return '6 meses com contas em dia! Quase na medalha de Bronze!';
    if (streak == 8) return '8 meses com contas em dia! Medalha de Bronze conquistada!';
    if (streak == 10) return '10 meses com contas em dia! Quase na medalha de Prata!';
    if (streak == 12) return '12 meses com contas em dia! Medalha de Prata conquistada!';
    
    return '$streak meses com contas em dia! Nada pode te parar!';
  }

  /// Verifica se alcançou milestone
  bool reachedMilestone() {
    const milestones = [1, 2, 3, 4, 6, 8, 10, 12];
    return milestones.contains(currentStreak);
  }

  /// Obtém próximo milestone
  int getNextMilestone() {
    const milestones = [1, 2, 3, 4, 6, 8, 10, 12];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    
    // Se passou todos os milestones, próximo é a cada 12 meses
    return ((currentStreak ~/ 12) + 1) * 12;
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
