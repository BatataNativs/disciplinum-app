import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_module_state.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/entities/adult_content_gamification_entity.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/services/adult_content_migration_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Adult Content
/// Implementa persistência local com Isar e sincronização com Supabase
class AdultContentGamificationRepository {
  static AdultContentGamificationRepository? _instance;
  static AdultContentGamificationRepository get instance => _instance ??= AdultContentGamificationRepository._();
  
  AdultContentGamificationRepository._();

  /// Salva o estado localmente usando Isar
  Future<void> saveAdultContentState(AdultContentModuleState state) async {
    try {
      final entity = AdultContentGamificationEntity.fromModuleState('adult_content_user', state);
      
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.adultContentGamificationStates.put(entity);
      });
      
      LoggerService.instance.gamification('Estado Adult Content salvo com Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Adult Content com Isar', error: e);
    }
  }

  /// Carrega o estado salvo localmente
  Future<AdultContentModuleState?> getAdultContentState() async {
    try {
      // Usando sintaxe simples como outros módulos: pega primeiro registro
      final isar = IsarService.instance.database;
      final entity = await isar.adultContentGamificationEntitys.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        final stateMap = entity.toModuleStateMap();
        LoggerService.instance.gamification('Estado Adult Content carregado do Isar');
        return AdultContentModuleState.fromJson(stateMap);
      }
      
      LoggerService.instance.gamification('Estado Adult Content não encontrado no Isar');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Adult Content do Isar', error: e);
      return null;
    }
  }

  /// Limpa o estado local
  Future<void> clearAdultContentState() async {
    try {
      await IsarService.instance.database.writeTxn(() async {
        await IsarService.instance.adultContentGamificationStates.clear();
      });
      LoggerService.instance.gamification('Estado Adult Content limpo do Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Adult Content do Isar', error: e);
    }
  }

  /// Sincroniza com Supabase (upload)
  Future<void> syncWithSupabase(AdultContentModuleState state) async {
    try {
      final isReady = await AdultContentMigrationChecker.instance.ensureMigration();
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

      await Supabase.instance.client.from('adult_content_gamification_states').upsert({
        'user_id': userId,
        'state_data': data,
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('Estado Adult Content sincronizado com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar estado Adult Content com Supabase', error: e);
    }
  }

  /// Carrega do Supabase (download)
  Future<AdultContentModuleState?> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para carregar dados');
        return null;
      }

      final response = await Supabase.instance.client
          .from('adult_content_gamification_states')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['state_data'] != null) {
        final stateData = Map<String, dynamic>.from(response['state_data']);
        final state = AdultContentModuleState.fromJson(stateData);
        LoggerService.instance.gamification('Estado Adult Content carregado do Supabase');
        return state;
      }

      LoggerService.instance.gamification('Estado Adult Content não encontrado no Supabase');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Adult Content do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<AdultContentModuleState> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      AdultContentModuleState? supabaseState = await loadFromSupabase();
      
      if (supabaseState != null) {
        // Salva localmente e retorna
        await saveAdultContentState(supabaseState);
        return supabaseState;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      AdultContentModuleState? localState = await getAdultContentState();
      
      if (localState != null) {
        // Envia para o Supabase
        await syncWithSupabase(localState);
        return localState;
      }
      
      // Se não encontrou em nenhum lugar, retorna estado inicial
      LoggerService.instance.gamification('Criando estado inicial Adult Content');
      final initialState = AdultContentModuleState.initial();
      await saveAdultContentState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Adult Content', error: e);
      // Fallback para estado inicial
      return AdultContentModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = AdultContentModuleState.initial();
      
      await saveAdultContentState(resetState);
      await syncWithSupabase(resetState);
      
      LoggerService.instance.gamification('Progresso Adult Content resetado');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso Adult Content', error: e);
    }
  }

  /// Obtém estatísticas do módulo
  Future<Map<String, dynamic>> getModuleStats() async {
    try {
      final state = await getAdultContentState();
      
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
      LoggerService.instance.e('Erro ao obter estatísticas Adult Content', error: e);
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
      final migrationOk = await AdultContentMigrationChecker.instance.ensureMigration();
      if (!migrationOk) {
        LoggerService.instance.w('⚠️ Supabase não está migrado - usando apenas Isar local');
      }
      
      LoggerService.instance.gamification('AdultContentGamificationRepository inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar AdultContentGamificationRepository', error: e);
      rethrow;
    }
  }

  /// Verifica se há dados locais
  Future<bool> hasLocalData() async {
    try {
      final state = await getAdultContentState();
      return state != null;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar dados locais Adult Content', error: e);
      return false;
    }
  }

  /// Força sincronização manual
  Future<bool> forceSync() async {
    try {
      final localState = await getAdultContentState();
      
      if (localState != null) {
        await syncWithSupabase(localState);
        LoggerService.instance.gamification('Sincronização forçada Adult Content concluída');
        return true;
      }
      
      LoggerService.instance.w('Não há dados locais para sincronizar Adult Content');
      return false;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização forçada Adult Content', error: e);
      return false;
    }
  }

  /// Limpa todos os dados (local e cloud)
  Future<void> clearAllData() async {
    try {
      // Limpa dados locais
      await clearAdultContentState();
      
      // Tenta limpar dados do Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        try {
          await Supabase.instance.client
              .from('adult_content_gamification_states')
              .delete()
              .eq('user_id', userId);
          
          LoggerService.instance.gamification('Dados do Supabase Adult Content limpos');
        } catch (e) {
          LoggerService.instance.w('Erro ao limpar dados do Supabase Adult Content: $e');
        }
      }
      
      LoggerService.instance.gamification('Todos os dados Adult Content limpos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar todos os dados Adult Content', error: e);
    }
  }
}
