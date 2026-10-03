import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_gamification_entity.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';
import 'package:objectbox/objectbox.dart';

/// Repositório ObjectBox para gamificação do módulo Focus (100% Local-First)
class FocusGamificationRepository {
  static FocusGamificationRepository? _instance;
  static FocusGamificationRepository get instance => _instance ??= FocusGamificationRepository._();
  
  FocusGamificationRepository._();

  Box<FocusGamificationEntity> get _box => ObjectBoxService.instance.store.box<FocusGamificationEntity>();

  /// Salva o estado completo do módulo Focus
  Future<void> saveFocusState(FocusModuleState state) async {
    try {
      // Converte FocusModuleState para FocusGamificationEntity
      final entity = FocusGamificationEntity();
      entity.earnedInsigniasList = state.earnedInsignias;
      entity.earnedMedalhasList = state.earnedMedalhas;
      entity.disciplinumCount = state.respectedPeriods.length;
      entity.touch();
      
      // Salva no ObjectBox com ID fixo 1
      entity.id = 1;
      _box.put(entity);
      LoggerService.instance.gamification('✅ Estado Focus salvo com ObjectBox');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Focus com ObjectBox', error: e);
    }
  }

  /// Carrega o estado salvo do módulo Focus
  Future<FocusModuleState?> getFocusState() async {
    try {
      final entity = _box.get(1);
      
      if (entity != null) {
        final jsonData = entity.toJson();
        final newState = FocusModuleState.fromJson(jsonData);
        
        LoggerService.instance.gamification('✅ Estado Focus carregado com ObjectBox');
        return newState;
      }
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Focus com ObjectBox', error: e);
      return null;
    }
  }

  /// Limpa o estado salvo
  Future<void> clearFocusState() async {
    try {
      _box.removeAll();
      LoggerService.instance.gamification('🗑️ Estado Focus limpo com ObjectBox');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Focus com ObjectBox', error: e);
    }
  }

  /// Verifica se existe estado salvo
  Future<bool> hasFocusState() async {
    try {
      final count = _box.count();
      return count > 0;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado Focus com ObjectBox', error: e);
      return false;
    }
  }

  /// Obtém metadados do estado
  Future<Map<String, dynamic>?> getStateMetadata() async {
    try {
      return {
        'hasState': await hasFocusState(),
        'storageType': 'ObjectBox',
        'version': '1.0',
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter metadados do estado Focus', error: e);
      return null;
    }
  }

  /// Sincronização completa (100% local)
  Future<FocusModuleState> performFullSync() async {
    try {
      final localState = await getFocusState();
      if (localState != null) {
        return localState;
      }
      
      LoggerService.instance.gamification('Criando estado inicial Focus');
      final initialState = FocusModuleState.initial();
      await saveFocusState(initialState);
      return initialState;
    } catch (e) {
      LoggerService.instance.e('Erro na inicialização Focus', error: e);
      return FocusModuleState.initial();
    }
  }

  /// Inicializa o repositório
  Future<void> initialize() async {
    LoggerService.instance.gamification('FocusGamificationRepository inicializado');
  }
}
