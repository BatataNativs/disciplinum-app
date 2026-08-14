import 'package:disciplinum/features/modules/spending/data/repositories/spending_config_repository.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_sync_service.dart';

/// Serviço local de acesso às configurações do módulo Controle de Gastos
/// Singleton, espelha a arquitetura do DigitalDetoxServiceLocal
class SpendingServiceLocal {
  static SpendingServiceLocal? _instance;
  static SpendingServiceLocal get instance =>
      _instance ??= SpendingServiceLocal._internal();

  SpendingServiceLocal._internal();

  final SpendingConfigRepository _repository = SpendingConfigRepository.instance;

  /// Busca configuração do usuário
  Future<SpendingConfigEntity?> getConfig(String userId) async {
    try {
      return await _repository.getConfig();
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar config do Spending', error: e);
      return null;
    }
  }

  /// Cria ou retorna configuração existente
  Future<SpendingConfigEntity> getOrCreateConfig(String userId) async {
    return await _repository.getOrCreateConfig(userId);
  }

  /// Salva configuração
  Future<void> saveConfig(SpendingConfigEntity config) async {
    try {
      await _repository.saveConfig(config);
      LoggerService.instance.i('Config do Spending salva');

      // Sincronizar configurações nativas do Android
      await AppLockSyncService.instance.syncAllConfigs();
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar config do Spending', error: e);
      rethrow;
    }
  }

  /// Ativa módulo
  Future<void> activateModule(String userId) async {
    await _repository.setModuleActive(userId, true);
    LoggerService.instance.i('Spending ativado');
    await AppLockSyncService.instance.syncAllConfigs();
  }

  /// Desativa módulo
  Future<void> deactivateModule(String userId) async {
    await _repository.setModuleActive(userId, false);
    LoggerService.instance.i('Spending desativado');
    await AppLockSyncService.instance.syncAllConfigs();
  }

  /// Verifica se módulo está ativo
  Future<bool> isModuleActive(String userId) async {
    return await _repository.isModuleActive();
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
