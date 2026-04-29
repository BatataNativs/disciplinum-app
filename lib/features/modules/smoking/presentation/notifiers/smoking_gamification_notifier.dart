import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/di/providers.dart' show cloudSyncServiceProvider;

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

  SmokingGamificationNotifier(this._repository, this._cloudSync) 
      : super(const SmokingGamificationState()) {
    LoggerService.instance.gamification('🎲 SmokingGamificationNotifier criado!');
    // Carrega automaticamente ao criar
    _loadOnInit();
  }
  
  Future<void> _loadOnInit() async {
    await loadGamification();
  }

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      LoggerService.instance.gamification('🔄 loadGamification iniciado');
      final gamification = await _repository.getSmokingState();
      LoggerService.instance.gamification('📦 ObjectBox: isModuleActive=${gamification?.isModuleActive}, dailyCost=${gamification?.dailyCost}, consecutiveDays=${gamification?.consecutivePositiveDays}');
      
      if (gamification != null) {
        // Usa o estado do ObjectBox
        state = state.copyWith(
          gamification: gamification,
          isLoading: false,
          isModuleActive: gamification.isModuleActive,
        );
        LoggerService.instance.gamification('✅ Estado carregado do ObjectBox: isModuleActive=${gamification.isModuleActive}, dailyCost=${gamification.dailyCost}');
      } else {
        // Se não tem estado local, tenta carregar do Supabase
        LoggerService.instance.gamification('🌐 Tentando carregar do Supabase...');
        final cloudState = await _repository.loadFromSupabase();
        
        if (cloudState != null) {
          await _repository.saveSmokingState(cloudState);
          state = state.copyWith(
            gamification: cloudState,
            isLoading: false,
            isModuleActive: cloudState.isModuleActive,
          );
          LoggerService.instance.gamification('✅ Estado carregado do Supabase: isModuleActive=${cloudState.isModuleActive}, dailyCost=${cloudState.dailyCost}');
        } else {
          // Se não tem em nenhum lugar, NÃO cria estado automaticamente
          // Aguarda sync ou ativação manual
          state = state.copyWith(
            gamification: null,
            isLoading: false,
            isModuleActive: false,
          );
          LoggerService.instance.gamification('⏳ Nenhum estado encontrado. Aguardando sync ou ativação manual.');
        }
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
  Future<void> activateModule({double dailyCost = 0.0, double packCost = 0.0}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Usa forceResetToActive para limpar estado antigo e garantir persistência
      await _repository.forceResetToActive(dailyCost: dailyCost, packCost: packCost);
      
      final initialState = SmokingModuleState.initial().copyWith(
        isModuleActive: true,
        dailyCost: dailyCost,
        packCost: packCost,
      );
      
      await _repository.syncWithSupabase(initialState);
      
      // Também atualiza o user_module_status para manter consistência com CloudSyncService
      await _cloudSync.saveModuleStatus(
        nicheId: NicheId.smoking,
        isModuleActive: true,
      );
      LoggerService.instance.gamification('☁️ user_module_status atualizado: is_active=true');
      
      // Atualiza o estado local diretamente sem recarregar
      state = state.copyWith(
        gamification: initialState,
        isLoading: false,
        isModuleActive: true,
      );
      LoggerService.instance.gamification('✅ Módulo ativado: isModuleActive=true, dailyCost=$dailyCost, packCost=$packCost');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Desativa o módulo (limpa dados)
  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      LoggerService.instance.gamification('🛑 deactivateModule chamado - salvando isModuleActive=false');
      final current = state.gamification;
      if (current != null) {
        final updated = current.copyWith(isModuleActive: false);
        await _repository.saveSmokingState(updated);
        await _repository.syncWithSupabase(updated);
      }
      
      // Também atualiza o user_module_status para manter consistência com CloudSyncService
      await _cloudSync.saveModuleStatus(
        nicheId: NicheId.smoking,
        isModuleActive: false,
      );
      LoggerService.instance.gamification('☁️ user_module_status atualizado: is_active=false');
      
      state = state.copyWith(
        gamification: null,
        isModuleActive: false, 
        isLoading: false
      );
      LoggerService.instance.gamification('🛑 Módulo desativado e sincronizado');
    } catch (e) {
      LoggerService.instance.e('❌ Erro em deactivateModule', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetProgress() async {
    try {
      LoggerService.instance.gamification('🔄 resetProgress chamado - limpando e resetando progresso');
      // Preserva a insígnia Madeira e o status ativo (incentivo para tentar novamente)
      final current = state.gamification;
      final hasMadeira = current?.earnedInsignias.contains('Madeira') ?? false;
      final wasActive = current?.isModuleActive ?? false;
      final dailyCost = current?.dailyCost ?? 0.0;
      final packCost = current?.packCost ?? 0.0;

      LoggerService.instance.gamification('🔄 Preservando: isModuleActive=$wasActive, dailyCost=$dailyCost, hasMadeira=$hasMadeira');
      
      await _repository.clearSmokingState();
      
      // Cria estado inicial preservando configurações importantes
      final initialState = SmokingModuleState.initial().copyWith(
        isModuleActive: wasActive,  // PRESERVA o status ativo!
        dailyCost: dailyCost,       // PRESERVA o custo diário!
        packCost: packCost,         // PRESERVA o custo do maço!
        earnedInsignias: hasMadeira ? ['Madeira'] : [],
      );
      
      await _repository.saveSmokingState(initialState);
      await _repository.syncWithSupabase(initialState);
      
      LoggerService.instance.gamification('✅ Progresso resetado mantendo isModuleActive=$wasActive');
      
      await loadGamification();
    } catch (e) {
      LoggerService.instance.e('❌ Erro em resetProgress', error: e);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Salva mensagens customizadas para um nicho específico
  /// [nicheId] - ID do nicho (ex: 'motivation_phrases')
  /// [messages] - Lista de mensagens customizadas
  Future<void> setCustomMessages(String nicheId, List<String> messages) async {
    try {
      final current = state.gamification;
      if (current == null) {
        LoggerService.instance.gamification('⚠️ setCustomMessages: gamification é null, pulando save');
        return;
      }
      
      // Cria cópia do mapa de mensagens customizadas
      final updatedMessages = Map<String, List<String>>.from(current.customMessages);
      updatedMessages[nicheId] = messages;
      
      final updated = current.copyWith(
        customMessages: updatedMessages,
      );
      
      await _repository.saveSmokingState(updated);
      await _repository.syncWithSupabase(updated);
      await loadGamification();
    } catch (e) {
      LoggerService.instance.e('❌ Erro em setCustomMessages', error: e);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Define a mensagem principal customizada
  /// [message] - Mensagem principal
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
      await _repository.syncWithSupabase(updated);
      await loadGamification();
    } catch (e) {
      LoggerService.instance.e('❌ Erro em setCustomMainMessage', error: e);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Recarrega sessões de monitoramento ativas
  /// Útil após atualizar mensagens ou configurações
  Future<void> reloadMonitoringSessions() async {
    try {
      // Força recarregamento do estado
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
  );
});

/// Provider conveniente
final smokingGamificationStateProvider = Provider<AsyncValue<SmokingGamificationState>>((ref) {
  final state = ref.watch(smokingGamificationNotifierProvider);
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});
