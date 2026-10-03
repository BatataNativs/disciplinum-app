import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_config_entity.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repository de configurações do Jejum Digital
/// Gerencia persistência de configurações usando ObjectBox (100% local)
class DigitalDetoxConfigRepository {
  static DigitalDetoxConfigRepository? _instance;
  static DigitalDetoxConfigRepository get instance => _instance ??= DigitalDetoxConfigRepository._internal();

  DigitalDetoxConfigRepository._internal();

  Box<DigitalDetoxConfigEntity> get _box => ObjectBoxService.instance.store.box<DigitalDetoxConfigEntity>();

  /// Busca configuração pelo userId
  Future<DigitalDetoxConfigEntity?> getConfig(String userId) async {
    try {
      final found = _box.query(DigitalDetoxConfigEntity_.userId.equals(userId)).build().findFirst();
      if (found != null) return found;
      
      // Fallback para qualquer configuração local existente
      return _box.getAll().firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// Cria ou retorna configuração existente
  Future<DigitalDetoxConfigEntity> getOrCreateConfig(String userId) async {
    var config = await getConfig(userId);
    if (config == null) {
      config = DigitalDetoxConfigEntity(userId: userId);
      config.id = _box.put(config);
    }
    return config;
  }

  /// Salva configuração
  Future<void> saveConfig(DigitalDetoxConfigEntity config) async {
    config.touch();
    _box.put(config);
  }

  /// Ativa/desativa módulo
  Future<void> setModuleActive(String userId, bool isActive) async {
    final config = await getOrCreateConfig(userId);
    config.isModuleActive = isActive;
    
    // Se estiver desativando, limpa a lista de apps monitorados
    if (!isActive) {
      config.monitoredApps.clear();
      LoggerService.instance.i('Apps monitorados limpos ao desativar módulo Digital Detox');
    }
    
    await saveConfig(config);
  }

  /// Verifica se módulo está ativo
  Future<bool> isModuleActive(String userId) async {
    final config = await getConfig(userId);
    return config?.isModuleActive ?? false;
  }

  /// Adiciona app monitorado
  Future<void> addMonitoredApp(String userId, String appPackage) async {
    final config = await getOrCreateConfig(userId);
    if (!config.monitoredApps.contains(appPackage)) {
      config.monitoredApps.add(appPackage);
      await saveConfig(config);
    }
  }

  /// Remove app monitorado
  Future<void> removeMonitoredApp(String userId, String appPackage) async {
    final config = await getOrCreateConfig(userId);
    config.monitoredApps.remove(appPackage);
    await saveConfig(config);
  }

  /// Atualiza streak de dias disciplinados
  Future<void> updateDisciplinedStreak(String userId, int streak, DateTime lastDate) async {
    final config = await getOrCreateConfig(userId);
    config.currentDisciplinedStreak = streak;
    config.lastDisciplinedDate = lastDate;
    await saveConfig(config);
  }

  /// Limpa todas as configurações
  Future<void> clearAll() async {
    _box.removeAll();
  }

  // ===== SINCRONIZAÇÃO (100% Local) =====

  /// Sincronização completa (100% local)
  Future<DigitalDetoxConfigEntity> performFullSync() async {
    return (await getConfig('local_user')) ?? await getOrCreateConfig('local_user');
  }
}
