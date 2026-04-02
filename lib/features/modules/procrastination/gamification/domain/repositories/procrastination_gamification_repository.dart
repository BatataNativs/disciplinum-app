import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_module_state.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/entities/procrastination_gamification_entity.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/services/procrastination_migration_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Procrastination
/// Implementa persistência local com Isar e sincronização com Supabase
class ProcrastinationGamificationRepository {
  static ProcrastinationGamificationRepository? _instance;
  static ProcrastinationGamificationRepository get instance => _instance ??= ProcrastinationGamificationRepository._();
  
  ProcrastinationGamificationRepository._();

  /// Salva o estado localmente usando Isar
  Future<void> saveProcrastinationState(ProcrastinationModuleState state) async {
    try {
      final entity = ProcrastinationGamificationEntity.fromModuleState('procrastination_user', state);
      
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.procrastinationGamificationStates.put(entity);
      });
      
      LoggerService.instance.gamification('Estado Procrastination salvo com Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Procrastination com Isar', error: e);
    }
  }

  /// Carrega o estado salvo localmente
  Future<ProcrastinationModuleState?> getProcrastinationState() async {
    try {
      // Usando sintaxe simples como outros módulos: pega primeiro registro
      final isar = IsarService.instance.database;
      final entity = await isar.procrastinationGamificationEntitys.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        final stateMap = entity.toModuleStateMap();
        LoggerService.instance.gamification('Estado Procrastination carregado do Isar');
        return ProcrastinationModuleState.fromJson(stateMap);
      }
      
      LoggerService.instance.gamification('Estado Procrastination não encontrado no Isar');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Procrastination do Isar', error: e);
      return null;
    }
  }

  /// Limpa o estado local
  Future<void> clearProcrastinationState() async {
    try {
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.procrastinationGamificationStates.clear();
      });
      LoggerService.instance.gamification('Estado Procrastination limpo do Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Procrastination do Isar', error: e);
    }
  }

  /// Sincroniza com Supabase (upload)
  Future<void> syncWithSupabase(ProcrastinationModuleState state) async {
    try {
      final isReady = await ProcrastinationMigrationChecker.instance.ensureMigration();
      if (!isReady) {
        LoggerService.instance.w('Supabase não está pronto para sincronização');
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = state.toJson();
      data['user_id'] = userId;

      await Supabase.instance.client.from('procrastination_gamification_states').upsert({
        'user_id': userId,
        'state_data': data,
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('Estado Procrastination sincronizado com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar estado Procrastination com Supabase', error: e);
    }
  }

  /// Carrega do Supabase (download)
  Future<ProcrastinationModuleState?> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para carregar dados');
        return null;
      }

      final response = await Supabase.instance.client
          .from('procrastination_gamification_states')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['state_data'] != null) {
        final stateData = Map<String, dynamic>.from(response['state_data']);
        final state = ProcrastinationModuleState.fromJson(stateData);
        LoggerService.instance.gamification('Estado Procrastination carregado do Supabase');
        return state;
      }

      LoggerService.instance.gamification('Estado Procrastination não encontrado no Supabase');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Procrastination do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<ProcrastinationModuleState> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      ProcrastinationModuleState? supabaseState = await loadFromSupabase();
      
      if (supabaseState != null) {
        // Salva localmente e retorna
        await saveProcrastinationState(supabaseState);
        return supabaseState;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      ProcrastinationModuleState? localState = await getProcrastinationState();
      
      if (localState != null) {
        // Envia para o Supabase
        await syncWithSupabase(localState);
        return localState;
      }
      
      // Se não encontrou em nenhum lugar, retorna estado inicial
      LoggerService.instance.gamification('Criando estado inicial Procrastination');
      final initialState = ProcrastinationModuleState.initial();
      await saveProcrastinationState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Procrastination', error: e);
      // Fallback para estado inicial
      return ProcrastinationModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = ProcrastinationModuleState.initial();
      
      await saveProcrastinationState(resetState);
      await syncWithSupabase(resetState);
      
      LoggerService.instance.gamification('Progresso Procrastination resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso Procrastination', error: e);
    }
  }

  /// Obtém estatísticas do módulo
  Future<Map<String, dynamic>> getModuleStats() async {
    try {
      final state = await getProcrastinationState();
      
      if (state == null) {
        return {
          'consecutiveDays': 0,
          'disciplinumCount': 0,
          'earnedInsignias': [],
          'earnedMedalhas': [],
          'isActive': false,
          'lastUpdated': DateTime.now().toIso8601String(),
          'version': '1.0',
        };
      }
      
      return {
        'consecutiveDays': state.consecutiveDays,
        'disciplinumCount': state.disciplinumCount,
        'earnedInsignias': state.earnedInsignias,
        'earnedMedalhas': state.earnedMedalhas,
        'isActive': state.isActive,
        'lastUpdated': state.lastUpdated.toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Procrastination', error: e);
      return {
        'consecutiveDays': 0,
        'disciplinumCount': 0,
        'earnedInsignias': [],
        'earnedMedalhas': [],
        'isActive': false,
        'lastUpdated': DateTime.now().toIso8601String(),
        'version': '1.0',
        'error': e.toString(),
      };
    }
  }

  /// Inicializa o repositório
  Future<void> initialize() async {
    try {
      // Verifica se o Supabase está pronto para uso
      final migrationOk = await ProcrastinationMigrationChecker.instance.ensureMigration();
      if (!migrationOk) {
        LoggerService.instance.w('⚠️ Supabase não está migrado - usando apenas Isar local');
      }
      
      LoggerService.instance.gamification('ProcrastinationGamificationRepository inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar ProcrastinationGamificationRepository', error: e);
      rethrow;
    }
  }

  /// Verifica se há dados locais
  Future<bool> hasLocalData() async {
    try {
      final state = await getProcrastinationState();
      return state != null;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar dados locais Procrastination', error: e);
      return false;
    }
  }

  /// Força sincronização manual
  Future<bool> forceSync() async {
    try {
      final localState = await getProcrastinationState();
      
      if (localState != null) {
        await syncWithSupabase(localState);
        LoggerService.instance.gamification('Sincronização forçada Procrastination concluída');
        return true;
      }
      
      LoggerService.instance.w('Não há dados locais para sincronizar Procrastination');
      return false;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização forçada Procrastination', error: e);
      return false;
    }
  }

  /// Limpa todos os dados (local e cloud)
  Future<void> clearAllData() async {
    try {
      // Limpa dados locais
      await clearProcrastinationState();
      
      // Tenta limpar dados do Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        try {
          await Supabase.instance.client
              .from('procrastination_gamification_states')
              .delete()
              .eq('user_id', userId);
          
          LoggerService.instance.gamification('Dados do Supabase Procrastination limpos');
        } catch (e) {
          LoggerService.instance.w('Erro ao limpar dados do Supabase Procrastination: $e');
        }
      }
      
      LoggerService.instance.gamification('Todos os dados Procrastination limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar todos os dados Procrastination', error: e);
    }
  }
}
