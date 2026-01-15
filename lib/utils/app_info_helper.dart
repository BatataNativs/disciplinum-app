import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';

class AppDisplayInfo {
  final String package;
  final String? label;
  final Uint8List? icon;
  AppDisplayInfo({required this.package, this.label, this.icon});
}

Future<String?> getAppLabel(String packageName) async {
  try {
    final app = await InstalledApps.getAppInfo(packageName);
    if (app != null) {
      return app.name;
    }
  } catch (_) {}
  return null;
}

Future<Uint8List?> getAppIcon(String packageName) async {
  try {
    final app = await InstalledApps.getAppInfo(packageName);
    if (app != null && app.icon != null) {
      return app.icon;
    }
  } catch (_) {}
  return null;
}

final Map<String, AppDisplayInfo> _appInfoCache = {};

Future<List<AppDisplayInfo>> gatherAppDisplayInfo(
    List<String> packageNames) async {
  final infos = await Future.wait(
    packageNames.map((pkg) async {
      if (_appInfoCache.containsKey(pkg)) {
        return _appInfoCache[pkg]!;
      }
      try {
        final app = await InstalledApps.getAppInfo(pkg);
        final info = AppDisplayInfo(
          package: pkg,
          label: app?.name,
          icon: app?.icon,
        );
        _appInfoCache[pkg] = info;
        return info;
      } catch (_) {
        return AppDisplayInfo(package: pkg);
      }
    }),
  );
  return infos;
}
