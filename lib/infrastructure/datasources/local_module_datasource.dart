import 'package:disciplinum/infrastructure/entities/user_module_status.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';

/// DataSource para dados locais de módulos
/// Usa LocalStorageService como camada de abstração
class LocalModuleDatasource {
  static const String _moduleStatusPrefix = 'module_status_';
  static const String _lastSyncPrefix = 'last_sync_';
  static const String _lastGeneralSyncKey = 'last_general_sync';
  static const String _activeModulesKey = 'active_modules';

  /// Salva status do módulo localmente
  Future<void> saveModuleStatus(UserModuleStatus status) async {
    final key = _getModuleKey(status.nicheId);
    await LocalStorageService.instance.saveJson(key, status.toJson());
    
    // Atualizar lista de módulos ativos
    await _updateActiveModulesList(status.nicheId, add: true);
  }

  /// Obtém status do módulo do cache local
  Future<UserModuleStatus?> getModuleStatus(int nicheId) async {
    final key = _getModuleKey(nicheId);
    final json = await LocalStorageService.instance.getJson(key);
    
    if (json == null) return null;
    
    try {
      return UserModuleStatus.fromJson(json);
    } catch (e) {
      // Se falhar parse, remover cache corrompido
      await LocalStorageService.instance.remove(key);
      return null;
    }
  }

  /// Remove módulo do cache local
  Future<void> removeModule(int nicheId) async {
    final key = _getModuleKey(nicheId);
    await LocalStorageService.instance.remove(key);
    await LocalStorageService.instance.remove(_getSyncKey(nicheId));
    
    // Remover da lista de ativos
    await _updateActiveModulesList(nicheId, add: false);
  }

  /// Lista todos os módulos ativos no cache
  Future<List<UserModuleStatus>> getActiveModules() async {
    final activeIdsJson = await LocalStorageService.instance.getJson(_activeModulesKey);
    if (activeIdsJson == null) return [];
    
    final activeIds = activeIdsJson['active_ids'] as List<dynamic>? ?? [];
    final modules = <UserModuleStatus>[];
    
    for (final id in activeIds) {
      if (id is int) {
        final nicheId = NicheId.fromInt(id);
        final status = await getModuleStatus(nicheId.id);
        if (status != null) {
          modules.add(status);
        }
      }
    }
    
    return modules;
  }

  /// Salva timestamp da última sincronização
  Future<void> saveLastSyncTime(int nicheId, DateTime timestamp) async {
    final key = _getSyncKey(nicheId);
    await LocalStorageService.instance.save(key, timestamp.toIso8601String());
  }

  /// Obtém timestamp da última sincronização
  Future<DateTime?> getLastSyncTime(int nicheId) async {
    final key = _getSyncKey(nicheId);
    final timestampString = await LocalStorageService.instance.getString(key);
    
    if (timestampString == null) return null;
    
    try {
      return DateTime.parse(timestampString);
    } catch (e) {
      return null;
    }
  }

  /// Salva timestamp da última sincronização geral
  Future<void> saveLastGeneralSyncTime(DateTime timestamp) async {
    await LocalStorageService.instance.save(
      _lastGeneralSyncKey, 
      timestamp.toIso8601String()
    );
  }

  /// Obtém timestamp da última sincronização geral
  Future<DateTime?> getLastGeneralSyncTime() async {
    final timestampString = await LocalStorageService.instance.getString(_lastGeneralSyncKey);
    
    if (timestampString == null) return null;
    
    try {
      return DateTime.parse(timestampString);
    } catch (e) {
      return null;
    }
  }

  /// Limpa todos os dados locais
  Future<void> clearAll() async {
    final keys = await LocalStorageService.instance.getKeys();
    final moduleKeys = keys.where((key) => 
      key.startsWith(_moduleStatusPrefix) || 
      key.startsWith(_lastSyncPrefix)
    );
    
    for (final key in moduleKeys) {
      await LocalStorageService.instance.remove(key);
    }
    
    await LocalStorageService.instance.remove(_activeModulesKey);
    await LocalStorageService.instance.remove(_lastGeneralSyncKey);
  }

  /// Atualiza lista de módulos ativos
  Future<void> _updateActiveModulesList(int nicheId, {required bool add}) async {
    final currentJson = await LocalStorageService.instance.getJson(_activeModulesKey) ?? {};
    final activeIds = List<int>.from(currentJson['active_ids'] as List? ?? []);
    
    if (add && !activeIds.contains(nicheId)) {
      activeIds.add(nicheId);
    } else if (!add) {
      activeIds.remove(nicheId);
    }
    
    await LocalStorageService.instance.saveJson(_activeModulesKey, {
      'active_ids': activeIds,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Gera chave para status do módulo
  String _getModuleKey(int nicheId) {
    return '$_moduleStatusPrefix$nicheId';
  }

  /// Gera chave para timestamp de sincronização
  String _getSyncKey(int nicheId) {
    return '$_lastSyncPrefix$nicheId';
  }
}
