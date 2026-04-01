import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_module_state.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_gamification_entity.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/services/binge_eating_migration_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Binge Eating
/// Implementa persistência local com Isar e sincronização com Supabase
class BingeEatingGamificationRepository {
  static BingeEatingGamificationRepository? _instance;
  static BingeEatingGamificationRepository get instance => _instance ??= BingeEatingGamificationRepository._();
  
  BingeEatingGamificationRepository._();

  /// Salva o estado localmente usando Isar
  Future<void> saveBingeEatingState(BingeEatingModuleState state) async {
    try {
      final entity = BingeEatingGamificationEntity.fromModuleState('binge_eating_user', state);
      
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.bingeEatingGamificationStates.put(entity);
      });
      
      LoggerService.instance.gamification('Estado Binge Eating salvo com Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Binge Eating com Isar', error: e);
    }
  }

  /// Carrega o estado salvo localmente
  Future<BingeEatingModuleState?> getBingeEatingState() async {
    try {
      // Usando sintaxe simples como outros módulos: pega primeiro registro
      final isar = IsarService.instance.database;
      final entity = await isar.bingeEatingGamificationEntitys.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        final stateMap = entity.toModuleStateMap();
        LoggerService.instance.gamification('Estado Binge Eating carregado do Isar');
        return BingeEatingModuleState.fromJson(stateMap);
      }
      
      LoggerService.instance.gamification('Estado Binge Eating não encontrado no Isar');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Binge Eating do Isar', error: e);
      return null;
    }
  }

  /// Limpa o estado local
  Future<void> clearBingeEatingState() async {
    try {
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.bingeEatingGamificationStates.clear();
      });
      LoggerService.instance.gamification('Estado Binge Eating limpo do Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Binge Eating do Isar', error: e);
    }
  }

  /// Sincroniza com Supabase (upload)
  Future<void> syncWithSupabase(BingeEatingModuleState state) async {
    try {
      final isReady = await BingeEatingMigrationChecker.instance.ensureMigration();
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
      
      // Se não encontrou em nenhum lugar, retorna estado inicial
      LoggerService.instance.gamification('Criando estado inicial Binge Eating');
      final initialState = BingeEatingModuleState.initial();
      await saveBingeEatingState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Binge Eating', error: e);
      // Fallback para estado inicial
      return BingeEatingModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = BingeEatingModuleState.initial();
      
      await saveBingeEatingState(resetState);
      await syncWithSupabase(resetState);
      
      LoggerService.instance.gamification('Progresso Binge Eating resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso Binge Eating', error: e);
    }
  }

  /// Obtém estatísticas do módulo
  Future<Map<String, dynamic>> getModuleStats() async {
    try {
      final state = await getBingeEatingState();
      
      if (state == null) {
        return {
          'consecutivePositiveDays': 0,
          'disciplinumCount': 0,
          'earnedInsignias': [],
          'earnedMedalhas': [],
          'isActive': false,
          'lastUpdated': DateTime.now().toIso8601String(),
          'version': '1.0',
        };
      }
      
      return {
        'consecutivePositiveDays': state.consecutivePositiveDays,
        'disciplinumCount': state.disciplinumCount,
        'earnedInsignias': state.earnedInsignias,
        'earnedMedalhas': state.earnedMedalhas,
        'isActive': state.isActive,
        'lastUpdated': state.lastUpdated.toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Binge Eating', error: e);
      return {
        'consecutivePositiveDays': 0,
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
      final migrationOk = await BingeEatingMigrationChecker.instance.ensureMigration();
      if (!migrationOk) {
        LoggerService.instance.w('⚠️ Supabase não está migrado - usando apenas Isar local');
      }
      
      LoggerService.instance.gamification('BingeEatingGamificationRepository inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar BingeEatingGamificationRepository', error: e);
      rethrow;
    }
  }

  /// Verifica se há dados locais
  Future<bool> hasLocalData() async {
    try {
      final state = await getBingeEatingState();
      return state != null;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar dados locais Binge Eating', error: e);
      return false;
    }
  }

  /// Força sincronização manual
  Future<bool> forceSync() async {
    try {
      final localState = await getBingeEatingState();
      
      if (localState != null) {
        await syncWithSupabase(localState);
        LoggerService.instance.gamification('Sincronização forçada Binge Eating concluída');
        return true;
      }
      
      LoggerService.instance.w('Não há dados locais para sincronizar Binge Eating');
      return false;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização forçada Binge Eating', error: e);
      return false;
    }
  }

  /// Limpa todos os dados (local e cloud)
  Future<void> clearAllData() async {
    try {
      // Limpa dados locais
      await clearBingeEatingState();
      
      // Tenta limpar dados do Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        try {
          await Supabase.instance.client
              .from('binge_eating_gamification_states')
              .delete()
              .eq('user_id', userId);
          
          LoggerService.instance.gamification('Dados do Supabase Binge Eating limpos');
        } catch (e) {
          LoggerService.instance.w('Erro ao limpar dados do Supabase Binge Eating: $e');
        }
      }
      
      LoggerService.instance.gamification('Todos os dados Binge Eating limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar todos os dados Binge Eating', error: e);
    }
  }
}
