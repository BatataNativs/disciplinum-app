import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Reading usando Isar puro
class ReadingConfigRepository {
  static ReadingConfigRepository? _instance;
  static ReadingConfigRepository get instance => _instance ??= ReadingConfigRepository._internal();
  
  ReadingConfigRepository._internal();

  Future<ReadingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.readingConfigEntitys
          .filter()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Reading', error: e);
      return null;
    }
  }

  Future<void> saveConfig(ReadingConfigEntity config) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        // Verificar se já existe uma configuração com o mesmo userId
        final existingConfig = await isar.readingConfigEntitys
            .filter()
            .userIdEqualTo(config.userId)
            .findFirst();
        
        if (existingConfig != null) {
          // Reutilizar o ID interno do Isar para atualizar em vez de criar nova
          config.id = existingConfig.id;
        }
        
        config.touch();
        await isar.readingConfigEntitys.put(config);
      });
      
      LoggerService.instance.i('Configuração do Reading salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Reading', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.readingConfigEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Configuração do Reading removida com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover configuração do Reading', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.readingConfigEntitys.clear();
      });
      
      LoggerService.instance.i('Todas as configurações do Reading foram limpas');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar configurações do Reading', error: e);
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
