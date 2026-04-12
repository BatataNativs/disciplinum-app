import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Reading usando ObjectBox
class ReadingConfigRepository {
  static ReadingConfigRepository? _instance;
  static ReadingConfigRepository get instance => _instance ??= ReadingConfigRepository._internal();
  
  ReadingConfigRepository._internal();

  Box<ReadingConfigEntity> get _box => ObjectBoxService.instance.store.box<ReadingConfigEntity>();

  Future<ReadingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      return _box.query(ReadingConfigEntity_.userId.equals(userId)).build().findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Reading', error: e);
      return null;
    }
  }

  Future<void> saveConfig(ReadingConfigEntity config) async {
    try {
      // Verificar se já existe uma configuração com o mesmo userId
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
      LoggerService.instance.e('Erro ao carregar todas as configurações do Reading', error: e);
      return [];
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getConfig();
      if (config != null) {
        final updatedConfig = config.copyWith(isModuleActive: isActive);
        await saveConfig(updatedConfig);
      } else {
        final newConfig = ReadingConfigEntity(userId: userId, isModuleActive: isActive);
        await saveConfig(newConfig);
      }
      LoggerService.instance.i('Estado do módulo Reading atualizado: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado do módulo Reading', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado do módulo Reading', error: e);
      return false;
    }
  }
}
