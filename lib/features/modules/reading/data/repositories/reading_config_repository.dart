import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório 100% Local-First para configurações de Reading usando ObjectBox
class ReadingConfigRepository {
  static ReadingConfigRepository? _instance;
  static ReadingConfigRepository get instance => _instance ??= ReadingConfigRepository._internal();
  
  ReadingConfigRepository._internal();

  static const String _defaultUserId = 'local_user';

  Box<ReadingConfigEntity> get _box => ObjectBoxService.instance.store.box<ReadingConfigEntity>();

  Future<ReadingConfigEntity?> getConfig() async {
    try {
      final config = _box.query(ReadingConfigEntity_.userId.equals(_defaultUserId)).build().findFirst();
      return config ?? _box.getAll().firstOrNull;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Reading', error: e);
      return null;
    }
  }

  Future<void> saveConfig(ReadingConfigEntity config) async {
    try {
      final existingConfig = _box.query(ReadingConfigEntity_.userId.equals(config.userId)).build().findFirst();
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      _box.put(config);
      LoggerService.instance.i('Configuração do Reading salva');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Reading', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig(String userId) async {
    try {
      final existing = _box.query(ReadingConfigEntity_.userId.equals(userId)).build().findFirst();
      if (existing != null) {
        _box.remove(existing.id);
        LoggerService.instance.i('Configuração do Reading deletada');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao deletar configuração do Reading', error: e);
      rethrow;
    }
  }

  Future<List<ReadingConfigEntity>> getAllConfigs() async {
    try {
      return _box.getAll();
    } catch (e) {
      LoggerService.instance.e('Erro ao listar configurações do Reading', error: e);
      return [];
    }
  }

  Future<ReadingConfigEntity> getOrCreateConfig([String userId = _defaultUserId]) async {
    try {
      final existing = await getConfig();
      if (existing != null) return existing;
      final newConfig = ReadingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar ou criar config Reading', error: e);
      return ReadingConfigEntity(userId: userId);
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getOrCreateConfig(userId);
      final updated = config.copyWith(isModuleActive: isActive);
      await saveConfig(updated);
    } catch (e) {
      LoggerService.instance.e('Erro ao ativar/desativar módulo Reading', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar status do Reading', error: e);
      return false;
    }
  }

  Future<ReadingConfigEntity> performFullSync() async {
    return await getOrCreateConfig();
  }
}
