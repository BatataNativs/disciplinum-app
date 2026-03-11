import 'package:flutter/foundation.dart';

/// Constantes globais do aplicativo
class AppConstants {
  // Informações do App
  static const String appName = 'Disciplinum';
  static const String appVersion = '0.1.0';
  static const String appBuildNumber = '1';
  
  // Configurações de Gamificação
  static const int maxStreakDays = 1000;
  static const int xpPerDay = 10;
  static const int xpPerMilestone = 50;
  static const int streakMilestoneInterval = 7;
  
  // Medalhas e Conquistas
  static const List<String> medalTypes = [
    'bronze',
    'silver', 
    'gold',
    'diamond',
  ];
  
  static const Map<String, int> medalThresholds = {
    'bronze': 7,
    'silver': 21,
    'gold': 50,
    'diamond': 100,
  };
  
  // Limites e Restrições
  static const int maxModulesPerUser = 9;
  static const int maxDailyCheckins = 1;
  static const int maxFocusSessionsPerDay = 10;
  static const int maxNotificationMessages = 100;
  
  // Tempo e Datas
  static const int checkInGracePeriodHours = 4;
  static const int focusSessionMinMinutes = 1;
  static const int focusSessionMaxMinutes = 480; // 8 horas
  static const int defaultFocusMinutes = 25;
  
  // Storage e Cache
  static const int maxCacheSizeMB = 50;
  static const int cacheExpirationHours = 24;
  static const int maxLocalDataRetentionDays = 90;
  
  // Performance
  static const int maxConcurrentOperations = 5;
  static const int networkTimeoutSeconds = 30;
  static const int animationDurationMs = 300;
  static const int debounceDelayMs = 500;
  
  // UI e Design
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;
  
  // Cores Tema Neon
  static const String neonPrimaryColor = '#00FFFF';
  static const String neonSecondaryColor = '#FF00FF';
  static const String neonAccentColor = '#FFFF00';
  static const String neonBackgroundColor = '#000000';
  
  // Nomes de Módulos
  static const Map<int, String> moduleNames = {
    1: 'Parar de Fumar',
    2: 'Compulsão Alimentar',
    3: 'Dieta',
    4: 'Gastos',
    5: 'Foco',
    6: 'Conteúdo Adulto',
    7: 'Economia',
    8: 'Procrastinação',
    9: 'Leitura',
  };
  
  static const Map<int, String> moduleDescriptions = {
    1: 'Liberte-se do cigarro e recupere sua saúde',
    2: 'Controle a compulsão alimentar',
    3: 'Alimentação saudável e equilibrada',
    4: 'Controle seus gastos financeiros',
    5: 'Aumente seu foco e produtividade',
    6: 'Evite conteúdo adulto prejudicial',
    7: 'Desafio de economia de dinheiro',
    8: 'Supere a procrastinação',
    9: 'Crie o hábito da leitura',
  };
  
  // Mensagens Motivacionais
  static const List<String> motivationalMessages = [
    'Você está mais forte do que imagina!',
    'Cada dia é uma nova oportunidade',
    'O progresso, não a perfeição',
    'Um passo de cada vez',
    'Você consegue!',
    'Acredite em seu potencial',
    'Hoje é o dia!',
    'Sua jornada vale a pena',
    'Continue assim!',
    'Você é incrível!',
  ];
  
  // Notificações
  static const String notificationChannelId = 'disciplinum_notifications';
  static const String notificationChannelName = 'Disciplinum';
  static const String notificationChannelDescription = 'Lembretes e motivação';
  
  // URLs e Links
  static const String privacyPolicyUrl = 'https://disciplinum.app/privacy';
  static const String termsOfServiceUrl = 'https://disciplinum.app/terms';
  static const String supportUrl = 'https://disciplinum.app/support';
  static const String rateAppUrl = 'https://play.google.com/store/apps/details?id=com.disciplinum.app';
  
  // Configurações de Rede
  static const int maxRetryAttempts = 3;
  static const int retryDelayMs = 1000;
  static const int batchSize = 50;
  
  // Segurança
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const int sessionTimeoutMinutes = 60;
  
  // Analytics
  static const int analyticsBatchSize = 20;
  static const int analyticsFlushIntervalSeconds = 30;
  static const int maxAnalyticsEventsPerSession = 1000;
  
  // Debug
  static const bool enableDebugLogs = kDebugMode;
  static const bool enablePerformanceMonitoring = kDebugMode;
  static const bool enableNetworkLogging = kDebugMode;
}
