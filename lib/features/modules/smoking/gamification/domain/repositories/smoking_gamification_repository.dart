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
      // Log stack trace quando isModuleActive=false para debug
      if (!state.isModuleActive) {
        final stackTrace = StackTrace.current.toString().split('\n').take(8).join('\n');
        LoggerService.instance.gamification('⚠️ saveSmokingState chamado com isModuleActive=false - Stack:\n$stackTrace');
      }
      
      // ALERTA: Tentativa de salvar estado inconsistente
      if (!state.isModuleActive && state.dailyCost > 0) {
        final stackTrace = StackTrace.current.toString().split('\n').take(10).join('\n');
        LoggerService.instance.gamification('🚨🚨🚨 TENTATIVA DE SALVAR ESTADO INCONSISTENTE! isModuleActive=false mas dailyCost=${state.dailyCost}\n🚨 Stack completo:\n$stackTrace');
      }
      
      LoggerService.instance.gamification('💾 saveSmokingState: isModuleActive=${state.isModuleActive}, dailyCost=${state.dailyCost}');
      
      // Converte SmokingModuleState para SmokingGamificationEntity
      final entity = SmokingGamificationEntity.fromModuleState(state);
      LoggerService.instance.gamification('💾 Entity criada: isModuleActive=${entity.isModuleActive}, dailyCost=${entity.dailyCost}');
      
      // Verifica se já existe entidade (usamos ID fixo 1 para sempre ter só um registro)
      final existing = box.query().build().findFirst();
      if (existing != null) {
        entity.id = existing.id; // Reusa o ID existente
        LoggerService.instance.gamification('💾 Reusando ID existente: ${existing.id}');
      } else {
        entity.id = 0; // ObjectBox gera novo ID automaticamente
        LoggerService.instance.gamification('💾 Criando novo registro');
      }
      entity.touch();

      // Salva no ObjectBox
      box.put(entity);
      LoggerService.instance.gamification('✅ Estado Smoking salvo com ObjectBox (isModuleActive: ${state.isModuleActive})');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Smoking com ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega o estado salvo do módulo Smoking
  Future<SmokingModuleState?> getSmokingState() async {
    try {
      // Busca o primeiro registro (deve ter apenas um)
      final entity = box.query().build().findFirst();
      
      if (entity != null) {
        // Usa toModuleState que agora inclui isModuleActive
        final newState = entity.toModuleState();
        
        // CORREÇÃO: Detecta e corrige estado inconsistente (inativo mas com custo configurado)
        if (!newState.isModuleActive && newState.dailyCost > 0) {
          final stackTrace = StackTrace.current.toString().split('\n').take(5).join('\n');
          LoggerService.instance.gamification('🚨🚨🚨 ESTADO INCONSISTENTE DETECTADO! isModuleActive=false mas dailyCost=${newState.dailyCost}\n🚨 Corrigindo automaticamente para isModuleActive=true...\n🚨 Quem chamou:\n$stackTrace');
          
          // Corrige o estado - se tem custo configurado, o módulo deveria estar ativo
          final correctedState = newState.copyWith(isModuleActive: true);
          await saveSmokingState(correctedState);
          LoggerService.instance.gamification('✅ Estado corrigido e salvo: isModuleActive=true, dailyCost=${correctedState.dailyCost}');
          return correctedState;
        }
        
        LoggerService.instance.gamification('✅ Estado Smoking carregado com ObjectBox (isModuleActive: ${newState.isModuleActive}, dailyCost: ${newState.dailyCost})');
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
      final query = box.query().build();
      final count = query.remove();
      LoggerService.instance.gamification('🗑️ Estado Smoking limpo com ObjectBox: $count registros removidos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Smoking com ObjectBox', error: e);
    }
  }

  /// Força reset do estado para ativo (usado para corrigir dados corrompidos)
  Future<void> forceResetToActive({double dailyCost = 0.0, double packCost = 0.0}) async {
    try {
      LoggerService.instance.gamification('🔄 forceResetToActive: limpando estado antigo...');
      await clearSmokingState();
      
      final initialState = SmokingModuleState.initial().copyWith(
        isModuleActive: true,
        dailyCost: dailyCost,
        packCost: packCost,
      );
      
      await saveSmokingState(initialState);
      await syncWithSupabase(initialState);
      LoggerService.instance.gamification('✅ Estado resetado para ativo e sincronizado com Supabase: isModuleActive=true, dailyCost=$dailyCost');
    } catch (e) {
      LoggerService.instance.e('Erro ao forçar reset do estado', error: e);
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
      entity.isModuleActive = state.isModuleActive;
      entity.touch();
      
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        await supabase.from('smoking_gamification_states').upsert({
          'user_id': userId,
          'state_data': entity.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
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
          LoggerService.instance.gamification('🌐 Supabase: isModuleActive=${entity.isModuleActive}, dailyCost=${entity.dailyCost}');
          
          // Converte diretamente da entidade para o estado do módulo
          return SmokingModuleState(
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            earnedInsignias: entity.earnedInsigniasList,
            earnedMedalhas: entity.earnedMedalhasList,
            consecutivePositiveDays: entity.consecutivePositiveDays,
            disciplinumCount: entity.disciplinumCount,
            lastPositiveCheckIn: entity.lastPositiveCheckIn,
            startDate: entity.startDate,
            dailyCost: entity.dailyCost,
            packCost: entity.packCost,
            isModuleActive: entity.isModuleActive,
          );
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
