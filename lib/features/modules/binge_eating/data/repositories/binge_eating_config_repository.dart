import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de BingeEating usando ObjectBox
class BingeEatingConfigRepository {
  static BingeEatingConfigRepository? _instance;
  static BingeEatingConfigRepository get instance => _instance ??= BingeEatingConfigRepository._internal();
  
  BingeEatingConfigRepository._internal();

  Box<BingeEatingConfigEntity> get _box => ObjectBoxService.instance.store.box<BingeEatingConfigEntity>();

  Future<BingeEatingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return _box.query(BingeEatingConfigEntity_.userId.equals(userId)).build().findFirst();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do BingeEating', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(BingeEatingConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      config.touch();
      _box.put(config);
      LoggerService.instance.i('Configuração do BingeEating salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do BingeEating', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }
      LoggerService.instance.i('Configuração do BingeEating removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do BingeEating', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do BingeEating foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do BingeEating', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
