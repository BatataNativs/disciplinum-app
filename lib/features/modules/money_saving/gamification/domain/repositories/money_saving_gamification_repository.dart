import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/supabase_migration_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_gamification_entity.dart';
import 'package:disciplinum/core/database/isar_service.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Money Saving Challenge
/// Implementa persistência local com Isar e sincronização com Supabase
class MoneySavingGamificationRepository {
  static MoneySavingGamificationRepository? _instance;
  static MoneySavingGamificationRepository get instance => _instance ??= MoneySavingGamificationRepository._();
  
  MoneySavingGamificationRepository._();

  /// Salva o estado localmente usando Isar
  Future<void> saveMoneySavingState(MoneySavingModuleState state) async {
    try {
      // Converte para entidade Isar com ID fixo como outros módulos
      final entity = MoneySavingGamificationEntity.fromModuleState('money_saving_user', state.toJson());
      entity.id = 1; // ID fixo como Smoking e Diet
      
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.moneySavingGamificationStates.put(entity);
      });
      
      LoggerService.instance.gamification('Estado Money Saving salvo com Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Money Saving com Isar', error: e);
    }
  }

  /// Carrega o estado salvo localmente
  Future<MoneySavingModuleState?> getMoneySavingState() async {
    try {
      // Usando sintaxe simples como outros módulos: pega primeiro registro
      final isar = IsarService.instance.database;
      final entity = await isar.moneySavingGamificationEntitys.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        final stateMap = entity.toModuleStateMap();
        LoggerService.instance.gamification('Estado Money Saving carregado do Isar');
        return MoneySavingModuleState.fromJson(stateMap);
      }
      
      LoggerService.instance.gamification('Estado Money Saving não encontrado no Isar');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Money Saving do Isar', error: e);
      return null;
    }
  }

  /// Limpa todos os dados locais
  Future<void> clearMoneySavingState() async {
    try {
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.moneySavingGamificationStates.clear();
      });
      LoggerService.instance.gamification('Estado Money Saving limpo do Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Money Saving do Isar', error: e);
    }
  }

  /// Sincroniza com Supabase (upload)
  Future<void> syncWithSupabase(MoneySavingModuleState state) async {
    try {
      final isReady = await SupabaseMigrationChecker.instance.ensureMigration();
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

      await Supabase.instance.client.from('money_saving_gamification_states').upsert({
        'user_id': userId,
        'state_data': data,
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('Estado Money Saving sincronizado com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar estado Money Saving com Supabase', error: e);
    }
  }

  /// Carrega do Supabase (download)
  Future<MoneySavingModuleState?> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para carregar dados');
        return null;
      }

      final response = await Supabase.instance.client
          .from('money_saving_gamification_states')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['state_data'] != null) {
        final stateData = Map<String, dynamic>.from(response['state_data']);
        final state = MoneySavingModuleState.fromJson(stateData);
        LoggerService.instance.gamification('Estado Money Saving carregado do Supabase');
        return state;
      }

      LoggerService.instance.gamification('Estado Money Saving não encontrado no Supabase');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Money Saving do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<MoneySavingModuleState> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      MoneySavingModuleState? supabaseState = await loadFromSupabase();
      
      if (supabaseState != null) {
        // Salva localmente e retorna
        await saveMoneySavingState(supabaseState);
        return supabaseState;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      MoneySavingModuleState? localState = await getMoneySavingState();
      
      if (localState != null) {
        // Envia para o Supabase
        await syncWithSupabase(localState);
        return localState;
      }
      
      // Se não encontrou em nenhum lugar, retorna estado inicial
      LoggerService.instance.gamification('Criando estado inicial Money Saving');
      final initialState = MoneySavingModuleState.initial();
      await saveMoneySavingState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Money Saving', error: e);
      // Fallback para estado inicial
      return MoneySavingModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = MoneySavingModuleState.initial();
      
      await saveMoneySavingState(resetState);
      await syncWithSupabase(resetState);
      
      LoggerService.instance.gamification('Progresso do Money Saving resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso Money Saving', error: e);
    }
  }

  /// Obtém estatísticas do repositório
  Future<Map<String, dynamic>> getRepositoryStats() async {
    try {
      return {
        'hasState': await getMoneySavingState() != null,
        'storageType': 'Isar',
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Money Saving', error: e);
      return {
        'hasState': false,
        'storageType': 'Isar',
        'version': '1.0',
        'error': e.toString(),
      };
    }
  }

  /// Inicializa o repositório
  Future<void> initialize() async {
    try {
      // Verifica se o Supabase está pronto para uso
      final migrationOk = await SupabaseMigrationChecker.instance.ensureMigration();
      if (!migrationOk) {
        LoggerService.instance.w('⚠️ Supabase não está migrado - usando apenas Isar local');
      }
      
      LoggerService.instance.gamification('MoneySavingGamificationRepository inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar MoneySavingGamificationRepository', error: e);
      rethrow;
    }
  }
}
