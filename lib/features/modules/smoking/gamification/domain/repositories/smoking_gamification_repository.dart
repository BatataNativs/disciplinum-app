import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/database/supabase_migration_checker.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_gamification_entity.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório ObjectBox para gamificação do módulo Smoking
/// Gerencia persistência do estado de gamificação usando ObjectBox + Supabase
class SmokingGamificationRepository {
  static SmokingGamificationRepository? _instance;
  static SmokingGamificationRepository get instance => _instance ??= SmokingGamificationRepository._();

  SmokingGamificationRepository._();

  Box<SmokingGamificationEntity>? _box;

  Box<SmokingGamificationEntity> get box {
    _box ??= ObjectBoxService.instance.store.box<SmokingGamificationEntity>();
    return _box!;
  }

  /// Salva o estado completo do módulo Smoking
  Future<void> saveSmokingState(SmokingModuleState state) async {
    try {
      // Converte SmokingModuleState para SmokingGamificationEntity
      final entity = SmokingGamificationEntity();
      entity.earnedInsigniasList = state.earnedInsignias;
      entity.earnedMedalhasList = state.earnedMedalhas;
      entity.consecutivePositiveDays = state.consecutivePositiveDays;
      entity.disciplinumCount = state.disciplinumCount;
      entity.lastPositiveCheckIn = state.lastPositiveCheckIn;
      entity.startDate = state.startDate;
      entity.dailyCost = state.dailyCost;
      entity.packCost = state.packCost;
      
      final existingEntity = box.get(1);
      if (existingEntity != null) {
        entity.id = existingEntity.id;
      } else {
        entity.id = 1;
      }
      entity.touch();

      // Salva no ObjectBox
      box.put(entity);

      LoggerService.instance.gamification('✅ Estado Smoking salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Smoking com ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega o estado salvo do módulo Smoking
  Future<SmokingModuleState?> getSmokingState() async {
    try {
      final entity = box.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        // Usa o construtor fromJson com os dados da entity
        final jsonData = entity.toJson();
        final newState = SmokingModuleState.fromJson(jsonData);
        
        LoggerService.instance.gamification('✅ Estado Smoking carregado com ObjectBox');
        return newState;
      }
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Smoking com ObjectBox', error: e);
      return null;
    }
  }

  /// Limpa o estado salvo
  Future<void> clearSmokingState() async {
    try {
      box.removeAll();
      LoggerService.instance.gamification('🗑️ Estado Smoking limpo com ObjectBox');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Smoking com ObjectBox', error: e);
    }
  }

  /// Verifica se existe estado salvo
  Future<bool> hasSmokingState() async {
    try {
      final count = box.count();
      return count > 0;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado Smoking com ObjectBox', error: e);
      return false;
    }
  }

  /// Obtém metadados do estado
  Future<Map<String, dynamic>?> getStateMetadata() async {
    try {
      return {
        'hasState': await hasSmokingState(),
        'storageType': 'ObjectBox',
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter metadados do estado Smoking', error: e);
      return null;
    }
  }

  /// Sincroniza com Supabase (cloud sync)
  Future<void> syncWithSupabase(SmokingModuleState state) async {
    try {
      // Verifica se Supabase está disponível antes de sincronizar
      if (!await supabaseAvailable) {
        LoggerService.instance.w('⚠️ Supabase não disponível - pulando sincronização');
        return;
      }
      
      // Converte para entity e depois para JSON
      final entity = SmokingGamificationEntity();
      entity.earnedInsigniasList = state.earnedInsignias;
      entity.earnedMedalhasList = state.earnedMedalhas;
      entity.consecutivePositiveDays = state.consecutivePositiveDays;
      entity.disciplinumCount = state.disciplinumCount;
      entity.lastPositiveCheckIn = state.lastPositiveCheckIn;
      entity.startDate = state.startDate;
      entity.dailyCost = state.dailyCost;
      entity.packCost = state.packCost;
      entity.touch();
      
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        await supabase.from('smoking_gamification_states').upsert({
          'user_id': userId,
          'state_data': entity.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        LoggerService.instance.gamification('☁️ Estado Smoking sincronizado com Supabase');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar estado Smoking com Supabase', error: e);
    }
  }

  /// Carrega estado do Supabase
  Future<SmokingModuleState?> loadFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        final response = await supabase
            .from('smoking_gamification_states')
            .select('state_data')
            .eq('user_id', userId)
            .maybeSingle();
        
        if (response != null && response['state_data'] != null) {
          final entity = SmokingGamificationEntity.fromJson(response['state_data']);
          final jsonData = entity.toJson();
          return SmokingModuleState.fromJson(jsonData);
        }
      }
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Smoking do Supabase', error: e);
      return null;
    }
  }

  /// Inicializa o repositório
  Future<void> initialize() async {
    try {
      // Verifica se o Supabase está pronto para uso
      final migrationOk = await SupabaseMigrationChecker.instance.ensureMigration();
      if (!migrationOk) {
        LoggerService.instance.w('⚠️ Supabase não está migrado - usando apenas ObjectBox local');
      }
      
      LoggerService.instance.gamification('SmokingGamificationRepository inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar SmokingGamificationRepository', error: e);
    }
  }

  /// Verifica se Supabase está disponível
  Future<bool> get supabaseAvailable async {
    return await SupabaseMigrationChecker.instance.checkMigrationStatus() == MigrationStatus.complete;
  }
}
