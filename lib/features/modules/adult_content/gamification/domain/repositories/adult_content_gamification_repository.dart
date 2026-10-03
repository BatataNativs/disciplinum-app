import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_module_state.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/entities/adult_content_gamification_entity.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Adult Content
/// Implementa persistência local com ObjectBox (100% local)
class AdultContentGamificationRepository {
  static AdultContentGamificationRepository? _instance;
  static AdultContentGamificationRepository get instance => _instance ??= AdultContentGamificationRepository._();
  
  AdultContentGamificationRepository._();

  Box<AdultContentGamificationEntity> get _box => ObjectBoxService.instance.store.box<AdultContentGamificationEntity>();

  /// Salva o estado localmente usando ObjectBox
  Future<void> saveAdultContentState(AdultContentModuleState state) async {
    try {
      final entity = AdultContentGamificationEntity.fromModuleState('adult_content_user', state);
      
      final existing = await getAdultContentState();
      if (existing != null) {
        final existingEntity = _box.get(1);
        if (existingEntity != null) {
          entity.id = existingEntity.id;
        } else {
          entity.id = 1;
        }
      } else {
        entity.id = 1;
      }
      
      _box.put(entity);
      
      LoggerService.instance.gamification('Estado Adult Content salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Adult Content com ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega o estado salvo localmente
  Future<AdultContentModuleState?> getAdultContentState() async {
    try {
      final entity = _box.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        final stateMap = entity.toModuleStateMap();
        LoggerService.instance.gamification('Estado Adult Content carregado do ObjectBox');
        return AdultContentModuleState.fromJson(stateMap);
      }
      
      LoggerService.instance.gamification('Estado Adult Content não encontrado no ObjectBox');
      return null;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar estado Adult Content do ObjectBox', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Limpa o estado local
  Future<void> clearAdultContentState() async {
    try {
      _box.removeAll();
      LoggerService.instance.gamification('Estado Adult Content limpo do ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar estado Adult Content do ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Sincronização completa (100% local)
  Future<AdultContentModuleState> performFullSync() async {
    try {
      AdultContentModuleState? localState = await getAdultContentState();
      if (localState != null) {
        return localState;
      }
      
      LoggerService.instance.gamification('Criando estado inicial Adult Content');
      final initialState = AdultContentModuleState.initial();
      await saveAdultContentState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na inicialização Adult Content', error: e);
      return AdultContentModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = AdultContentModuleState.initial();
      await saveAdultContentState(resetState);
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
          'isModuleActive': false,
          'lastUpdated': DateTime.now().toIso8601String(),
          'version': '1.0',
        };
      }
      
      return {
        'consecutiveDays': state.consecutiveDays,
        'disciplinumCount': state.disciplinumCount,
        'earnedInsignias': state.earnedInsignias,
        'earnedMedalhas': state.earnedMedalhas,
        'isModuleActive': state.isModuleActive,
        'lastUpdated': state.updatedAt.toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Adult Content', error: e);
      return {
        'consecutiveDays': 0,
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
    LoggerService.instance.gamification('AdultContentGamificationRepository inicializado');
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

  /// Força sincronização manual (100% local)
  Future<bool> forceSync() async {
    return true;
  }

  /// Limpa todos os dados locais
  Future<void> clearAllData() async {
    await clearAdultContentState();
    LoggerService.instance.gamification('Todos os dados Adult Content limpos');
  }
}
