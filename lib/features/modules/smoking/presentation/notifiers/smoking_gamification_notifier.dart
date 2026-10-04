import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_insignia.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_medal.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_celebration_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_checkin_service.dart';
import 'package:disciplinum/features/streaks/domain/services/streak_calculator.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/di/providers.dart'
    show cloudSyncServiceProvider, smokingServiceProvider, smokingCheckinServiceProvider;

/// Estado da gamificação do Smoking
class SmokingGamificationState {
  final SmokingModuleState? gamification;
  final bool isLoading;
  final String? error;
  final bool isModuleActive;

  const SmokingGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
    this.isModuleActive = false,
  });

  SmokingGamificationState copyWith({
    SmokingModuleState? gamification,
    bool? isLoading,
    String? error,
    bool? isModuleActive,
  }) {
    return SmokingGamificationState(
      gamification: gamification ?? this.gamification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModuleActive: isModuleActive ?? this.isModuleActive,
    );
  }

  int get currentStreak => gamification?.consecutivePositiveDays ?? 0;
  int get disciplinumCount => gamification?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => gamification?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => gamification?.earnedMedalhas ?? [];
  DateTime? get lastUpdated => gamification?.lastUpdated;
}

/// Notifier para gamificação do Smoking - Plugin independente
class SmokingGamificationNotifier extends StateNotifier<SmokingGamificationState> {
  final SmokingGamificationRepository _repository;
  final CloudSyncService _cloudSync;
  final SmokingService _smokingService;
  final SmokingCheckinService _checkinService;

  SmokingGamificationNotifier(
    this._repository, 
    this._cloudSync,
    this._smokingService,
    this._checkinService,
  ) : super(const SmokingGamificationState()) {
    LoggerService.instance.gamification('🎲 SmokingGamificationNotifier criado!');
    _registerEventListeners();
    _loadOnInit();
  }

  void _registerEventListeners() {
    EventBus.instance.listen<ModuleCheckInEvent>((event) {
      if (event.nicheId == NicheId.smoking.index) {
        if (event.isPositive) {
          loadGamification();
        } else {
          handleRelapse();
        }
      }
    });

    EventBus.instance.listen<SmokingRelapseEvent>((event) {
      handleRelapse();
    });
  }
  
  Future<void> _loadOnInit() async {
    await loadGamification();
  }

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      LoggerService.instance.gamification('🔄 loadGamification iniciado');
      final gamification = await _repository.getSmokingState();
      LoggerService.instance.gamification(
          '📦 ObjectBox: isModuleActive=${gamification?.isModuleActive}, dailyCost=${gamification?.dailyCost}, consecutiveDays=${gamification?.consecutivePositiveDays}');
      
      if (gamification != null) {
        SmokingModuleState effectiveGamification = gamification;
        
        // Se o módulo está ativo, calcula o streak atual e concede insígnias devidas
        if (effectiveGamification.isModuleActive) {
          bool stateChanged = false;
          
          // 1. Assegura startDate
          if (effectiveGamification.startDate == null) {
            final settings = await _smokingService.getSettings();
            final quitDate = settings?.quitDate ?? settings?.startDate;
            if (quitDate != null) {
              effectiveGamification = effectiveGamification.copyWith(startDate: quitDate);
              stateChanged = true;
            } else {
              effectiveGamification = effectiveGamification.copyWith(startDate: effectiveGamification.createdAt);
              stateChanged = true;
            }
          }
          
          // 2. Garante a insígnia Madeira (ganha ao ativar o módulo)
          final currentInsignias = List<String>.from(effectiveGamification.earnedInsignias);
          if (!currentInsignias.contains('madeira')) {
            currentInsignias.add('madeira');
            stateChanged = true;
            LoggerService.instance.gamification('🪵 Insígnia Madeira auto-recuperada');
            SmokingCelebrationService.instance.celebrarInsigniaConquistada(
              insigniaId: SmokingInsigniaEntity.madeira.name,
              insigniaName: SmokingInsigniaEntity.madeira.nameBr,
              insigniaDescription: SmokingInsigniaEntity.madeira.requirementDescription,
              assetPath: SmokingInsigniaEntity.madeira.asset,
            );
          }
          
          // 3. Calcula o streak de abstenção (dias sem fumar)
          final effectiveStart = effectiveGamification.startDate ?? effectiveGamification.createdAt;
          final abstinenceDays = StreakCalculator.instance.calculateAbstinenceStreak(
            activationDate: effectiveStart,
            lastRelapseDate: effectiveGamification.lastPositiveCheckIn != null &&
                    effectiveGamification.lastPositiveCheckIn!.isAfter(effectiveStart)
                ? effectiveGamification.lastPositiveCheckIn
                : null,
          );
          
          // Verifica se há check-ins registrados que indiquem streak
          int checkinStreak = 0;
          try {
            final checkins = await _checkinService.loadCheckins();
            checkinStreak = _checkinService.calculateConsecutiveDays(checkins);
          } catch (_) {}
          
          final calculatedDays = abstinenceDays > checkinStreak ? abstinenceDays : checkinStreak;
          
          if (calculatedDays != effectiveGamification.consecutivePositiveDays) {
            effectiveGamification = effectiveGamification.copyWith(
              consecutivePositiveDays: calculatedDays,
            );
            stateChanged = true;
          }
          
          // 4. Concede insígnias desbloqueadas por dias sem fumar
          for (final insignia in SmokingInsigniaEntity.values) {
            if (insignia == SmokingInsigniaEntity.madeira) continue;
            if (calculatedDays >= insignia.requiredDays && !currentInsignias.contains(insignia.name)) {
              currentInsignias.add(insignia.name);
              stateChanged = true;
              
              SmokingCelebrationService.instance.celebrarInsigniaConquistada(
                insigniaId: insignia.name,
                insigniaName: insignia.nameBr,
                insigniaDescription: insignia.requirementDescription,
                assetPath: insignia.asset,
              );
              LoggerService.instance.gamification(
                  '🎉 Insígnia ${insignia.nameBr} conquistada ($calculatedDays dias sem fumar)!');
            }
          }
          
          // 5. Calcula Disciplinum count e concede medalhas
          int disciplinumCount = effectiveGamification.disciplinumCount;
          if (currentInsignias.contains(SmokingInsigniaEntity.disciplinum.name)) {
            final cycleCount = (calculatedDays ~/ 30).clamp(1, 999);
            if (cycleCount > disciplinumCount) {
              disciplinumCount = cycleCount;
              stateChanged = true;
            }
          }
          
          final currentMedalhas = List<String>.from(effectiveGamification.earnedMedalhas);
          for (final medalha in SmokingMedalEntity.values) {
            if (medalha.canBeAwarded(currentInsignias) && !currentMedalhas.contains(medalha.name)) {
              currentMedalhas.add(medalha.name);
              stateChanged = true;
              
              SmokingCelebrationService.instance.celebrarMedalhaConquistada(
                medalhaId: medalha.name,
                medalhaName: medalha.nameBr,
                medalhaDescription: medalha.benefitDescription,
                assetPath: medalha.asset,
              );
              LoggerService.instance.gamification('🏅 Medalha ${medalha.nameBr} conquistada!');
            }
          }
          
          if (stateChanged) {
            effectiveGamification = effectiveGamification.copyWith(
              earnedInsignias: currentInsignias,
              earnedMedalhas: currentMedalhas,
              disciplinumCount: disciplinumCount,
            );
            await _repository.saveSmokingState(effectiveGamification);
            LoggerService.instance.gamification(
                '✅ Estado Smoking atualizado e salvo: dias=$calculatedDays, insignias=$currentInsignias');
          }
        }
        
        state = state.copyWith(
          gamification: effectiveGamification,
          isLoading: false,
          isModuleActive: effectiveGamification.isModuleActive,
        );
        LoggerService.instance.gamification(
            '✅ Estado carregado do ObjectBox: isModuleActive=${effectiveGamification.isModuleActive}, dailyCost=${effectiveGamification.dailyCost}, streak=${effectiveGamification.consecutivePositiveDays}, insignias=${effectiveGamification.earnedInsignias}');
      } else {
        state = state.copyWith(
          gamification: null,
          isLoading: false,
          isModuleActive: false,
        );
        LoggerService.instance.gamification('⏳ Nenhum estado encontrado. Aguardando ativação.');
      }
    } catch (e) {
      LoggerService.instance.e('❌ Erro no loadGamification', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Recarrega estado do cloud após sincronização
  Future<void> reloadFromCloud() async {
    LoggerService.instance.gamification('🔄 reloadFromCloud chamado após sync');
    await loadGamification();
  }

  /// Ativa o módulo (cria estado inicial)
  Future<void> activateModule({
    double dailyCost = 0.0, 
    double packCost = 0.0,
    DateTime? startDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.forceResetToActive(dailyCost: dailyCost, packCost: packCost);
      
      final effectiveStart = startDate ?? DateTime.now();
      final streak = StreakCalculator.instance.calculateAbstinenceStreak(activationDate: effectiveStart);
      
      final initialInsignias = <String>['madeira'];
      for (final insignia in SmokingInsigniaEntity.values) {
        if (insignia == SmokingInsigniaEntity.madeira) continue;
        if (streak >= insignia.requiredDays) {
          initialInsignias.add(insignia.name);
        }
      }
      
      int initialDisciplinumCount = 0;
      if (initialInsignias.contains(SmokingInsigniaEntity.disciplinum.name)) {
        initialDisciplinumCount = (streak ~/ 30).clamp(1, 999);
      }
      
      final initialMedalhas = <String>[];
      for (final medalha in SmokingMedalEntity.values) {
        if (medalha.canBeAwarded(initialInsignias)) {
          initialMedalhas.add(medalha.name);
        }
      }
      
      final initialState = SmokingModuleState.initial().copyWith(
        isModuleActive: true,
        dailyCost: dailyCost,
        packCost: packCost,
        startDate: effectiveStart,
        consecutivePositiveDays: streak,
        earnedInsignias: initialInsignias,
        earnedMedalhas: initialMedalhas,
        disciplinumCount: initialDisciplinumCount,
      );

      await _repository.saveSmokingState(initialState);
      
      // Celebra Madeira
      await SmokingCelebrationService.instance.celebrarInsigniaConquistada(
        insigniaId: SmokingInsigniaEntity.madeira.name,
        insigniaName: SmokingInsigniaEntity.madeira.nameBr,
        insigniaDescription: SmokingInsigniaEntity.madeira.requirementDescription,
        assetPath: SmokingInsigniaEntity.madeira.asset,
      );
      
      // Se já alcançou outras insígnias imediatamente (caso startDate seja no passado):
      for (final insigniaName in initialInsignias) {
        if (insigniaName == 'madeira') continue;
        final ins = SmokingInsigniaEntity.values.firstWhere((i) => i.name == insigniaName);
        await SmokingCelebrationService.instance.celebrarInsigniaConquistada(
          insigniaId: ins.name,
          insigniaName: ins.nameBr,
          insigniaDescription: ins.requirementDescription,
          assetPath: ins.asset,
        );
      }
      
      await _cloudSync.saveModuleStatus(
        nicheId: NicheId.smoking,
        isModuleActive: true,
      );
      LoggerService.instance.gamification('☁️ user_module_status atualizado: is_active=true');
      
      state = state.copyWith(
        gamification: initialState,
        isLoading: false,
        isModuleActive: true,
      );
      LoggerService.instance.gamification(
          '✅ Módulo ativado: isModuleActive=true, dailyCost=$dailyCost, packCost=$packCost, streak=$streak, insignias=$initialInsignias');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Desativa o módulo (limpa dados)
  /// Mantém apenas a insígnia Madeira, remove todas as outras insígnias e medalhas
  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      LoggerService.instance.gamification('🛑 deactivateModule chamado - resetando progresso mantendo apenas Madeira');
      final current = state.gamification;
      SmokingModuleState? updated;
      if (current != null) {
        // Preserva apenas a insígnia Madeira, remove todas as outras e zera medalhas
        final hasMadeira = current.earnedInsignias.contains('madeira');
        
        updated = current.copyWith(
          isModuleActive: false,
          earnedInsignias: hasMadeira ? ['madeira'] : [], // Mantém só Madeira
          earnedMedalhas: [], // Zera medalhas
          consecutivePositiveDays: 0,
          disciplinumCount: 0,
        );
        
        await _repository.saveSmokingState(updated);
        LoggerService.instance.gamification('🛑 Progresso resetado: mantida apenas Madeira=$hasMadeira, medalhas zeradas');
      }
      
      await _cloudSync.saveModuleStatus(
        nicheId: NicheId.smoking,
        isModuleActive: false,
      );
      LoggerService.instance.gamification('☁️ user_module_status atualizado: is_active=false');
      
      // Preserva o estado com a insígnia Madeira em memória
      state = state.copyWith(
        gamification: updated,
        isModuleActive: false, 
        isLoading: false,
      );
      LoggerService.instance.gamification('🛑 Módulo desativado e progresso resetado (Madeira mantida)');
    } catch (e) {
      LoggerService.instance.e('❌ Erro em deactivateModule', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Processa recaída (reinicia streak e zera estatísticas do módulo, mantendo Madeira)
  Future<void> handleRelapse() async {
    try {
      LoggerService.instance.gamification('⚠️ handleRelapse chamado');
      final current = state.gamification ?? await _repository.getSmokingState();
      if (current != null && current.isModuleActive) {
        final hasMadeira = current.earnedInsignias.contains('madeira');
        final now = DateTime.now();

        // 1. Zera check-ins registrados (local e nuvem)
        await _checkinService.clearAllCheckins();

        // 2. Arquiva e reseta as estatísticas do módulo (tempo sem fumar, economia, cigarros evitados iniciam de agora)
        await _smokingService.archiveAndReset();
        
        final updated = current.copyWith(
          startDate: now,
          lastPositiveCheckIn: now,
          consecutivePositiveDays: 0,
          earnedInsignias: hasMadeira ? ['madeira'] : [],
          earnedMedalhas: [],
          disciplinumCount: 0,
        );
        
        await _repository.saveSmokingState(updated);
        state = state.copyWith(gamification: updated);
        LoggerService.instance.gamification('🔄 Relapse processado: streak resetado para 0, estatísticas zeradas, Madeira preservada');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao processar relapse no Smoking', error: e);
    }
  }

  Future<void> resetProgress() async {
    try {
      LoggerService.instance.gamification('🔄 resetProgress chamado - limpando e resetando progresso');
      final current = state.gamification;
      final hasMadeira = current?.earnedInsignias.contains('madeira') ?? false;
      final wasActive = current?.isModuleActive ?? false;
      final dailyCost = current?.dailyCost ?? 0.0;
      final packCost = current?.packCost ?? 0.0;

      LoggerService.instance.gamification('🔄 Preservando: isModuleActive=$wasActive, dailyCost=$dailyCost, hasMadeira=$hasMadeira');
      
      // Zera check-ins e estatísticas de consumo
      await _checkinService.clearAllCheckins();
      await _smokingService.archiveAndReset();

      await _repository.clearSmokingState();
      
      final initialState = SmokingModuleState.initial().copyWith(
        isModuleActive: wasActive,  // PRESERVA o status ativo!
        dailyCost: dailyCost,       // PRESERVA o custo diário!
        packCost: packCost,         // PRESERVA o custo do maço!
        startDate: DateTime.now(),  // Reinicia contagem a partir de agora!
        earnedInsignias: hasMadeira ? ['madeira'] : [], // Mantém só Madeira
        earnedMedalhas: [],         // ZERA medalhas
        disciplinumCount: 0,        // ZERA contador
        consecutivePositiveDays: 0, // ZERA streak
      );
      
      await _repository.saveSmokingState(initialState);
      
      LoggerService.instance.gamification('✅ Progresso resetado mantendo Madeira=$hasMadeira, medalhas zeradas, isModuleActive=$wasActive');
      
      await loadGamification();
    } catch (e) {
      LoggerService.instance.e('❌ Erro em resetProgress', error: e);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Salva mensagens customizadas para um nicho específico
  Future<void> setCustomMessages(String nicheId, List<String> messages) async {
    try {
      final current = state.gamification;
      if (current == null) {
        LoggerService.instance.gamification('⚠️ setCustomMessages: gamification é null, pulando save');
        return;
      }
      
      final updatedMessages = Map<String, List<String>>.from(current.customMessages);
      updatedMessages[nicheId] = messages;
      
      final updated = current.copyWith(
        customMessages: updatedMessages,
      );
      
      await _repository.saveSmokingState(updated);
      await loadGamification();
    } catch (e) {
      LoggerService.instance.e('❌ Erro em setCustomMessages', error: e);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Define a mensagem principal customizada
  Future<void> setCustomMainMessage(String message) async {
    try {
      final current = state.gamification;
      if (current == null) {
        LoggerService.instance.gamification('⚠️ setCustomMainMessage: gamification é null, pulando save');
        return;
      }
      
      final updated = current.copyWith(
        customMainMessage: message,
      );
      
      await _repository.saveSmokingState(updated);
      await loadGamification();
    } catch (e) {
      LoggerService.instance.e('❌ Erro em setCustomMainMessage', error: e);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Recarrega sessões de monitoramento ativas
  Future<void> reloadMonitoringSessions() async {
    try {
      await loadGamification();
      LoggerService.instance.i('Sessões de monitoramento recarregadas');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

/// Provider do Notifier
final smokingGamificationNotifierProvider = StateNotifierProvider<
  SmokingGamificationNotifier,
  SmokingGamificationState
>((ref) {
  return SmokingGamificationNotifier(
    SmokingGamificationRepository.instance,
    ref.read(cloudSyncServiceProvider),
    ref.read(smokingServiceProvider),
    ref.read(smokingCheckinServiceProvider),
  );
});

/// Provider conveniente
final smokingGamificationStateProvider = Provider<AsyncValue<SmokingGamificationState>>((ref) {
  final state = ref.watch(smokingGamificationNotifierProvider);
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});
