import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_module_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository simplificado para gerenciar persistência da gamificação do Binge Eating
class BingeEatingGamificationRepository {
  static BingeEatingGamificationRepository? _instance;
  static BingeEatingGamificationRepository get instance => 
      _instance ??= BingeEatingGamificationRepository._();
  
  BingeEatingGamificationRepository._();

  static const String _storageKey = 'binge_eating_gamification_state';

  /// Salva o estado localmente usando localStorage
  Future<void> saveBingeEatingState(BingeEatingModuleState state) async {
    try {
      final stateJson = state.toJson();
      await LocalStorageService.instance.saveJson(_storageKey, stateJson);
      LoggerService.instance.gamification('Estado Binge Eating salvo com localStorage');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Binge Eating com localStorage', error: e);
    }
  }

  /// Carrega o estado salvo localmente
  Future<BingeEatingModuleState?> getBingeEatingState() async {
    try {
      final stateData = await LocalStorageService.instance.getJson(_storageKey);
      if (stateData != null) {
        final state = BingeEatingModuleState.fromJson(stateData);
        LoggerService.instance.gamification('Estado Binge Eating carregado do localStorage');
        return state;
      }
      
      LoggerService.instance.gamification('Estado Binge Eating não encontrado no localStorage');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Binge Eating do localStorage', error: e);
      return null;
    }
  }

  /// Limpa todos os dados locais
  Future<void> clearBingeEatingState() async {
    try {
      await LocalStorageService.instance.remove(_storageKey);
      LoggerService.instance.gamification('Estado Binge Eating limpo do localStorage');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Binge Eating do localStorage', error: e);
    }
  }

  /// Sincroniza com Supabase (upload)
  Future<void> syncWithSupabase(BingeEatingModuleState state) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = state.toJson();
      data['user_id'] = userId;

      await Supabase.instance.client.from('binge_eating_gamification_states').upsert({
        'user_id': userId,
        'state_data': data,
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('Estado Binge Eating sincronizado com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar estado Binge Eating com Supabase', error: e);
    }
  }

  /// Carrega do Supabase (download)
  Future<BingeEatingModuleState?> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para carregar dados');
        return null;
      }

      final response = await Supabase.instance.client
          .from('binge_eating_gamification_states')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['state_data'] != null) {
        final stateData = Map<String, dynamic>.from(response['state_data']);
        final state = BingeEatingModuleState.fromJson(stateData);
        LoggerService.instance.gamification('Estado Binge Eating carregado do Supabase');
        return state;
      }

      LoggerService.instance.gamification('Estado Binge Eating não encontrado no Supabase');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Binge Eating do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<BingeEatingModuleState> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      BingeEatingModuleState? supabaseState = await loadFromSupabase();
      
      if (supabaseState != null) {
        // Salva localmente e retorna
        await saveBingeEatingState(supabaseState);
        return supabaseState;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      BingeEatingModuleState? localState = await getBingeEatingState();
      
      if (localState != null) {
        // Envia para o Supabase
        await syncWithSupabase(localState);
        return localState;
      }
      
      // Se não encontrou em nenhum lugar, cria estado padrão
      final defaultState = BingeEatingModuleState(
        lastUpdated: DateTime.now(),
        isActive: false,
      );
      
      await saveBingeEatingState(defaultState);
      return defaultState;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa do Binge Eating', error: e);
      
      // Fallback para estado padrão
      return BingeEatingModuleState(
        lastUpdated: DateTime.now(),
        isActive: false,
      );
    }
  }

  /// Reseta o progresso (mantendo madeira se ativo)
  Future<void> resetProgress() async {
    try {
      final currentState = await getBingeEatingState();
      if (currentState != null) {
        final resetState = BingeEatingModuleState(
          earnedInsignias: currentState.isActive ? ['madeira'] : [],
          earnedMedalhas: [],
          consecutivePositiveDays: 0,
          disciplinumCount: 0,
          lastUpdated: DateTime.now(),
          isActive: currentState.isActive,
        );
        
        await saveBingeEatingState(resetState);
        await syncWithSupabase(resetState);
        
        LoggerService.instance.gamification('Progresso do Binge Eating resetado');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso do Binge Eating', error: e);
    }
  }
}
