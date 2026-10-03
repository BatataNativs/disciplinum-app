import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório 100% Local-First para configurações de Money Saving usando ObjectBox
class MoneySavingConfigRepository {
  static MoneySavingConfigRepository? _instance;
  static MoneySavingConfigRepository get instance => _instance ??= MoneySavingConfigRepository._internal();
  
  MoneySavingConfigRepository._internal();

  static const String _defaultUserId = 'local_user';

  Box<MoneySavingConfigEntity> get _box => ObjectBoxService.instance.store.box<MoneySavingConfigEntity>();

  Future<MoneySavingConfigEntity?> getConfig() async {
    try {
      final query = _box.query(MoneySavingConfigEntity_.userId.equals(_defaultUserId)).build();
      final result = query.findFirst();
      query.close();
      return result ?? _box.getAll().firstOrNull;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Money Saving', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(MoneySavingConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Money Saving salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Money Saving', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
         _box.remove(existingConfig.id);
      }
      
      LoggerService.instance.i('Configuração do Money Saving removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Money Saving', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Money Saving foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Money Saving', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<MoneySavingConfigEntity> getOrCreateConfig([String userId = _defaultUserId]) async {
    try {
      final existing = await getConfig();
      if (existing != null) return existing;
      
      final newConfig = MoneySavingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro ao criar config do Money Saving', error: e);
      return MoneySavingConfigEntity(userId: userId);
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getOrCreateConfig(userId);
      final updated = config.copyWith(isModuleActive: isActive);
      await saveConfig(updated);
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar status do Money Saving', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar status do Money Saving', error: e);
      return false;
    }
  }

  Future<MoneySavingConfigEntity> performFullSync() async {
    return await getOrCreateConfig();
  }
}
