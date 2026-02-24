/// lib/config/app_config.dart
///
/// Chaves injetadas via:
/// flutter run --dart-define-from-file=secrets/dev.json
/// ou repetindo --dart-define=CHAVE=VALOR. [web:72]
///
/// String.fromEnvironment usa defaultValue quando a chave não é definida. [web:87][web:96]

library;

class AppConfig {
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static const String admobTestDeviceId =
      String.fromEnvironment('ADMOB_TEST_DEVICE_ID', defaultValue: '');

  // Banner de teste do Google como fallback (dev).
  static const String admobBannerUnitId = String.fromEnvironment(
    'ADMOB_BANNER_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );

  // Rewarded Ad de teste do Google como fallback (dev).
  static const String admobRewardedUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
}
