import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/entities/spending_module_state.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/entities/spending_gamification_entity.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/services/spending_migration_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Spending
/// Implementa persistência local com Isar e sincronização com Supabase
class SpendingGamificationRepository {
  static SpendingGamificationRepository? _instance;
  static SpendingGamificationRepository get instance => _instance ??= SpendingGamificationRepository._();
  
  SpendingGamificationRepository._();

  /// Salva o estado localmente usando Isar
  Future<void> saveSpendingState(SpendingModuleState state) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final entity = SpendingGamificationEntity.fromModuleState(userId, state);
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        // Usar putByUserId que gerencia automaticamente o upsert pelo índice único
        await isar.spendingGamificationEntitys.putByUserId(entity);
      });
      
      LoggerService.instance.gamification('Estado Spending salvo com Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Spending com Isar', error: e);
    }
  }

  /// Carrega o estado salvo localmente
  Future<SpendingModuleState?> getSpendingState() async {
    try {
      // Usando sintaxe simples como outros módulos: pega primeiro registro
      final isar = IsarService.instance.database;
      final entity = await isar.spendingGamificationEntitys.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        final stateMap = entity.toModuleStateMap();
        LoggerService.instance.gamification('Estado Spending carregado do Isar');
        return SpendingModuleState.fromJson(stateMap);
      }
      
      LoggerService.instance.gamification('Estado Spending não encontrado no Isar');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Spending do Isar', error: e);
      return null;
    }
  }

  /// Limpa o estado local
  Future<void> clearSpendingState() async {
    try {
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.spendingGamificationStates.clear();
      });
      LoggerService.instance.gamification('Estado Spending limpo do Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Spending do Isar', error: e);
    }
  }

  /// Sincroniza com Supabase (upload)
  Future<void> syncWithSupabase(SpendingModuleState state) async {
    try {
      final isReady = await SpendingMigrationChecker.instance.ensureMigration();
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

      await Supabase.instance.client.from('spending_gamification_states').upsert({
        'user_id': userId,
        'state_data': data,
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('Estado Spending sincronizado com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar estado Spending com Supabase', error: e);
    }
  }

  /// Carrega do Supabase (download)
  Future<SpendingModuleState?> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para carregar dados');
        return null;
      }

      final response = await Supabase.instance.client
          .from('spending_gamification_states')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['state_data'] != null) {
        final stateData = Map<String, dynamic>.from(response['state_data']);
        final state = SpendingModuleState.fromJson(stateData);
        LoggerService.instance.gamification('Estado Spending carregado do Supabase');
        return state;
      }

      LoggerService.instance.gamification('Estado Spending não encontrado no Supabase');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Spending do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<SpendingModuleState> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      SpendingModuleState? supabaseState = await loadFromSupabase();
      
      if (supabaseState != null) {
        // Salva localmente e retorna
        await saveSpendingState(supabaseState);
        return supabaseState;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      SpendingModuleState? localState = await getSpendingState();
      
      if (localState != null) {
        // Envia para o Supabase
        await syncWithSupabase(localState);
        return localState;
      }
      
      // Se não encontrou em nenhum lugar, retorna estado inicial
      LoggerService.instance.gamification('Criando estado inicial Spending');
      final initialState = SpendingModuleState.initial();
      await saveSpendingState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Spending', error: e);
      // Fallback para estado inicial
      return SpendingModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = SpendingModuleState.initial();
      
      await saveSpendingState(resetState);
      await syncWithSupabase(resetState);
      
      LoggerService.instance.gamification('Progresso Spending resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso Spending', error: e);
    }
  }

  /// Obtém estatísticas do módulo
  Future<Map<String, dynamic>> getModuleStats() async {
    try {
      final state = await getSpendingState();
      
      if (state == null) {
        return {
          'consecutiveMonths': 0,
          'disciplinumCount': 0,
          'earnedInsignias': [],
          'earnedMedalhas': [],
          'isActive': false,
          'lastUpdated': DateTime.now().toIso8601String(),
          'version': '1.0',
        };
      }
      
      return {
        'consecutiveMonths': state.consecutiveMonths,
        'disciplinumCount': state.disciplinumCount,
        'earnedInsignias': state.earnedInsignias,
        'earnedMedalhas': state.earnedMedalhas,
        'isActive': state.isActive,
        'lastUpdated': state.lastUpdated.toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Spending', error: e);
      return {
        'consecutiveMonths': 0,
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
      final migrationOk = await SpendingMigrationChecker.instance.ensureMigration();
      if (!migrationOk) {
        LoggerService.instance.w('⚠️ Supabase não está migrado - usando apenas Isar local');
      }
      
      LoggerService.instance.gamification('SpendingGamificationRepository inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar SpendingGamificationRepository', error: e);
      rethrow;
    }
  }

  /// Verifica se há dados locais
  Future<bool> hasLocalData() async {
    try {
      final state = await getSpendingState();
      return state != null;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar dados locais Spending', error: e);
      return false;
    }
  }

  /// Força sincronização manual
  Future<bool> forceSync() async {
    try {
      final localState = await getSpendingState();
      
      if (localState != null) {
        await syncWithSupabase(localState);
        LoggerService.instance.gamification('Sincronização forçada Spending concluída');
        return true;
      }
      
      LoggerService.instance.w('Não há dados locais para sincronizar Spending');
      return false;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização forçada Spending', error: e);
      return false;
    }
  }

  /// Limpa todos os dados (local e cloud)
  Future<void> clearAllData() async {
    try {
      // Limpa dados locais
      await clearSpendingState();
      
      // Tenta limpar dados do Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        try {
          await Supabase.instance.client
              .from('spending_gamification_states')
              .delete()
              .eq('user_id', userId);
          
          LoggerService.instance.gamification('Dados do Supabase Spending limpos');
        } catch (e) {
          LoggerService.instance.w('Erro ao limpar dados do Supabase Spending: $e');
        }
      }
      
      LoggerService.instance.gamification('Todos os dados Spending limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar todos os dados Spending', error: e);
    }
  }
}
