import 'package:disciplinum/features/modules/digital_detox/data/repositories/digital_detox_config_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_sync_service.dart';

/// ServiÃ§o local de acesso Ã s configuraÃ§Ãµes do Jejum Digital
/// Abstrai o repository para facilitar testes e manutenÃ§Ã£o
class DigitalDetoxServiceLocal {
  static DigitalDetoxServiceLocal? _instance;
  static DigitalDetoxServiceLocal get instance => _instance ??= DigitalDetoxServiceLocal._internal();

  DigitalDetoxServiceLocal._internal();

  final DigitalDetoxConfigRepository _repository = DigitalDetoxConfigRepository.instance;

  /// Busca configuraÃ§Ã£o do usuÃ¡rio
  Future<DigitalDetoxConfigEntity?> getConfig(String userId) async {
    try {
      return await _repository.getConfig(userId);
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar config do Jejum Digital', error: e);
      return null;
    }
  }

  /// Cria ou retorna configuraÃ§Ã£o existente
  Future<DigitalDetoxConfigEntity> getOrCreateConfig(String userId) async {
    return await _repository.getOrCreateConfig(userId);
  }

  /// Salva configuraÃ§Ã£o
  Future<void> saveConfig(DigitalDetoxConfigEntity config) async {
    try {
      await _repository.saveConfig(config);
      LoggerService.instance.i('Config do Jejum Digital salva');
      
      // Sincronizar configurações nativas do Android
      await AppLockSyncService.instance.syncAllConfigs();
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar config do Jejum Digital', error: e);
      rethrow;
    }
  }

  /// Ativa mÃ³dulo
  Future<void> activateModule(String userId) async {
    await _repository.setModuleActive(userId, true);
    LoggerService.instance.i('Jejum Digital ativado');
    await AppLockSyncService.instance.syncAllConfigs();
  }

  /// Desativa mÃ³dulo
  Future<void> deactivateModule(String userId) async {
    await _repository.setModuleActive(userId, false);
    LoggerService.instance.i('Jejum Digital desativado');
    await AppLockSyncService.instance.syncAllConfigs();
  }

  /// Verifica se mÃ³dulo estÃ¡ ativo
  Future<bool> isModuleActive(String userId) async {
    return await _repository.isModuleActive(userId);
  }

  /// Adiciona app monitorado
  Future<void> addMonitoredApp(String userId, String appPackage) async {
    await _repository.addMonitoredApp(userId, appPackage);
    await AppLockSyncService.instance.syncAllConfigs();
  }

  /// Remove app monitorado
  Future<void> removeMonitoredApp(String userId, String appPackage) async {
    await _repository.removeMonitoredApp(userId, appPackage);
    await AppLockSyncService.instance.syncAllConfigs();
  }

  /// Busca lista de apps monitorados
  Future<List<String>> getMonitoredApps(String userId) async {
    final config = await getConfig(userId);
    return config?.monitoredApps ?? [];
  }
}
