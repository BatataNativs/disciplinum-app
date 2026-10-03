import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_module_state.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/entities/procrastination_gamification_entity.dart';

/// Repositório 100% Local-First com ObjectBox para Procrastinação
class ProcrastinationGamificationRepository {
  static ProcrastinationGamificationRepository? _instance;
  static ProcrastinationGamificationRepository get instance => _instance ??= ProcrastinationGamificationRepository._();
  
  ProcrastinationGamificationRepository._();

  Box<ProcrastinationGamificationEntity> get _box => ObjectBoxService.instance.store.box<ProcrastinationGamificationEntity>();

  /// Salva o estado localmente usando ObjectBox
  Future<void> saveProcrastinationState(ProcrastinationModuleState state) async {
    try {
      final entity = ProcrastinationGamificationEntity.fromModuleState('local_user', state);
      
      final existingEntity = _box.get(1);
      if (existingEntity != null) {
        entity.id = existingEntity.id;
      } else {
        entity.id = 1;
      }
      
      _box.put(entity);
      
      LoggerService.instance.gamification('Estado Procrastination salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Procrastination com ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega o estado salvo localmente
  Future<ProcrastinationModuleState?> getProcrastinationState() async {
    try {
      final entity = _box.get(1);
      
      if (entity != null) {
        final state = entity.toModuleState();
        LoggerService.instance.gamification('Estado Procrastination carregado do ObjectBox');
        return state;
      }
      
      LoggerService.instance.gamification('Estado Procrastination não encontrado no ObjectBox');
      return null;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar estado Procrastination do ObjectBox', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Limpa o estado local
  Future<void> clearProcrastinationState() async {
    try {
      _box.removeAll();
      LoggerService.instance.gamification('Estado Procrastination limpo do ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar estado Procrastination do ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Sincronização local completa
  Future<ProcrastinationModuleState> performFullSync() async {
    try {
      ProcrastinationModuleState? localState = await getProcrastinationState();
      if (localState != null) {
        return localState;
      }
      
      LoggerService.instance.gamification('Criando estado inicial Procrastination');
      final initialState = ProcrastinationModuleState.initial();
      await saveProcrastinationState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na inicialização Procrastination', error: e);
      return ProcrastinationModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = ProcrastinationModuleState.initial();
      await saveProcrastinationState(resetState);
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
          'isModuleActive': false,
          'lastUpdated': DateTime.now().toIso8601String(),
          'version': '1.0',
        };
      }
      
      return {
        'disciplinumCount': state.disciplinumCount,
        'earnedInsignias': state.earnedInsignias,
        'earnedMedalhas': state.earnedMedalhas,
        'isModuleActive': state.isModuleActive,
        'lastUpdated': state.updatedAt.toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Procrastination', error: e);
      return {
        'disciplinumCount': 0,
        'earnedInsignias': [],
        'earnedMedalhas': [],
        'isModuleActive': false,
        'lastUpdated': DateTime.now().toIso8601String(),
        'version': '1.0',
        'error': e.toString(),
      };
    }
  }

  /// Inicializa o repositório
  Future<void> initialize() async {
    LoggerService.instance.gamification('ProcrastinationGamificationRepository inicializado localmente');
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

  /// Força sincronização
  Future<bool> forceSync() async {
    return true;
  }

  /// Limpa todos os dados
  Future<void> clearAllData() async {
    await clearProcrastinationState();
  }
}
