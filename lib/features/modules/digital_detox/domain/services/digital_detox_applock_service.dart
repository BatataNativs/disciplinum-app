import 'dart:typed_data';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_service_local.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_time_tracker.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_time_checker.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_session_manager.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_weekly_manager.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/repositories/digital_detox_fasting_break_domain_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/entities/digital_detox_fasting_break_info.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';

/// ServiÃ§o de integraÃ§Ã£o entre Jejum Digital e AppLock
/// Gerencia o bloqueio de apps durante o perÃ­odo de jejum
class DigitalDetoxAppLockService {
  static DigitalDetoxAppLockService? _instance;
  static DigitalDetoxAppLockService get instance => _instance ??= DigitalDetoxAppLockService._internal();

  DigitalDetoxAppLockService._internal();

  final DigitalDetoxServiceLocal _detoxService = DigitalDetoxServiceLocal.instance;

  /// Verifica se um app deve ser bloqueado pelo Jejum Digital
  Future<bool> shouldBlockApp(String userId, String packageName) async {
    try {
      final config = await _detoxService.getConfig(userId);

      // Verifica se mÃ³dulo estÃ¡ ativo
      if (config == null || !config.isModuleActive) {
        return false;
      }

      // Verifica se app estÃ¡ na lista de monitorados
      if (!config.monitoredApps.contains(packageName)) {
        return false;
      }

      // FASE 2: Verificar bloqueio por horÃ¡rio
      if (config.enableTimeWindow) {
        final isWithinAllowedTime = DigitalDetoxTimeChecker.isWithinAllowedTime(config);
        if (!isWithinAllowedTime) {
          LoggerService.instance.i('App bloqueado fora do horÃ¡rio permitido: $packageName');
          return true; // Bloqueia se estÃ¡ fora do horÃ¡rio permitido
        }
      }

      // FASE 3: Verificar limite de tempo diÃ¡rio
      if (config.enableDailyLimit) {
        final timeTracker = DigitalDetoxTimeTracker.instance;
        final hasReachedLimit = await timeTracker.hasReachedDailyLimit(userId, config);
        if (hasReachedLimit) {
          LoggerService.instance.i('App bloqueado - limite diÃ¡rio atingido: $packageName');
          return true; // Bloqueia se atingiu o limite diÃ¡rio
        }

        // Verifica se estÃ¡ prÃ³ximo do limite e envia notificaÃ§Ã£o de aviso
        final isNearLimit = await timeTracker.isNearDailyLimit(userId, config);
        if (isNearLimit) {
          LoggerService.instance.i('Aviso: prÃ³ximo do limite diÃ¡rio - $packageName');
          // Implementar notificaÃ§Ã£o de aviso visual
          await _showNearLimitNotification(packageName);
        }
      }

      // FASE 5: Verificar SessÃµes Controladas
      if (config.enableSessionMode) {
        final sessionManager = DigitalDetoxSessionManager.instance;
        final canStartSession = await sessionManager.canStartSession(userId);
        
        if (!canStartSession) {
          LoggerService.instance.i('App bloqueado - SessÃµes Controladas: $packageName');
          return true; // Bloqueia se nÃ£o pode iniciar sessÃ£o
        }
        
        // Se pode iniciar sessÃ£o, inicia automaticamente
        final sessionStarted = await sessionManager.startSession(userId, packageName);
        if (!sessionStarted) {
          LoggerService.instance.i('Falha ao iniciar sessÃ£o - bloqueando app: $packageName');
          return true;
        }
        
        LoggerService.instance.i('SessÃ£o iniciada com sucesso para: $packageName');
      }

      // FASE 6B: Verificar limite semanal
      if (config.enableWeeklyLimit) {
        final weeklyManager = DigitalDetoxWeeklyManager.instance;
        final canUseMoreTime = await weeklyManager.canUseMoreTime(userId, 1); // Verifica se pode usar mais 1 minuto
        
        if (!canUseMoreTime) {
          LoggerService.instance.i('App bloqueado - limite semanal atingido: $packageName');
          return true; // Bloqueia se atingiu o limite semanal
        }
      }

      // FASE 7 - Verificar Quebra de Jejum ativa
      final hasActiveBreak = await _checkActiveFastingBreak(userId);
      if (hasActiveBreak) {
        LoggerService.instance.i('Acesso permitido: Quebra de Jejum ativa');
        return false; // Permite acesso se tem quebra ativa
      }

      return false; // Permite acesso se passou por todas as verificaÃ§Ãµes
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar bloqueio de app', error: e);
      return false;
    }
  }

  /// Mostra a tela de AppLock para Jejum Digital
  Future<void> showAppLockScreen(String userId, String packageName, String appName, Uint8List? appIconBytes) async {
    try {
      await AppLockService.instance.showAppLockScreen(
        packageName: packageName,
        appName: appName,
        appIconBytes: appIconBytes,
        nicheId: NicheId.digitalDetox,
        onOpenApp: () => _handleOpenApp(userId, packageName),
        onExitApp: () => _handleExitApp(userId, packageName),
      );

      LoggerService.instance.i('AppLock exibido para Jejum Digital: $appName');
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar AppLock', error: e);
    }
  }

  /// Callback quando usuÃ¡rio escolhe abrir o app
  Future<void> _handleOpenApp(String userId, String packageName) async {
    try {
      LoggerService.instance.gamification('UsuÃ¡rio abriu app durante Jejum Digital: $packageName');

      // FASE 3: Inicia tracking de tempo
      final config = await _detoxService.getOrCreateConfig(userId);
      if (config.enableDailyLimit) {
        final timeTracker = DigitalDetoxTimeTracker.instance;
        await timeTracker.onAppOpened(userId, packageName, packageName);
        LoggerService.instance.i('Iniciando tracking de tempo para: $packageName');
      }

      // FASE 6B: Registra inÃ­cio de uso para controle semanal
      if (config.enableWeeklyLimit) {
        final weeklyManager = DigitalDetoxWeeklyManager.instance;
        await weeklyManager.registerUsage(userId, 0); // Registra inÃ­cio de sessÃ£o
      }

      // FASE 5: SessÃ£o jÃ¡ foi iniciada no shouldBlockApp se necessÃ¡rio
      
      // FASE 7 - Verificar se estÃ¡ usando Quebra de Jejum
      final hasActiveBreak = await _checkActiveFastingBreak(userId);
      if (hasActiveBreak) {
        LoggerService.instance.i('App liberado: Quebra de Jejum ativa para $packageName');
        // Permite acesso se tem quebra ativa - nÃ£o retorna nada pois mÃ©todo Ã© void
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao processar abertura de app', error: e);
    }
  }

  /// Callback quando usuÃ¡rio escolhe sair do app
  Future<void> _handleExitApp(String userId, String packageName) async {
    try {
      LoggerService.instance.gamification('UsuÃ¡rio saiu do app durante Jejum Digital: $packageName');

      // FASE 3: Finaliza tracking de tempo
      final timeTracker = DigitalDetoxTimeTracker.instance;
      await timeTracker.onAppClosed(userId);

      // FASE 5: Finaliza sessÃ£o controlada se estiver ativa
      final sessionManager = DigitalDetoxSessionManager.instance;
      final currentSession = sessionManager.getCurrentSession();
      
      if (currentSession != null && 
          currentSession.isActive && 
          currentSession.packageName == packageName) {
        await sessionManager.endSession(userId);
        LoggerService.instance.i('SessÃ£o controlada finalizada para: $packageName');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao processar saÃ­da de app', error: e);
    }
  }

  /// Notifica que um app foi aberto (chamado pelo sistema de monitoramento)
  Future<void> onAppOpened(String userId, String packageName, String appName) async {
    try {
      final config = await _detoxService.getConfig(userId);
      if (config == null || !config.isModuleActive) return;
      if (!config.monitoredApps.contains(packageName)) return;

      // Inicia tracking de tempo
      await DigitalDetoxTimeTracker.instance.onAppOpened(userId, packageName, appName);
    } catch (e) {
      LoggerService.instance.e('Erro ao notificar abertura de app', error: e);
    }
  }

  /// Notifica que um app foi fechado
  Future<void> onAppClosed(String userId) async {
    try {
      await DigitalDetoxTimeTracker.instance.onAppClosed(userId);
    } catch (e) {
      LoggerService.instance.e('Erro ao notificar fechamento de app', error: e);
    }
  }

  /// Retorna estatÃ­sticas de uso para exibiÃ§Ã£o
  Future<Map<String, dynamic>> getUsageStats(String userId) async {
    try {
      final config = await _detoxService.getOrCreateConfig(userId);
      final timeTracker = DigitalDetoxTimeTracker.instance;

      final todayMinutes = await timeTracker.getTodayUsageMinutes(userId);
      final remainingMinutes = await timeTracker.getRemainingMinutes(userId, config);
      final appUsage = await timeTracker.getTodayAppUsage(userId);

      return {
        'todayMinutes': todayMinutes,
        'remainingMinutes': remainingMinutes,
        'limitMinutes': config.dailyLimitMinutes,
        'appUsage': appUsage,
        'isLimitEnabled': config.enableDailyLimit,
      };
    } catch (e) {
      LoggerService.instance.e('Erro ao obter estatÃ­sticas', error: e);
      return {
        'todayMinutes': 0,
        'remainingMinutes': 0,
        'limitMinutes': 60,
        'appUsage': {},
        'isLimitEnabled': false,
      };
    }
  }

  /// Lista de apps comuns de redes sociais
  List<String> getCommonSocialMediaApps() {
    return [
      'com.instagram.android',      // Instagram
      'com.facebook.katana',       // Facebook
      'com.zhiliaoapp.musically', // TikTok
      'com.snapchat.android',      // Snapchat
      'com.twitter.android',       // X (Twitter)
      'com.pinterest',             // Pinterest
      'com.linkedin.android',      // LinkedIn
      'com.reddit.frontpage',      // Reddit
      'com.whatsapp',              // WhatsApp
      'com.discord',               // Discord
      'com.telegram.messenger',    // Telegram
      'com.google.android.youtube', // YouTube
      'com.twitch.android',        // Twitch
    ];
  }

  /// Adiciona apps comuns de redes sociais
  Future<void> addCommonSocialMediaApps(String userId) async {
    try {
      final commonApps = getCommonSocialMediaApps();
      final config = await _detoxService.getOrCreateConfig(userId);

      bool hasChanges = false;
      for (final app in commonApps) {
        if (!config.monitoredApps.contains(app)) {
          config.monitoredApps.add(app);
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _detoxService.saveConfig(config);
        LoggerService.instance.i('Apps de redes sociais adicionados: ${commonApps.length} apps');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao adicionar apps comuns', error: e);
    }
  }

  /// Verifica se usuÃ¡rio tem quebra de jejum ativa
  Future<bool> _checkActiveFastingBreak(String userId) async {
    try {
      final objectBoxService = ObjectBoxService.instance;
      final breakRepo = DigitalDetoxFastingBreakRepository(objectBoxService.store.box<DigitalDetoxFastingBreakInfo>());
      final activeBreaks = breakRepo.getActiveForUser(userId);
      return activeBreaks.isNotEmpty;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar quebra de jejum ativa', error: e);
      return false;
    }
  }

  /// Mostra notificaÃ§Ã£o de aviso visual quando prÃ³ximo do limite
  Future<void> _showNearLimitNotification(String packageName) async {
    try {
      await NotificationService.showNotification(
        id: 9000,
        title: '⏰ Limite de Tempo Próximo',
        body: 'Você está perto de atingir o limite diário para $packageName',
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar notificaÃ§Ã£o de limite prÃ³ximo', error: e);
    }
  }
}
