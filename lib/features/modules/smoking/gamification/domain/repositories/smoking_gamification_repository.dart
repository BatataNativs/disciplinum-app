import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_gamification_entity.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório ObjectBox para gamificação do módulo Smoking (100% Local-First)
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
        
        // NOTA: Removida a "correção automática" que forçava isModuleActive=true quando dailyCost > 0
        // O usuário pode ter configurado o custo e depois desativado o módulo - esse estado é válido!
        // Respeitamos a preferência do usuário: se ele desativou, permanece desativado.
        
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
        earnedInsignias: const ['madeira'],
      );
      
      await saveSmokingState(initialState);
      LoggerService.instance.gamification('✅ Estado resetado para ativo: isModuleActive=true, dailyCost=$dailyCost, insignias=[madeira]');
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

  /// Inicializa o repositório
  Future<void> initialize() async {
    LoggerService.instance.gamification('SmokingGamificationRepository inicializado (100% Local-First)');
  }

  /// Retorna dados de gamificação para notificações motivacionais
  /// 
  /// Retorna um mapa com:
  /// - insignias: Lista de IDs de insígnias conquistadas
  /// - medalhas: Lista de IDs de medalhas conquistadas
  /// - consecutiveDays: Dias consecutivos sem fumar
  Future<Map<String, dynamic>?> getGamificationData() async {
    try {
      final state = await getSmokingState();
      if (state == null) return null;

      return {
        'insignias': state.earnedInsignias,
        'medalhas': state.earnedMedalhas,
        'consecutiveDays': state.consecutivePositiveDays,
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar dados de gamificação', error: e);
      return null;
    }
  }
}
