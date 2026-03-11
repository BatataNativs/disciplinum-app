import 'package:flutter/foundation.dart';

/// Feature Flags para controle de funcionalidades
/// Permite habilitar/desabilitar features em produção
class FeatureFlags {
  // Gamificação
  static const bool gamificationEnabled = true;
  static const bool achievementsEnabled = true;
  static const bool streakSystemEnabled = true;
  static const bool xpSystemEnabled = true;

  // Módulos
  static const bool smokingModuleEnabled = true;
  static const bool bingeEatingModuleEnabled = true;
  static const bool dietModuleEnabled = true;
  static const bool spendingModuleEnabled = true;
  static const bool focusModuleEnabled = true;
  static const bool adultContentModuleEnabled = true;
  static const bool readingModuleEnabled = true;
  static const bool procrastinationModuleEnabled = true;
  static const bool moneySavingModuleEnabled = true;

  // Analytics e Monitoramento
  static const bool analyticsEnabled = true;
  static const bool crashlyticsEnabled = true;
  static const bool performanceMonitoringEnabled = true;

  // Monetização
  static const bool adsEnabled = true;
  static const bool iapEnabled = true;
  static const bool premiumFeaturesEnabled = false; // Futuro

  // Funcionalidades Avançadas
  static const bool appBlockingEnabled = false; // Fase 6
  static const bool accessibilityServiceEnabled = true; // Fase 6
  static const bool mlAnalyticsEnabled = false; // Fase 6

  // UI/UX
  static const bool darkModeEnabled = true;
  static const bool neonThemeEnabled = true;
  static const bool animationsEnabled = true;
  static const bool hapticFeedbackEnabled = true;

  // Notificações
  static const bool pushNotificationsEnabled = true;
  static const bool scheduledNotificationsEnabled = true;
  static const bool motivationalNotificationsEnabled = true;

  // Sincronização
  static const bool cloudSyncEnabled = true;
  static const bool offlineModeEnabled = true;
  static const bool realTimeSyncEnabled = false; // Futuro

  // Debug e Desenvolvimento
  static const bool debugModeEnabled = kDebugMode;
  static const bool debugMenuEnabled = kDebugMode;
  static const bool verboseLoggingEnabled = kDebugMode;
  static const bool mockDataEnabled = false;

  // Experimentos (A/B Testing)
  static const bool newOnboardingEnabled = false;
  static const bool improvedGamificationEnabled = false;
  static const bool enhancedAnalyticsEnabled = false;

  // Helper methods
  static bool isModuleEnabled(int nicheId) {
    switch (nicheId) {
      case 1:
        return smokingModuleEnabled;
      case 2:
        return bingeEatingModuleEnabled;
      case 3:
        return dietModuleEnabled;
      case 4:
        return spendingModuleEnabled;
      case 5:
        return focusModuleEnabled;
      case 6:
        return adultContentModuleEnabled;
      case 7:
        return moneySavingModuleEnabled;
      case 8:
        return procrastinationModuleEnabled;
      case 9:
        return readingModuleEnabled;
      default:
        return false;
    }
  }

  static bool isGamificationFeatureEnabled(String feature) {
    switch (feature) {
      case 'achievements':
        return achievementsEnabled;
      case 'streaks':
        return streakSystemEnabled;
      case 'xp':
        return xpSystemEnabled;
      default:
        return gamificationEnabled;
    }
  }

  static List<String> getEnabledModules() {
    final modules = <String>[];
    if (smokingModuleEnabled) modules.add('smoking');
    if (bingeEatingModuleEnabled) modules.add('binge_eating');
    if (dietModuleEnabled) modules.add('diet');
    if (spendingModuleEnabled) modules.add('spending');
    if (focusModuleEnabled) modules.add('focus');
    if (adultContentModuleEnabled) modules.add('adult_content');
    if (moneySavingModuleEnabled) modules.add('money_saving');
    if (procrastinationModuleEnabled) modules.add('procrastination');
    if (readingModuleEnabled) modules.add('reading');
    return modules;
  }

  static Map<String, bool> getAllFlags() {
    return {
      'gamification': gamificationEnabled,
      'achievements': achievementsEnabled,
      'streaks': streakSystemEnabled,
      'xp': xpSystemEnabled,
      'smoking': smokingModuleEnabled,
      'binge_eating': bingeEatingModuleEnabled,
      'diet': dietModuleEnabled,
      'spending': spendingModuleEnabled,
      'focus': focusModuleEnabled,
      'adult_content': adultContentModuleEnabled,
      'reading': readingModuleEnabled,
      'procrastination': procrastinationModuleEnabled,
      'money_saving': moneySavingModuleEnabled,
      'analytics': analyticsEnabled,
      'crashlytics': crashlyticsEnabled,
      'performance': performanceMonitoringEnabled,
      'ads': adsEnabled,
      'iap': iapEnabled,
      'premium': premiumFeaturesEnabled,
      'app_blocking': appBlockingEnabled,
      'accessibility': accessibilityServiceEnabled,
      'ml_analytics': mlAnalyticsEnabled,
      'dark_mode': darkModeEnabled,
      'neon_theme': neonThemeEnabled,
      'animations': animationsEnabled,
      'haptic': hapticFeedbackEnabled,
      'push_notifications': pushNotificationsEnabled,
      'scheduled_notifications': scheduledNotificationsEnabled,
      'motivational_notifications': motivationalNotificationsEnabled,
      'cloud_sync': cloudSyncEnabled,
      'offline_mode': offlineModeEnabled,
      'real_time_sync': realTimeSyncEnabled,
      'debug_mode': debugModeEnabled,
      'debug_menu': debugMenuEnabled,
      'verbose_logging': verboseLoggingEnabled,
      'mock_data': mockDataEnabled,
      'new_onboarding': newOnboardingEnabled,
      'improved_gamification': improvedGamificationEnabled,
      'enhanced_analytics': enhancedAnalyticsEnabled,
    };
  }
}
