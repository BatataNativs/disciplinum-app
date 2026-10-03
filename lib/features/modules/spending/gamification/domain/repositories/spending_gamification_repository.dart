import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_module_state.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/entities/spending_gamification_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Spending
/// Implementa persistência 100% local com ObjectBox
class SpendingGamificationRepository {
  static SpendingGamificationRepository? _instance;
  static SpendingGamificationRepository get instance => _instance ??= SpendingGamificationRepository._();

  SpendingGamificationRepository._();

  Box<SpendingGamificationEntity>? _box;

  Box<SpendingGamificationEntity> get box {
    _box ??= ObjectBoxService.instance.store.box<SpendingGamificationEntity>();
    return _box!;
  }

  /// Salva o estado localmente usando ObjectBox
  Future<void> saveSpendingState(SpendingModuleState state) async {
    try {
      const userId = 'local_user';
      final entity = SpendingGamificationEntity.fromModuleState(userId, state);
      
      final existingEntity = box.get(1);
      if (existingEntity != null) {
        entity.id = existingEntity.id;
      } else {
        entity.id = 1;
      }

      box.put(entity);

      LoggerService.instance.gamification('Estado Spending salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Spending com ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega o estado salvo localmente
  Future<SpendingModuleState?> getSpendingState() async {
    try {
      final entity = box.get(1);
      
      if (entity != null) {
        final stateMap = entity.toModuleStateMap();
        LoggerService.instance.gamification('Estado Spending carregado do ObjectBox');
        return SpendingModuleState.fromJson(stateMap);
      }
      
      LoggerService.instance.gamification('Estado Spending não encontrado no ObjectBox');
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Spending do ObjectBox', error: e);
      return null;
    }
  }

  /// Limpa o estado local
  Future<void> clearSpendingState() async {
    try {
      box.removeAll();
      LoggerService.instance.gamification('Estado Spending limpo do ObjectBox');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Spending do ObjectBox', error: e);
    }
  }

  /// Sincronização local completa
  Future<SpendingModuleState> performFullSync() async {
    try {
      SpendingModuleState? localState = await getSpendingState();
      if (localState != null) {
        return localState;
      }
      
      LoggerService.instance.gamification('Criando estado inicial Spending');
      final initialState = SpendingModuleState.initial();
      await saveSpendingState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na inicialização Spending', error: e);
      return SpendingModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = SpendingModuleState.initial();
      await saveSpendingState(resetState);
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
          'isModuleActive': false,
          'lastUpdated': DateTime.now().toIso8601String(),
          'version': '1.0',
        };
      }
      
      return {
        'consecutiveMonths': state.consecutiveMonths,
        'disciplinumCount': state.disciplinumCount,
        'earnedInsignias': state.earnedInsignias,
        'earnedMedalhas': state.earnedMedalhas,
        'isModuleActive': state.isModuleActive,
        'lastUpdated': state.updatedAt.toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Spending', error: e);
      return {
        'consecutiveMonths': 0,
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
    LoggerService.instance.gamification('SpendingGamificationRepository inicializado localmente');
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

  /// Força sincronização local
  Future<bool> forceSync() async {
    return true;
  }

  /// Limpa todos os dados
  Future<void> clearAllData() async {
    await clearSpendingState();
  }
}
