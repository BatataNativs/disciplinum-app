import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/entities/digital_detox_gamification_entity.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/repositories/digital_detox_gamification_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/repositories/digital_detox_fasting_break_domain_repository.dart';

// Estado da gamificação do Digital Detox
class DigitalDetoxGamificationState {
  final bool isLoading;
  final String errorMessage;
  final DigitalDetoxGamificationEntity? gamification;
  final List<dynamic> availableBreaks;

  const DigitalDetoxGamificationState({
    required this.gamification,
    this.isLoading = false,
    this.errorMessage = '',
    this.availableBreaks = const [],
  });

  DigitalDetoxGamificationState copyWith({
    bool? isLoading,
    String? errorMessage,
    DigitalDetoxGamificationEntity? gamification,
    List<dynamic>? availableBreaks,
  }) {
    return DigitalDetoxGamificationState(
      gamification: gamification ?? this.gamification,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      availableBreaks: availableBreaks ?? this.availableBreaks,
    );
  }

  DigitalDetoxGamificationState loading() {
    return copyWith(isLoading: true);
  }

  DigitalDetoxGamificationState error(String message) {
    return copyWith(errorMessage: message, isLoading: false);
  }

  DigitalDetoxGamificationState loaded(DigitalDetoxGamificationEntity gamification) {
    return copyWith(gamification: gamification, isLoading: false);
  }
}

// Notifier para gerenciar estado da gamificação
class DigitalDetoxGamificationNotifier extends StateNotifier<DigitalDetoxGamificationState> {
  final DigitalDetoxGamificationRepository _repository;
  final DigitalDetoxFastingBreakRepository _fastingBreakRepository;

  DigitalDetoxGamificationNotifier(this._repository, this._fastingBreakRepository) 
    : super(DigitalDetoxGamificationState(gamification: null, isLoading: false, errorMessage: '', availableBreaks: []));

  // Getters
  DigitalDetoxGamificationEntity? get gamification => state.gamification;
  String get userId => state.gamification?.userId ?? '';

  // Métodos principais
  Future<void> loadGamification(String userId) async {
    state = DigitalDetoxGamificationState(gamification: null, isLoading: true, errorMessage: '', availableBreaks: []);
    try {
      final gamification = _repository.getByUserId(userId);
      if (gamification == null) {
        // Criar nova gamificação se não existir
        final newGamification = DigitalDetoxGamificationEntity(userId: userId);
        await _repository.save(newGamification);
        state = DigitalDetoxGamificationState(gamification: newGamification, isLoading: false, errorMessage: '', availableBreaks: []);
      } else {
        final availableBreaks = _fastingBreakRepository.getActiveForUser(userId);
        state = DigitalDetoxGamificationState(gamification: gamification, isLoading: false, errorMessage: '', availableBreaks: availableBreaks);
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar gamificação: $e');
      state = DigitalDetoxGamificationState(gamification: null, isLoading: false, errorMessage: 'Falha ao carregar dados', availableBreaks: []);
    }
  }

  Future<void> activateModule() async {
    try {
      final currentGamification = state.gamification;
      if (currentGamification == null) return;
      
      final updatedGamification = currentGamification.copyWith(
        isModuleActive: true,
        updatedAt: DateTime.now(),
      );
      
      await _repository.save(updatedGamification);
      
      // Recarregar estado
      await loadGamification(userId);
      
      LoggerService.instance.i('Módulo Digital Detox ativado');
    } catch (e) {
      LoggerService.instance.e('Erro ao ativar módulo: $e');
      state = state.copyWith(errorMessage: 'Falha ao ativar módulo');
    }
  }

  Future<void> deactivateModule() async {
    try {
      final currentGamification = state.gamification;
      if (currentGamification == null) return;
      
      final updatedGamification = currentGamification.copyWith(
        isModuleActive: false,
        updatedAt: DateTime.now(),
      );
      
      await _repository.save(updatedGamification);
      
      // Recarregar estado
      await loadGamification(userId);
      
      LoggerService.instance.i('Módulo Digital Detox desativado');
    } catch (e) {
      LoggerService.instance.e('Erro ao desativar módulo: $e');
      state = state.copyWith(errorMessage: 'Falha ao desativar módulo');
    }
  }

  Future<void> markDayAsValid() async {
    try {
      final currentGamification = state.gamification;
      if (currentGamification == null) return;
      
      final updatedGamification = currentGamification.addDisciplinedDay();
      await _repository.save(updatedGamification);
      
      // Recarregar estado
      await loadGamification(userId);
      
      LoggerService.instance.i('Dia marcado como válido para Digital Detox');
    } catch (e) {
      LoggerService.instance.e('Erro ao marcar dia como válido: $e');
      state = state.copyWith(errorMessage: 'Falha ao marcar dia');
    }
  }

  Future<void> resetStreak() async {
    try {
      final currentGamification = state.gamification;
      if (currentGamification == null) return;
      
      final updatedGamification = currentGamification.resetStreak();
      await _repository.save(updatedGamification);
      
      // Recarregar estado
      await loadGamification(userId);
      
      LoggerService.instance.i('Streak resetado para Digital Detox');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar streak: $e');
      state = state.copyWith(errorMessage: 'Falha ao resetar streak');
    }
  }

  Future<void> useFastingBreak() async {
    try {
      final currentGamification = state.gamification;
      if (currentGamification == null) return;
      
      if (!currentGamification.shouldAwardFastingBreak()) {
        state = state.copyWith(errorMessage: 'Você não tem dias suficientes para uma quebra de jejum');
        return;
      }
      
      final updatedGamification = currentGamification.resetSevenDayCycle();
      await _repository.save(updatedGamification);
      
      // Recarregar estado
      await loadGamification(userId);
      
      LoggerService.instance.i('Quebra de jejum utilizada para Digital Detox');
    } catch (e) {
      LoggerService.instance.e('Erro ao usar quebra de jejum: $e');
      state = state.copyWith(errorMessage: 'Falha ao usar quebra');
    }
  }

  void clearError() {
    if (state.errorMessage.isNotEmpty) {
      state = state.copyWith(errorMessage: '');
    }
  }
}
