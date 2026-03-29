import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Adult Content usando Isar puro
class AdultContentConfigRepository {
  static AdultContentConfigRepository? _instance;
  static AdultContentConfigRepository get instance => _instance ??= AdultContentConfigRepository._internal();
  
  AdultContentConfigRepository._internal();

  Future<AdultContentConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.adultContentConfigEntitys
          .filter()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Adult Content', error: e);
      return null;
    }
  }

  Future<void> saveConfig(AdultContentConfigEntity config) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        config.touch();
        await isar.adultContentConfigEntitys.put(config);
      });
      
      LoggerService.instance.i('Configuração do Adult Content salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Adult Content', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.adultContentConfigEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Configuração do Adult Content removida com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover configuração do Adult Content', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.adultContentConfigEntitys.clear();
      });
      
      LoggerService.instance.i('Todas as configurações do Adult Content foram limpas');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar configurações do Adult Content', error: e);
      rethrow;
    }
  }
}
