import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/gamification/domain/entities/module_state.dart';
import 'package:disciplinum/features/gamification/domain/services/streak_service.dart';
import 'package:disciplinum/infrastructure/repositories/module_repository.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';

/// Controller de UI para gamificação
/// Gerencia estado da UI e interage com services de domínio
class GamificationController extends ChangeNotifier {
  final ModuleRepository _moduleRepository;
  
  // Estado privado
  Map<int, ModuleState> _moduleStates = {};
  bool _isLoading = false;
  String? _error;
  
  // Getters públicos
  Map<int, ModuleState> get moduleStates => Map.unmodifiable(_moduleStates);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Estatísticas globais
  int get totalActiveModules => _moduleStates.values.where((state) => state.isActive).length;
  int get longestStreak => _moduleStates.values.isEmpty ? 0 : 
      _moduleStates.values.map((state) => state.consecutiveDays).reduce((a, b) => a > b ? a : b);
  int get totalXp => _moduleStates.values.fold(0, (sum, state) => sum + state.currentXp);
  double get averageSuccessRate {
    if (_moduleStates.isEmpty) return 0.0;
    final totalRate = _moduleStates.values.fold(0.0, (sum, state) => sum + state.successRate);
    return totalRate / _moduleStates.length;
  }

  GamificationController({
    required ModuleRepository moduleRepository,
  }) : _moduleRepository = moduleRepository;

  /// Carrega todos os estados dos módulos
  Future<void> loadModuleStates() async {
    _setLoading(true);
    _clearError();
    
    try {
      LoggerService.instance.d('Loading module states...');
      
      final modules = await _moduleRepository.getActiveModules();
      final states = <int, ModuleState>{};
      
      for (final module in modules) {
        final state = ModuleState.fromUserModuleStatus(module);
        states[module.nicheId] = state;
      }
      
      _moduleStates = states;
      
      LoggerService.instance.i('Loaded ${states.length} module states');
      await AnalyticsService.instance.trackEngagement(
        action: 'gamification_loaded',
        context: {'modules_loaded': states.length},
      );
      
    } catch (e) {
      _setError('Failed to load module states: $e');
      LoggerService.instance.e('Failed to load module states', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Processa check-in para um módulo
  Future<bool> processCheckIn(int nicheId) async {
    final currentState = _moduleStates[nicheId];
    if (currentState == null) {
      _setError('Module $nicheId not found');
      return false;
    }
    
    try {
      LoggerService.instance.d('Processing check-in for module $nicheId');
      
      // Atualizar estado com novo check-in
      final updatedState = StreakService.updateStreakState(
        currentState: currentState,
        didCheckInToday: true,
        hadRelapseToday: false,
      );
      
      // Salvar estado atualizado
      await _saveModuleState(updatedState);
      
      // Track analytics
      await AnalyticsService.instance.trackHabitCompleted(
        nicheId: nicheId,
        habitType: 'daily_checkin',
        metadata: {
          'streak': updatedState.consecutiveDays,
          'total_checkins': updatedState.totalCheckIns,
        },
      );
      
      // Verificar milestones
      if (StreakService.reachedMilestone(updatedState.consecutiveDays)) {
        await _handleStreakMilestone(updatedState);
      }
      
      LoggerService.instance.i('Check-in processed successfully for module $nicheId');
      return true;
      
    } catch (e) {
      _setError('Failed to process check-in: $e');
      LoggerService.instance.e('Failed to process check-in for module $nicheId', error: e);
      return false;
    }
  }

  /// Processa recaída para um módulo
  Future<bool> processRelapse(int nicheId, {String? reason}) async {
    final currentState = _moduleStates[nicheId];
    if (currentState == null) {
      _setError('Module $nicheId not found');
      return false;
    }
    
    try {
      LoggerService.instance.w('Processing relapse for module $nicheId', 
         error: reason);
      
      // Atualizar estado com recaída
      final updatedState = StreakService.updateStreakState(
        currentState: currentState,
        didCheckInToday: false,
        hadRelapseToday: true,
      );
      
      // Salvar estado atualizado
      await _saveModuleState(updatedState);
      
      // Track analytics
      await AnalyticsService.instance.trackRelapse(
        nicheId: nicheId,
        reason: reason ?? 'unknown',
        context: {
          'previous_streak': currentState.consecutiveDays,
          'total_relapses': updatedState.totalRelapses,
        },
      );
      
      LoggerService.instance.w('Relapse processed for module $nicheId');
      return true;
      
    } catch (e) {
      _setError('Failed to process relapse: $e');
      LoggerService.instance.e('Failed to process relapse for module $nicheId', error: e);
      return false;
    }
  }

  /// Adiciona XP a um módulo
  Future<bool> addXp(int nicheId, int xpAmount, {String? reason}) async {
    final currentState = _moduleStates[nicheId];
    if (currentState == null) {
      _setError('Module $nicheId not found');
      return false;
    }
    
    try {
      final updatedState = currentState.copyWith(
        currentXp: currentState.currentXp + xpAmount,
        lastUpdated: DateTime.now(),
      );
      
      await _saveModuleState(updatedState);
      
      // Track analytics
      await AnalyticsService.instance.trackAchievement(
        nicheId: nicheId,
        achievementType: 'xp_earned',
        achievementName: 'XP Gained',
        achievementData: {
          'xp_amount': xpAmount,
          'reason': reason ?? 'unknown',
          'total_xp': updatedState.currentXp,
        },
      );
      
      LoggerService.instance.i('Added $xpAmount XP to module $nicheId');
      return true;
      
    } catch (e) {
      _setError('Failed to add XP: $e');
      LoggerService.instance.e('Failed to add XP to module $nicheId', error: e);
      return false;
    }
  }

  /// Adiciona insígnia a um módulo
  Future<bool> addInsignia(int nicheId, String insigniaName) async {
    final currentState = _moduleStates[nicheId];
    if (currentState == null) {
      _setError('Module $nicheId not found');
      return false;
    }
    
    if (currentState.earnedInsignias.contains(insigniaName)) {
      LoggerService.instance.w('Insignia $insigniaName already earned for module $nicheId');
      return true;
    }
    
    try {
      final updatedInsignias = [...currentState.earnedInsignias, insigniaName];
      final updatedState = currentState.copyWith(
        earnedInsignias: updatedInsignias,
        lastUpdated: DateTime.now(),
      );
      
      await _saveModuleState(updatedState);
      
      // Track analytics
      await AnalyticsService.instance.trackAchievement(
        nicheId: nicheId,
        achievementType: 'insignia_earned',
        achievementName: insigniaName,
        achievementData: {
          'total_insignias': updatedInsignias.length,
        },
      );
      
      LoggerService.instance.i('Insignia $insigniaName earned for module $nicheId');
      return true;
      
    } catch (e) {
      _setError('Failed to add insignia: $e');
      LoggerService.instance.e('Failed to add insignia to module $nicheId', error: e);
      return false;
    }
  }

  /// Atualiza medalha máxima de um módulo
  Future<bool> updateMaxMedal(int nicheId, String medalName) async {
    final currentState = _moduleStates[nicheId];
    if (currentState == null) {
      _setError('Module $nicheId not found');
      return false;
    }
    
    try {
      final updatedState = currentState.copyWith(
        maxMedal: medalName,
        lastUpdated: DateTime.now(),
      );
      
      await _saveModuleState(updatedState);
      
      // Track analytics
      await AnalyticsService.instance.trackAchievement(
        nicheId: nicheId,
        achievementType: 'medal_earned',
        achievementName: medalName,
        achievementData: {
          'previous_medal': currentState.maxMedal,
        },
      );
      
      LoggerService.instance.i('Medal updated to $medalName for module $nicheId');
      return true;
      
    } catch (e) {
      _setError('Failed to update medal: $e');
      LoggerService.instance.e('Failed to update medal for module $nicheId', error: e);
      return false;
    }
  }

  /// Sincroniza estados com o cloud
  Future<void> syncWithCloud() async {
    _setLoading(true);
    _clearError();
    
    try {
      LoggerService.instance.d('Syncing module states with cloud...');
      
      await _moduleRepository.syncWithCloud();
      await loadModuleStates(); // Recarregar após sync
      
      LoggerService.instance.i('Cloud sync completed');
      
    } catch (e) {
      _setError('Failed to sync with cloud: $e');
      LoggerService.instance.e('Failed to sync with cloud', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém estado de um módulo específico
  ModuleState? getModuleState(int nicheId) {
    return _moduleStates[nicheId];
  }

  /// Verifica se módulo precisa de check-in hoje
  bool needsCheckInToday(int nicheId) {
    final state = _moduleStates[nicheId];
    return state?.needsCheckInToday ?? false;
  }

  /// Obtém mensagem motivacional para um módulo
  String getStreakMessage(int nicheId) {
    final state = _moduleStates[nicheId];
    if (state == null) return 'Comece sua jornada! 💪';
    
    return StreakService.getStreakMessage(state.consecutiveDays);
  }

  /// Métodos privados
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

  Future<void> _saveModuleState(ModuleState state) async {
    // Obter userId do AuthService
    final authService = AuthService();
    final userId = authService.currentUser?.id ?? 'temp_user';
    
    final userModuleStatus = state.toUserModuleStatus(userId: userId);
    await _moduleRepository.saveModuleStatus(userModuleStatus);
    
    // Atualizar estado local
    _moduleStates[state.nicheId] = state;
    notifyListeners();
  }

  Future<void> _handleStreakMilestone(ModuleState state) async {
    final milestone = state.consecutiveDays;
    final message = StreakService.getStreakMessage(milestone);
    
    // Track milestone achievement
    await AnalyticsService.instance.trackAchievement(
      nicheId: state.nicheId,
      achievementType: 'streak_milestone',
      achievementName: '$milestone days streak',
      achievementData: {
        'milestone': milestone,
        'message': message,
      },
    );
    
    LoggerService.instance.i('Streak milestone reached: $milestone days for module ${state.nicheId}');
    
    // Mostrar notificação ou celebração de UI
    _showStreakCelebration(milestone, state);
  }

  /// Mostra celebração quando usuário atinge marco de streak
  void _showStreakCelebration(int milestone, ModuleState state) {
    // Aqui poderia ser implementado:
    // - Notificação local
    // - Dialog de celebração
    // - Confete na tela
    // - Som de vitória
    // Por enquanto, apenas logamos o evento
    LoggerService.instance.i('🎉 Celebration triggered for $milestone days streak!');
  }
}
