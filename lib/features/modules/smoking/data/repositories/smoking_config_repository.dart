import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_config_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório específico para configurações de Smoking usando ObjectBox puro (100% Local-First)
class SmokingConfigRepository {
  static SmokingConfigRepository? _instance;
  static SmokingConfigRepository get instance => _instance ??= SmokingConfigRepository._internal();

  SmokingConfigRepository._internal();

  Box<SmokingConfigEntity>? _box;

  Box<SmokingConfigEntity> get box {
    _box ??= ObjectBoxService.instance.store.box<SmokingConfigEntity>();
    return _box!;
  }

  static const String _defaultUserId = 'local_user';

  Future<SmokingConfigEntity?> getConfig() async {
    try {
      final query = box.query(SmokingConfigEntity_.userId.equals(_defaultUserId)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Smoking', error: e);
      return null;
    }
  }

  Future<void> saveConfig(SmokingConfigEntity config) async {
    try {
      // Verificar se já existe uma configuração com o mesmo userId
      final query = box.query(SmokingConfigEntity_.userId.equals(config.userId)).build();
      final existingConfig = query.findFirst();
      query.close();

      if (existingConfig != null) {
        // Reutilizar o ID para atualizar em vez de criar nova
        config.id = existingConfig.id;
      }

      config.touch();
      box.put(config);

      LoggerService.instance.i('Configuração do Smoking salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Smoking', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final query = box.query(SmokingConfigEntity_.userId.equals(_defaultUserId)).build();
      final existing = query.findFirst();
      query.close();

      if (existing != null) {
        box.remove(existing.id);
      }

      LoggerService.instance.i('Configuração do Smoking removida com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover configuração do Smoking', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      box.removeAll();
      LoggerService.instance.i('Todas as configurações do Smoking foram limpas');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar configurações do Smoking', error: e);
      rethrow;
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getConfig();
      if (config != null) {
        final updatedConfig = config.copyWith(isModuleActive: isActive);
        await saveConfig(updatedConfig);
      } else {
        final newConfig = SmokingConfigEntity(userId: userId, isModuleActive: isActive);
        await saveConfig(newConfig);
      }
      LoggerService.instance.i('Estado do módulo Smoking atualizado: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado do módulo Smoking', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado do módulo Smoking', error: e);
      return false;
    }
  }

  // ===== SINCRONIZAÇÃO (100% Local-First) =====

  /// Retorna a configuração local
  Future<SmokingConfigEntity> performFullSync() async {
    final localConfig = await getConfig();
    if (localConfig != null) {
      return localConfig;
    }
    final newConfig = SmokingConfigEntity(userId: _defaultUserId);
    await saveConfig(newConfig);
    return newConfig;
  }
}
