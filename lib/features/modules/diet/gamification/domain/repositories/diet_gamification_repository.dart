import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_module_state.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/entities/diet_gamification_entity.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Dieta
/// Implementa persistência local com ObjectBox (100% local)
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

  /// Sincronização completa (100% local)
  Future<DietModuleState> performFullSync() async {
    try {
      final localState = await getDietState();
      if (localState != null) {
        return localState;
      }

      final defaultState = DietModuleState(
        earnedInsignias: [],
        earnedMedalhas: [],
        consecutiveDays: 0,
        disciplinumCount: 0,
        isModuleActive: false,
      );

      await saveDietState(defaultState);
      return defaultState;
    } catch (e) {
      LoggerService.instance.e('Erro na inicialização do estado Dieta', error: e);
      return DietModuleState(
        earnedInsignias: [],
        earnedMedalhas: [],
        consecutiveDays: 0,
        disciplinumCount: 0,
        isModuleActive: false,
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
          isModuleActive: false,
        );
        
        await saveDietState(resetState);
        LoggerService.instance.gamification('Progresso do módulo Dieta resetado');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar progresso do módulo Dieta', error: e);
    }
  }
}
