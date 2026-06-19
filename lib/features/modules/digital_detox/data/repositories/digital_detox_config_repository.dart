import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_config_entity.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repository de configuraÃ§Ãµes do Jejum Digital
/// Gerencia persistÃªncia de configuraÃ§Ãµes usando ObjectBox
class DigitalDetoxConfigRepository {
  static DigitalDetoxConfigRepository? _instance;
  static DigitalDetoxConfigRepository get instance => _instance ??= DigitalDetoxConfigRepository._internal();

  DigitalDetoxConfigRepository._internal();

  Box<DigitalDetoxConfigEntity> get _box => ObjectBoxService.instance.store.box<DigitalDetoxConfigEntity>();

  /// Busca configuração pelo userId
  /// Se não encontrar pelo userId real, verifica se há uma entrada orphan de 'guest_user'
  /// salva erroneamente por race condition no Riverpod, e migra para o userId correto.
  Future<DigitalDetoxConfigEntity?> getConfig(String userId) async {
    try {
      final found = _box.query(DigitalDetoxConfigEntity_.userId.equals(userId)).build().findFirst();
      if (found != null) return found;
      
      // Se o userId real não foi encontrado, verifica se existe uma entrada salva
      // erroneamente como 'guest_user' (bug de race condition no provider de auth).
      // Isso NÃO é dado do modo convidado real — é dado do usuário logado salvo com
      // chave errada. Fazemos a migração corrigindo o userId.
      if (userId != 'guest_user') {
        final orphan = _box.query(DigitalDetoxConfigEntity_.userId.equals('guest_user')).build().findFirst();
        if (orphan != null) {
          orphan.userId = userId;
          _box.put(orphan);
          LoggerService.instance.i('DigitalDetox: config migrada de guest_user para $userId');
          return orphan;
        }
      }
      
      return null;
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

  /// Limpa todas as configuraÃ§Ãµes
  Future<void> clearAll() async {
    _box.removeAll();
  }
}
