import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de BingeEating usando Isar puro
class BingeEatingConfigRepository {
  static BingeEatingConfigRepository? _instance;
  static BingeEatingConfigRepository get instance => _instance ??= BingeEatingConfigRepository._internal();
  
  BingeEatingConfigRepository._internal();

  Future<BingeEatingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.bingeEatingConfigEntitys
          .filter()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do BingeEating', error: e);
      return null;
    }
  }

  Future<void> saveConfig(BingeEatingConfigEntity config) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        config.touch();
        await isar.bingeEatingConfigEntitys.put(config);
      });
      
      LoggerService.instance.i('Configuração do BingeEating salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do BingeEating', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.bingeEatingConfigEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Configuração do BingeEating removida com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover configuração do BingeEating', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.bingeEatingConfigEntitys.clear();
      });
      
      LoggerService.instance.i('Todas as configurações do BingeEating foram limpas');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar configurações do BingeEating', error: e);
      rethrow;
    }
  }
}
