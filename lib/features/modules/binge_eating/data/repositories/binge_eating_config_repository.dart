import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório específico para configurações de BingeEating usando ObjectBox (100% local)
class BingeEatingConfigRepository {
  static const String _defaultUserId = 'local_user';
  static BingeEatingConfigRepository? _instance;
  static BingeEatingConfigRepository get instance => _instance ??= BingeEatingConfigRepository._internal();
  
  BingeEatingConfigRepository._internal();

  Box<BingeEatingConfigEntity> get _box => ObjectBoxService.instance.store.box<BingeEatingConfigEntity>();

  Future<BingeEatingConfigEntity?> getConfig() async {
    try {
      final existing = _box.query(BingeEatingConfigEntity_.userId.equals(_defaultUserId)).build().findFirst();
      if (existing != null) return existing;
      return _box.getAll().firstOrNull;
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

  // ===== SINCRONIZAÇÃO (100% Local) =====

  /// Sincronização completa (100% local)
  Future<BingeEatingConfigEntity> performFullSync() async {
    try {
      BingeEatingConfigEntity? localConfig = await getConfig();
      if (localConfig != null) {
        return localConfig;
      }
      
      final newConfig = BingeEatingConfigEntity(userId: _defaultUserId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização BingeEating', error: e);
      return BingeEatingConfigEntity(userId: _defaultUserId);
    }
  }
}
