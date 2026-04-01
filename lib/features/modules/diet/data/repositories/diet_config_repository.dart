import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Diet usando Isar puro
class DietConfigRepository {
  static DietConfigRepository? _instance;
  static DietConfigRepository get instance => _instance ??= DietConfigRepository._internal();
  
  DietConfigRepository._internal();

  Future<DietConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.dietConfigEntitys
          .filter()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Diet', error: e);
      return null;
    }
  }

  Future<void> saveConfig(DietConfigEntity config) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        // Verificar se já existe uma configuração com o mesmo userId
        final existingConfig = await isar.dietConfigEntitys
            .filter()
            .userIdEqualTo(config.userId)
            .findFirst();
        
        if (existingConfig != null) {
          // Reutilizar o ID interno do Isar para atualizar em vez de criar nova
          config.id = existingConfig.id;
        }
        
        config.touch();
        await isar.dietConfigEntitys.put(config);
      });
      
      LoggerService.instance.i('Configuração do Diet salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Diet', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.dietConfigEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Configuração do Diet removida com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover configuração do Diet', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.dietConfigEntitys.clear();
      });
      
      LoggerService.instance.i('Todas as configurações do Diet foram limpas');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar configurações do Diet', error: e);
      rethrow;
    }
  }
}
