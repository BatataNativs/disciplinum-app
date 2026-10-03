import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_gamification_entity.dart';

/// Repositório 100% Local-First com ObjectBox para Gamificação do Money Saving Challenge
class MoneySavingGamificationRepository {
  static MoneySavingGamificationRepository? _instance;
  static MoneySavingGamificationRepository get instance => _instance ??= MoneySavingGamificationRepository._();
  
  MoneySavingGamificationRepository._();

  Box<MoneySavingGamificationEntity> get _box => ObjectBoxService.instance.store.box<MoneySavingGamificationEntity>();

  /// Salva o estado localmente usando ObjectBox
  Future<void> saveMoneySavingState(MoneySavingModuleState state) async {
    try {
      final entity = MoneySavingGamificationEntity.fromModuleState(state);
      
      final existingEntity = _box.get(1);
      if (existingEntity != null) {
        entity.id = existingEntity.id;
      } else {
        entity.id = 1;
      }
      entity.userId = 'local_user';
      
      _box.put(entity);
      
      LoggerService.instance.gamification('Estado Money Saving salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Money Saving com ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega o estado salvo localmente
  Future<MoneySavingModuleState?> getMoneySavingState() async {
    try {
      final entity = _box.get(1);
      
      if (entity != null) {
        final state = entity.toModuleState();
        LoggerService.instance.gamification('Estado Money Saving carregado do ObjectBox');
        return state;
      }
      
      LoggerService.instance.gamification('Estado Money Saving não encontrado no ObjectBox');
      return null;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar estado Money Saving do ObjectBox', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Limpa todos os dados locais
  Future<void> clearMoneySavingState() async {
    try {
      _box.removeAll();
      LoggerService.instance.gamification('Estado Money Saving limpo do ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar estado Money Saving do ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Sincronização local completa
  Future<MoneySavingModuleState> performFullSync() async {
    try {
      MoneySavingModuleState? localState = await getMoneySavingState();
      if (localState != null) {
        return localState;
      }
      
      LoggerService.instance.gamification('Criando estado inicial Money Saving');
      final initialState = MoneySavingModuleState.initial();
      await saveMoneySavingState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na inicialização Money Saving', error: e);
      return MoneySavingModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = MoneySavingModuleState.initial();
      await saveMoneySavingState(resetState);
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
        'storageType': 'ObjectBox',
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Money Saving', error: e);
      return {
        'hasState': false,
        'storageType': 'ObjectBox',
        'version': '1.0',
        'error': e.toString(),
      };
    }
  }

  /// Inicializa o repositório
  Future<void> initialize() async {
    LoggerService.instance.gamification('MoneySavingGamificationRepository inicializado localmente');
  }
}
