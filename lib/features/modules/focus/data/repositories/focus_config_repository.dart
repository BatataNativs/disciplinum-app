import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Focus usando Isar puro
class FocusConfigRepository {
  static FocusConfigRepository? _instance;
  static FocusConfigRepository get instance => _instance ??= FocusConfigRepository._internal();
  
  FocusConfigRepository._internal();

  Future<FocusConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.focusConfigEntitys
          .filter()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Focus', error: e);
      return null;
    }
  }

  Future<void> saveConfig(FocusConfigEntity config) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        config.touch();
        await isar.focusConfigEntitys.put(config);
      });
      
      LoggerService.instance.i('Configuração do Focus salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Focus', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.focusConfigEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Configuração do Focus removida com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover configuração do Focus', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.focusConfigEntitys.clear();
      });
      
      LoggerService.instance.i('Todas as configurações do Focus foram limpas');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar configurações do Focus', error: e);
      rethrow;
    }
  }
}
