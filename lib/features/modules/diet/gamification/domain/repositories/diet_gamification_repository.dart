import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/supabase_migration_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_module_state.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/entities/diet_gamification_entity.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Dieta
/// Implementa persistência local com ObjectBox e sincronização com Supabase
class DietGamificationRepository {
  static DietGamificationRepository? _instance;
  static DietGamificationRepository get instance => _instance ??= DietGamificationRepository._();
  
  DietGamificationRepository._();

  Box<DietGamificationEntity> get _box => ObjectBoxService.instance.store.box<DietGamificationEntity>();

  /// Salva o estado localmente usando ObjectBox
  Future<void> saveDietState(DietModuleState state) async {
    try {
      final entity = DietGamificationEntity.fromModuleState('diet_user', state.toJson());
      
      final existingEntity = _box.get(1);
      if (existingEntity != null) {
        entity.id = existingEntity.id;
      } else {
        entity.id = 1;
      }
      
      _box.put(entity);
      
      LoggerService.instance.gamification('Estado Dieta salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Dieta com ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega o estado salvo localmente
  Future<DietModuleState?> getDietState() async {
    try {
      final entity = _box.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        LoggerService.instance.gamification('Estado Dieta carregado do ObjectBox');
        return entity.toModuleState();
      }
      
      LoggerService.instance.gamification('Estado Dieta não encontrado no ObjectBox');
      return null;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar estado Dieta do ObjectBox', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Limpa todos os dados locais
  Future<void> clearDietState() async {
    try {
      _box.removeAll();
      LoggerService.instance.gamification('Estado Dieta limpo do ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar estado Dieta do ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Sincroniza com Supabase (upload)
  Future<void> syncWithSupabase(DietModuleState state) async {
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

      await Supabase.instance.client.from('diet_gamification_states').upsert({
        'user_id': userId,
        'state_data': state.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('Estado Dieta sincronizado com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar estado Dieta com Supabase', error: e);
    }
  }

  /// Faz download do estado do Supabase
  Future<DietModuleState?> downloadFromSupabase() async {
    try {
      final isReady = await SupabaseMigrationChecker.instance.ensureMigration();
      if (!isReady) {
        LoggerService.instance.w('Supabase não está pronto para download');
        return null;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para download');
        return null;
      }

      final response = await Supabase.instance.client
          .from('diet_gamification_states')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final stateData = response['state_data'] as Map<String, dynamic>;
        final state = DietModuleState.fromJson(stateData);
        LoggerService.instance.gamification('Estado Dieta baixado do Supabase');
        return state;
      }

      LoggerService.instance.gamification('Estado Dieta não encontrado no Supabase');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao baixar estado Dieta do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização completa (merge local + cloud)
  Future<DietModuleState> performFullSync() async {
    try {
      // Tenta baixar do Supabase primeiro
      final cloudState = await downloadFromSupabase();
      
      if (cloudState != null) {
        // Se encontrou na nuvem, usa o estado da nuvem
        await saveDietState(cloudState);
        return cloudState;
      }

      // Se não encontrou na nuvem, usa o estado local
      final localState = await getDietState();
      if (localState != null) {
        // Sincroniza o estado local com a nuvem
        await syncWithSupabase(localState);
        return localState;
      }

      // Cria estado padrão se não encontrou nem local nem na nuvem
      final defaultState = DietModuleState(
        earnedInsignias: [],
        earnedMedalhas: [],
        consecutiveDays: 0,
        disciplinumCount: 0,
        isActive: false,
      );

      await saveDietState(defaultState);
      return defaultState;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa do estado Dieta', error: e);
      
      // Retorna estado local como fallback
      final localState = await getDietState();
      return localState ?? DietModuleState(
        earnedInsignias: [],
        earnedMedalhas: [],
        consecutiveDays: 0,
        disciplinumCount: 0,
        isActive: false,
      );
    }
  }

  /// Reseta o progresso (mantém apenas madeira)
  Future<void> resetProgress() async {
    try {
      final currentState = await getDietState();
      if (currentState != null) {
        final resetState = currentState.copyWith(
          earnedInsignias: ['madeira'], // Mantém apenas madeira
          earnedMedalhas: [], // Remove todas as medalhas
          consecutiveDays: 0,
          disciplinumCount: 0,
          isActive: false,
        );
        
        await saveDietState(resetState);
        
        // Sincroniza reset com Supabase
        await syncWithSupabase(resetState);
        
        LoggerService.instance.gamification('Progresso do módulo Dieta resetado');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso do módulo Dieta', error: e);
    }
  }
}
