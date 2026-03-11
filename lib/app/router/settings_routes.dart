import 'package:flutter/material.dart';

class SettingsRoutes {
  static const String settings = '/settings';
  static const String howItWorks = '/settings/how-it-works';
  static const String secretMenu = '/settings/secret-menu';
  static const String privacy = '/settings/privacy';
  static const String terms = '/settings/terms';

  static Map<String, Widget Function(BuildContext)> get routes => {
    settings: (context) => throw UnimplementedError('Settings screen not implemented'),
    howItWorks: (context) => throw UnimplementedError('How it works screen not implemented'),
    secretMenu: (context) => throw UnimplementedError('Secret menu screen not implemented'),
    privacy: (context) => throw UnimplementedError('Privacy screen not implemented'),
    terms: (context) => throw UnimplementedError('Terms screen not implemented'),
  };
}
