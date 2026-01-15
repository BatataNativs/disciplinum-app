import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'dart:io';

class InstalledAppService extends ChangeNotifier {
  static final InstalledAppService _instance = InstalledAppService._internal();
  factory InstalledAppService() => _instance;
  InstalledAppService._internal();

  List<AppInfo> _cachedApps = [];
  final Map<String, Uint8List?> _iconCache = {};
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
      debugPrint('InstalledAppService Error: $e');
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
      return _iconCache[packageName];
    }

    try {
      final appInfo = await InstalledApps.getAppInfo(packageName);
      _iconCache[packageName] = appInfo?.icon;
      return appInfo?.icon;
    } catch (e) {
      debugPrint('Error fetching icon for $packageName: $e');
      _iconCache[packageName] = null;
      return null;
    }
  }

  /// Limpa os caches se necessário
  void clearCache() {
    _cachedApps = [];
    _iconCache.clear();
    notifyListeners();
  }
}
