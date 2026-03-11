import 'package:shared_preferences/shared_preferences.dart';

/// Dados de inicialização retornados pelo bootstrap
class AppStartupData {
  final SharedPreferences prefs;
  final bool seenOnboarding;

  AppStartupData({
    required this.prefs,
    required this.seenOnboarding,
  });
}
