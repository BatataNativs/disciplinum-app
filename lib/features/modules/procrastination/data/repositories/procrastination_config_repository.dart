import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Procrastination usando Isar puro
class ProcrastinationConfigRepository {
  static ProcrastinationConfigRepository? _instance;
  static ProcrastinationConfigRepository get instance => _instance ??= ProcrastinationConfigRepository._internal();
  
  ProcrastinationConfigRepository._internal();

  Future<ProcrastinationConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.procrastinationConfigEntitys
          .filter()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Procrastination', error: e);
      return null;
    }
  }

  Future<void> saveConfig(ProcrastinationConfigEntity config) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        config.touch();
        await isar.procrastinationConfigEntitys.put(config);
      });
      
      LoggerService.instance.i('Configuração do Procrastination salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Procrastination', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.procrastinationConfigEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Configuração do Procrastination removida com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover configuração do Procrastination', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.procrastinationConfigEntitys.clear();
      });
      
      LoggerService.instance.i('Todas as configurações do Procrastination foram limpas');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar configurações do Procrastination', error: e);
      rethrow;
    }
  }
}
