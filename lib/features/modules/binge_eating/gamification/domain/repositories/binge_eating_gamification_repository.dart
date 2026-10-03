import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_module_state.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_gamification_entity.dart';

/// Repositório para gerenciar o estado de gamificação do módulo Binge Eating
/// Implementa persistência local com ObjectBox (100% local)
class BingeEatingGamificationRepository {
  static BingeEatingGamificationRepository? _instance;
  static BingeEatingGamificationRepository get instance => _instance ??= BingeEatingGamificationRepository._();
  
  BingeEatingGamificationRepository._();

  Box<BingeEatingGamificationEntity> get _box => ObjectBoxService.instance.store.box<BingeEatingGamificationEntity>();

  /// Salva o estado localmente usando ObjectBox
  Future<void> saveBingeEatingState(BingeEatingModuleState state) async {
    try {
      final entity = BingeEatingGamificationEntity.fromModuleState('binge_eating_user', state);
      
      final existing = await getBingeEatingState();
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
      
      LoggerService.instance.gamification('Estado Binge Eating salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Binge Eating com ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega o estado salvo localmente
  Future<BingeEatingModuleState?> getBingeEatingState() async {
    try {
      final entity = _box.get(1); // Pega o primeiro registro (id=1)
      
      if (entity != null) {
        LoggerService.instance.gamification('Estado Binge Eating carregado do ObjectBox');
        return entity.toModuleState();
      }
      
      LoggerService.instance.gamification('Estado Binge Eating não encontrado no ObjectBox');
      return null;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar estado Binge Eating do ObjectBox', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Limpa o estado local
  Future<void> clearBingeEatingState() async {
    try {
      _box.removeAll();
      LoggerService.instance.gamification('Estado Binge Eating limpo do ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar estado Binge Eating do ObjectBox', error: e, stackTrace: stackTrace);
    }
  }

  /// Sincronização completa (100% local)
  Future<BingeEatingModuleState> performFullSync() async {
    try {
      BingeEatingModuleState? localState = await getBingeEatingState();
      if (localState != null) {
        return localState;
      }
      
      LoggerService.instance.gamification('Criando estado inicial Binge Eating');
      final initialState = BingeEatingModuleState.initial();
      await saveBingeEatingState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na inicialização Binge Eating', error: e);
      return BingeEatingModuleState.initial();
    }
  }

  /// Reseta o progresso do módulo
  Future<void> resetProgress() async {
    try {
      final resetState = BingeEatingModuleState.initial();
      await saveBingeEatingState(resetState);
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
          'isModuleActive': false,
          'lastUpdated': DateTime.now().toIso8601String(),
          'version': '1.0',
        };
      }
      
      return {
        'consecutivePositiveDays': state.consecutivePositiveDays,
        'disciplinumCount': state.disciplinumCount,
        'earnedInsignias': state.earnedInsignias,
        'earnedMedalhas': state.earnedMedalhas,
        'isModuleActive': state.isModuleActive,
        'lastUpdated': state.updatedAt.toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatísticas Binge Eating', error: e);
      return {
        'consecutivePositiveDays': 0,
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
    LoggerService.instance.gamification('BingeEatingGamificationRepository inicializado');
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

  /// Força sincronização manual (100% local)
  Future<bool> forceSync() async {
    return true;
  }

  /// Limpa todos os dados locais
  Future<void> clearAllData() async {
    await clearBingeEatingState();
    LoggerService.instance.gamification('Todos os dados Binge Eating limpos');
  }
}
