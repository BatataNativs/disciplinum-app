import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório específico para configurações de Diet usando ObjectBox (100% local)
class DietConfigRepository {
  static const String _defaultUserId = 'local_user';
  static DietConfigRepository? _instance;
  static DietConfigRepository get instance => _instance ??= DietConfigRepository._internal();
  
  DietConfigRepository._internal();

  Box<DietConfigEntity> get _box => ObjectBoxService.instance.store.box<DietConfigEntity>();

  Future<DietConfigEntity?> getConfig() async {
    try {
      final existing = _box.query(DietConfigEntity_.userId.equals(_defaultUserId)).build().findFirst();
      if (existing != null) return existing;
      return _box.getAll().firstOrNull;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Diet', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(DietConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Diet salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Diet', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }
      LoggerService.instance.i('Configuração do Diet removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Diet', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Diet foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Diet', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== SINCRONIZAÇÃO (100% Local) =====

  /// Sincronização completa (100% local)
  Future<DietConfigEntity> performFullSync() async {
    try {
      DietConfigEntity? localConfig = await getConfig();
      if (localConfig != null) {
        return localConfig;
      }
      
      final newConfig = DietConfigEntity(userId: _defaultUserId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização Diet', error: e);
      return DietConfigEntity(userId: _defaultUserId);
    }
  }
}
