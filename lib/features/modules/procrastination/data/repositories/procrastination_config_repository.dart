import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Procrastination usando ObjectBox
class ProcrastinationConfigRepository {
  static ProcrastinationConfigRepository? _instance;
  static ProcrastinationConfigRepository get instance => _instance ??= ProcrastinationConfigRepository._internal();
  
  ProcrastinationConfigRepository._internal();

  Box<ProcrastinationConfigEntity> get _box => ObjectBoxService.instance.store.box<ProcrastinationConfigEntity>();

  Future<ProcrastinationConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final query = _box.query(ProcrastinationConfigEntity_.userId.equals(userId)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Procrastination', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(ProcrastinationConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Procrastination salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
         _box.remove(existingConfig.id);
      }
      
      LoggerService.instance.i('Configuração do Procrastination removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Procrastination foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Procrastination', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
