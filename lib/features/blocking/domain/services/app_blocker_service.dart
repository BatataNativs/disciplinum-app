import 'package:flutter/foundation.dart';
import 'package:disciplinum/features/blocking/domain/entities/blocked_app.dart';

class AppBlockerService extends ChangeNotifier {
  static final AppBlockerService instance = AppBlockerService._internal();

  AppBlockerService._internal();

  final List<BlockedApp> _blockedApps = [];
  List<BlockedApp> get blockedApps => List.unmodifiable(_blockedApps);

  Future<void> initialize() async {
    // Carregar configurações de bloqueio iniciais
  }

  Future<void> blockApp(BlockedApp app) async {
    _blockedApps.add(app);
    notifyListeners();
  }

  Future<void> unblockApp(String packageName) async {
    _blockedApps.removeWhere((app) => app.packageName == packageName);
    notifyListeners();
  }
}
