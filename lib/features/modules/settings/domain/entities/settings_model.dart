import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Enum para modo de tema
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Classe para representar horário
class AppTimeOfDay {
  final int hour;
  final int minute;

  const AppTimeOfDay({
    required this.hour,
    required this.minute,
  });

  factory AppTimeOfDay.now() {
    final now = DateTime.now();
    return AppTimeOfDay(hour: now.hour, minute: now.minute);
  }

  String format() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  factory AppTimeOfDay.fromString(String timeString) {
    final parts = timeString.split(':');
    return AppTimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

/// Modelo de configurações do usuário
class UserSettings {
  final String id;
  final Map<NicheId, ModuleSettings> moduleSettings;
  final AppSettings appSettings;
  final NotificationSettings notificationSettings;
  final PrivacySettings privacySettings;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    required this.moduleSettings,
    required this.appSettings,
    required this.notificationSettings,
    required this.privacySettings,
    required this.updatedAt,
  });

  factory UserSettings.initial() {
    return UserSettings(
      id: 'default',
      moduleSettings: {},
      appSettings: AppSettings.initial(),
      notificationSettings: NotificationSettings.initial(),
      privacySettings: PrivacySettings.initial(),
      updatedAt: DateTime.now(),
    );
  }

  UserSettings copyWith({
    String? id,
    Map<NicheId, ModuleSettings>? moduleSettings,
    AppSettings? appSettings,
    NotificationSettings? notificationSettings,
    PrivacySettings? privacySettings,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      moduleSettings: moduleSettings ?? this.moduleSettings,
      appSettings: appSettings ?? this.appSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleSettings': moduleSettings.map((key, value) => MapEntry(key.id.toString(), value.toJson())),
      'appSettings': appSettings.toJson(),
      'notificationSettings': notificationSettings.toJson(),
      'privacySettings': privacySettings.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] ?? 'default',
      moduleSettings: (json['moduleSettings'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(
          NicheId.values.firstWhere((niche) => niche.id.toString() == key),
          ModuleSettings.fromJson(value as Map<String, dynamic>),
        ),
      ),
      appSettings: AppSettings.fromJson(json['appSettings'] as Map<String, dynamic>? ?? {}),
      notificationSettings: NotificationSettings.fromJson(json['notificationSettings'] as Map<String, dynamic>? ?? {}),
      privacySettings: PrivacySettings.fromJson(json['privacySettings'] as Map<String, dynamic>? ?? {}),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Configurações de um módulo específico
class ModuleSettings {
  final bool isEnabled;
  final bool notificationsEnabled;
  final Map<String, dynamic> customSettings;
  final DateTime lastActivatedAt;
  final DateTime? lastDeactivatedAt;

  const ModuleSettings({
    required this.isEnabled,
    required this.notificationsEnabled,
    required this.customSettings,
    required this.lastActivatedAt,
    this.lastDeactivatedAt,
  });

  factory ModuleSettings.initial() {
    return ModuleSettings(
      isEnabled: false,
      notificationsEnabled: true,
      customSettings: {},
      lastActivatedAt: DateTime.now(),
    );
  }

  ModuleSettings copyWith({
    bool? isEnabled,
    bool? notificationsEnabled,
    Map<String, dynamic>? customSettings,
    DateTime? lastActivatedAt,
    DateTime? lastDeactivatedAt,
  }) {
    return ModuleSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      customSettings: customSettings ?? this.customSettings,
      lastActivatedAt: lastActivatedAt ?? this.lastActivatedAt,
      lastDeactivatedAt: lastDeactivatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'notificationsEnabled': notificationsEnabled,
      'customSettings': customSettings,
      'lastActivatedAt': lastActivatedAt.toIso8601String(),
      'lastDeactivatedAt': lastDeactivatedAt?.toIso8601String(),
    };
  }

  factory ModuleSettings.fromJson(Map<String, dynamic> json) {
    return ModuleSettings(
      isEnabled: json['isEnabled'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
      lastActivatedAt: DateTime.parse(json['lastActivatedAt'] ?? DateTime.now().toIso8601String()),
      lastDeactivatedAt: json['lastDeactivatedAt'] != null ? DateTime.parse(json['lastDeactivatedAt']) : null,
    );
  }
}

/// Configurações gerais do aplicativo
class AppSettings {
  final AppThemeMode themeMode;
  final String language;
  final bool animationsEnabled;
  final bool hapticFeedbackEnabled;
  final bool soundEffectsEnabled;
  final String defaultCurrency;

  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.animationsEnabled,
    required this.hapticFeedbackEnabled,
    required this.soundEffectsEnabled,
    required this.defaultCurrency,
  });

  factory AppSettings.initial() {
    return const AppSettings(
      themeMode: AppThemeMode.system,
      language: 'pt_BR',
      animationsEnabled: true,
      hapticFeedbackEnabled: true,
      soundEffectsEnabled: true,
      defaultCurrency: 'BRL',
    );
  }

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? language,
    bool? animationsEnabled,
    bool? hapticFeedbackEnabled,
    bool? soundEffectsEnabled,
    String? defaultCurrency,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'language': language,
      'animationsEnabled': animationsEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'soundEffectsEnabled': soundEffectsEnabled,
      'defaultCurrency': defaultCurrency,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values[json['themeMode'] ?? AppThemeMode.system.index],
      language: json['language'] ?? 'pt_BR',
      animationsEnabled: json['animationsEnabled'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      soundEffectsEnabled: json['soundEffectsEnabled'] ?? true,
      defaultCurrency: json['defaultCurrency'] ?? 'BRL',
    );
  }
}

/// Configurações de notificações
class NotificationSettings {
  final bool globalNotificationsEnabled;
  final AppTimeOfDay quietHoursStart;
  final AppTimeOfDay quietHoursEnd;
  final bool quietHoursEnabled;
  final Map<String, bool> notificationTypes;

  const NotificationSettings({
    required this.globalNotificationsEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.quietHoursEnabled,
    required this.notificationTypes,
  });

  factory NotificationSettings.initial() {
    return NotificationSettings(
      globalNotificationsEnabled: true,
      quietHoursStart: const AppTimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: const AppTimeOfDay(hour: 7, minute: 0),
      quietHoursEnabled: false,
      notificationTypes: {
        'daily_reminders': true,
        'achievements': true,
        'streak_alerts': true,
        'level_ups': true,
        'module_updates': false,
      },
    );
  }

  NotificationSettings copyWith({
    bool? globalNotificationsEnabled,
    AppTimeOfDay? quietHoursStart,
    AppTimeOfDay? quietHoursEnd,
    bool? quietHoursEnabled,
    Map<String, bool>? notificationTypes,
  }) {
    return NotificationSettings(
      globalNotificationsEnabled: globalNotificationsEnabled ?? this.globalNotificationsEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      notificationTypes: notificationTypes ?? this.notificationTypes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'globalNotificationsEnabled': globalNotificationsEnabled,
      'quietHoursStart': quietHoursStart.format(),
      'quietHoursEnd': quietHoursEnd.format(),
      'quietHoursEnabled': quietHoursEnabled,
      'notificationTypes': notificationTypes,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final quietStartStr = json['quietHoursStart'] ?? '22:00';
    final quietEndStr = json['quietHoursEnd'] ?? '07:00';
    
    return NotificationSettings(
      globalNotificationsEnabled: json['globalNotificationsEnabled'] ?? true,
      quietHoursStart: AppTimeOfDay.fromString(quietStartStr),
      quietHoursEnd: AppTimeOfDay.fromString(quietEndStr),
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      notificationTypes: Map<String, bool>.from(json['notificationTypes'] ?? {}),
    );
  }
}

/// Configurações de privacidade
class PrivacySettings {
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool usageDataCollection;
  final bool personalizedNotifications;
  final bool locationServices;
  final bool biometricAuthentication;

  const PrivacySettings({
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.usageDataCollection,
    required this.personalizedNotifications,
    required this.locationServices,
    required this.biometricAuthentication,
  });

  factory PrivacySettings.initial() {
    return const PrivacySettings(
      analyticsEnabled: true,
      crashReportingEnabled: true,
      usageDataCollection: false,
      personalizedNotifications: true,
      locationServices: false,
      biometricAuthentication: false,
    );
  }

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? usageDataCollection,
    bool? personalizedNotifications,
    bool? locationServices,
    bool? biometricAuthentication,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      usageDataCollection: usageDataCollection ?? this.usageDataCollection,
      personalizedNotifications: personalizedNotifications ?? this.personalizedNotifications,
      locationServices: locationServices ?? this.locationServices,
      biometricAuthentication: biometricAuthentication ?? this.biometricAuthentication,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analyticsEnabled': analyticsEnabled,
      'crashReportingEnabled': crashReportingEnabled,
      'usageDataCollection': usageDataCollection,
      'personalizedNotifications': personalizedNotifications,
      'locationServices': locationServices,
      'biometricAuthentication': biometricAuthentication,
    };
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      analyticsEnabled: json['analyticsEnabled'] ?? true,
      crashReportingEnabled: json['crashReportingEnabled'] ?? true,
      usageDataCollection: json['usageDataCollection'] ?? false,
      personalizedNotifications: json['personalizedNotifications'] ?? true,
      locationServices: json['locationServices'] ?? false,
      biometricAuthentication: json['biometricAuthentication'] ?? false,
    );
  }
}
