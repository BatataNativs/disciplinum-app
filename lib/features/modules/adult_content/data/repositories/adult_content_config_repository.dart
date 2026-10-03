import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório específico para configurações de Adult Content usando ObjectBox (100% local)
class AdultContentConfigRepository {
  static const String _defaultUserId = 'local_user';
  static AdultContentConfigRepository? _instance;
  static AdultContentConfigRepository get instance => _instance ??= AdultContentConfigRepository._internal();
  
  AdultContentConfigRepository._internal();

  Box<AdultContentConfigEntity> get _box => ObjectBoxService.instance.store.box<AdultContentConfigEntity>();

  Future<AdultContentConfigEntity?> getConfig() async {
    try {
      final existing = _box.query(AdultContentConfigEntity_.userId.equals(_defaultUserId)).build().findFirst();
      if (existing != null) return existing;
      return _box.getAll().firstOrNull;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Adult Content', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(AdultContentConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      
      config.touch();
      _box.put(config);
      
      LoggerService.instance.i('Configuração do Adult Content salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Adult Content', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }
      
      LoggerService.instance.i('Configuração do Adult Content removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Adult Content', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Adult Content foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Adult Content', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== SINCRONIZAÇÃO (100% Local) =====

  /// Sincronização completa (100% local)
  Future<AdultContentConfigEntity> performFullSync() async {
    try {
      AdultContentConfigEntity? localConfig = await getConfig();
      if (localConfig != null) {
        return localConfig;
      }
      
      final newConfig = AdultContentConfigEntity(userId: _defaultUserId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização Adult Content', error: e);
      return AdultContentConfigEntity(userId: _defaultUserId);
    }
  }
}
