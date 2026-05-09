import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_config_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repository de configuraÃ§Ãµes do Jejum Digital
/// Gerencia persistÃªncia de configuraÃ§Ãµes usando ObjectBox
class DigitalDetoxConfigRepository {
  static DigitalDetoxConfigRepository? _instance;
  static DigitalDetoxConfigRepository get instance => _instance ??= DigitalDetoxConfigRepository._internal();

  DigitalDetoxConfigRepository._internal();

  Box<DigitalDetoxConfigEntity> get _box => ObjectBoxService.instance.store.box<DigitalDetoxConfigEntity>();

  /// Busca configuraÃ§Ã£o pelo userId
  Future<DigitalDetoxConfigEntity?> getConfig(String userId) async {
    try {
      return _box.query(DigitalDetoxConfigEntity_.userId.equals(userId)).build().findFirst();
    } catch (e) {
      return null;
    }
  }

  /// Cria ou retorna configuraÃ§Ã£o existente
  Future<DigitalDetoxConfigEntity> getOrCreateConfig(String userId) async {
    var config = await getConfig(userId);
    if (config == null) {
      config = DigitalDetoxConfigEntity(userId: userId);
      config.id = _box.put(config);
    }
    return config;
  }

  /// Salva configuraÃ§Ã£o
  Future<void> saveConfig(DigitalDetoxConfigEntity config) async {
    config.touch();
    _box.put(config);
  }

  /// Ativa/desativa mÃ³dulo
  Future<void> setModuleActive(String userId, bool isActive) async {
    final config = await getOrCreateConfig(userId);
    config.isModuleActive = isActive;
    await saveConfig(config);
  }

  /// Verifica se mÃ³dulo estÃ¡ ativo
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

  /// Limpa todas as configuraÃ§Ãµes
  Future<void> clearAll() async {
    _box.removeAll();
  }
}
