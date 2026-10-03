import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório 100% Local-First para configurações de Procrastination usando ObjectBox
class ProcrastinationConfigRepository {
  static ProcrastinationConfigRepository? _instance;
  static ProcrastinationConfigRepository get instance => _instance ??= ProcrastinationConfigRepository._internal();
  
  ProcrastinationConfigRepository._internal();

  static const String _defaultUserId = 'local_user';

  Box<ProcrastinationConfigEntity> get _box => ObjectBoxService.instance.store.box<ProcrastinationConfigEntity>();

  Future<ProcrastinationConfigEntity?> getConfig() async {
    try {
      final query = _box.query(ProcrastinationConfigEntity_.userId.equals(_defaultUserId)).build();
      final result = query.findFirst();
      query.close();
      return result ?? _box.getAll().firstOrNull;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Procrastination', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(ProcrastinationConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Procrastination salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
         _box.remove(existingConfig.id);
      }
      
      LoggerService.instance.i('Configuração do Procrastination removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Procrastination foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<ProcrastinationConfigEntity> getOrCreateConfig([String userId = _defaultUserId]) async {
    try {
      final existing = await getConfig();
      if (existing != null) return existing;
      
      final newConfig = ProcrastinationConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro ao criar config do Procrastination', error: e);
      return ProcrastinationConfigEntity(userId: userId);
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getOrCreateConfig(userId);
      final updated = config.copyWith(isModuleActive: isActive);
      await saveConfig(updated);
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar status do Procrastination', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar status do Procrastination', error: e);
      return false;
    }
  }

  Future<ProcrastinationConfigEntity> performFullSync() async {
    return await getOrCreateConfig();
  }
}
