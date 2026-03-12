import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'dart:io';
import 'package:disciplinum/core/logging/logger_service.dart';

class InstalledAppService extends ChangeNotifier {
  static final InstalledAppService _instance = InstalledAppService._internal();
  factory InstalledAppService() => _instance;
  InstalledAppService._internal();

  List<AppInfo> _cachedApps = [];
  final Map<String, Uint8List?> _iconCache = {};
  final List<String> _iconLruKeys = [];
  static const int _maxIconCacheEntries = 200;
  final Map<String, Future<Uint8List?>> _pendingRequests = {};
  bool _isLoading = false;

  List<AppInfo> get cachedApps => _cachedApps;
  bool get isLoading => _isLoading;

  /// Busca a lista de apps instalados (sem ícones inicialmente para velocidade)
  Future<List<AppInfo>> getApps(
      {bool excludeSystemApps = true, bool forceRefresh = false}) async {
    if (_cachedApps.isNotEmpty && !forceRefresh) {
      return _cachedApps;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (Platform.isAndroid) {
        final apps = await InstalledApps.getInstalledApps(
          excludeSystemApps: excludeSystemApps,
          withIcon: false,
        );

        // Ordenação inicial por nome
        apps.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _cachedApps = apps;
      }
    } catch (e) {
      LoggerService.instance.e('InstalledAppService Error', error: e);
    }

    _isLoading = false;
    notifyListeners();
    return _cachedApps;
  }

  /// Método de conveniência para disparar o carregamento sem bloquear
  void preload({bool excludeSystemApps = true}) {
    getApps(excludeSystemApps: excludeSystemApps);
  }

  /// Busca o ícone de um app específico com cache
  Future<Uint8List?> getAppIcon(String packageName) async {
    if (_iconCache.containsKey(packageName)) {
      _touchIconKey(packageName);
      return _iconCache[packageName];
    }

    if (_pendingRequests.containsKey(packageName)) {
      return _pendingRequests[packageName];
    }

    try {
      final future = _fetchIcon(packageName);
      _pendingRequests[packageName] = future;
      return future;
    } catch (e) {
      LoggerService.instance.e('Error queuing icon fetch for $packageName', error: e);
      return null;
    }
  }

  Future<Uint8List?> _fetchIcon(String packageName) async {
    try {
      final appInfo = await InstalledApps.getAppInfo(packageName);
      _iconCache[packageName] = appInfo?.icon;
      _touchIconKey(packageName);
      _evictIconCacheIfNeeded();
      _pendingRequests.remove(packageName);
      return appInfo?.icon;
    } catch (e) {
      LoggerService.instance.e('Error fetching icon for $packageName', error: e);
      _iconCache[packageName] = null;
      _touchIconKey(packageName);
      _evictIconCacheIfNeeded();
      _pendingRequests.remove(packageName);
      return null;
    }
  }

  void _touchIconKey(String packageName) {
    _iconLruKeys.remove(packageName);
    _iconLruKeys.add(packageName);
  }

  void _evictIconCacheIfNeeded() {
    while (_iconLruKeys.length > _maxIconCacheEntries) {
      final oldestKey = _iconLruKeys.removeAt(0);
      _iconCache.remove(oldestKey);
    }
  }

  /// Limpa os caches se necessário
  void clearCache() {
    _cachedApps = [];
    _iconCache.clear();
    _iconLruKeys.clear();
    _pendingRequests.clear();
    notifyListeners();
  }
}
