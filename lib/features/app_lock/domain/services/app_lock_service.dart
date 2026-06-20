import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/features/app_lock/infrastructure/services/navigation_service.dart';
import 'package:disciplinum/features/app_lock/infrastructure/channels/app_lock_channel.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:disciplinum/features/modules/diet/gamification/presentation/providers/diet_gamification_provider.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/repositories/digital_detox_gamification_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/entities/digital_detox_gamification_entity.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/services/digital_detox_gamification_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/presentation/providers/binge_eating_gamification_provider.dart';
import 'package:disciplinum/features/modules/spending/gamification/presentation/providers/spending_gamification_provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart' as ns;

/// Serviço principal de App Lock
/// Gerencia o sistema de bloqueio consciente para todos os módulos
class AppLockService {
  static AppLockService? _instance;
  static AppLockService get instance => _instance ??= AppLockService._();
  
  // Container para acessar os providers
  static ProviderContainer? _container;
  
  static void setContainer(ProviderContainer container) {
    _container = container;
    _startAccessibilityListener();
  }

  static const _accessibilityChannel = EventChannel('com.disciplinum.app/accessibility');
  static StreamSubscription? _accessibilitySubscription;

  static void _startAccessibilityListener() {
    if (_accessibilitySubscription != null) return;
    
    _accessibilitySubscription = _accessibilityChannel.receiveBroadcastStream().listen((event) async {
      LoggerService.instance.system('Acessibilidade enviou evento: $event');
      if (event is Map) {
        await _handleAccessibilityEvent(event);
      }
    });
    LoggerService.instance.system('Listener de acessibilidade foi INICIADO e registrado no channel com.disciplinum.app/accessibility');
  }

  static Future<void> _handleAccessibilityEvent(Map event) async {
    try {
      final type = event['type'] as String?;
      var packageName = event['packageName'] as String?;
      
      if (packageName == null) return;
      
      // Corrige erro de digitação no packageName (comm. -> com.)
      packageName = _fixPackageNameTypo(packageName);
      
      if (_isSystemPackage(packageName)) {
        return;
      }
      
      if (type == 'app_blocked') {
        // App foi bloqueado nativamente - atualizar gamificação
        final moduleId = event['moduleId'] as String?;
        final reason = event['reason'] as String?;
        
        LoggerService.instance.system('App bloqueado nativamente: $packageName (módulo: $moduleId, motivo: $reason)');
        
        // Atualizar gamificação baseado no módulo
        if (moduleId != null) {
          await _handleAppBlockedForGamification(packageName, moduleId);
        }
      } else if (type == 'app_opened') {
        // App foi aberto mas não bloqueado - apenas logar
        final reason = event['reason'] as String?;
        LoggerService.instance.system('App aberto sem bloqueio: $packageName (motivo: $reason)');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao processar evento de acessibilidade', error: e);
    }
  }

  /// Corrige erro de digitação no packageName (comm. -> com.)
  static String _fixPackageNameTypo(String packageName) {
    if (packageName.startsWith('comm.')) {
      return 'com.${packageName.substring(5)}';
    }
    return packageName;
  }

  static Future<void> _handleAppBlockedForGamification(String packageName, String moduleId) async {
    try {
      // Mapear moduleId para o serviço de gamificação correspondente
      switch (moduleId) {
        case 'digital_detox':
        case 'instagram':
        case 'facebook':
        case 'twitter':
        case 'tiktok':
        case 'youtube':
          // Digital Detox - atualizar gamificação
          await _handleDigitalDetoxBlocked(packageName);
          break;
        default:
          LoggerService.instance.w('Módulo não mapeado para gamificação: $moduleId');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar gamificação para app bloqueado', error: e);
    }
  }

  static Future<void> _handleDigitalDetoxBlocked(String packageName) async {
    try {
      // Digital Detox - incrementar violações ou resetar streak
      // A lógica específica depende da implementação do módulo
      LoggerService.instance.gamification('Digital Detox: app bloqueado - $packageName');
      
      // Aqui você pode chamar o serviço de gamificação do Digital Detox
      // para atualizar streaks, medalhas, etc.
    } catch (e) {
      LoggerService.instance.e('Erro ao processar bloqueio Digital Detox', error: e);
    }
  }

  static bool _isSystemPackage(String packageName) {
    final systemPackages = [
      'com.android.systemui',
      'android',
      'com.android.launcher',
      'com.android.settings',
      'com.google.android.apps.nexuslauncher',
      'com.teslacoilsw.launcher.prime',
      'com.microsoft.launcher',
      'com.miui.home',
      'com.sec.android.app.launcher',
      'com.disciplinum.app',
    ];

    return systemPackages.contains(packageName) ||
        packageName.contains('.launcher') ||
        packageName.contains('.home') ||
        packageName.endsWith('.launcher');
  }

  AppLockService._();

  /// Mostra a tela de bloqueio para um app específico
  Future<void> showAppLockScreen({
    required String packageName,
    required String appName,
    required Uint8List? appIconBytes,
    required NicheId nicheId,
    required VoidCallback onExitApp,
    required VoidCallback onOpenApp,
  }) async {
    try {
      // Mensagem personalizada por módulo
      final alertMessage = _getModuleAlertMessage(nicheId);
      
      LoggerService.instance.gamification('App Lock exibido para: $appName - Mensagem: $alertMessage');
      
      // Criar callbacks que fecham a tela automaticamente
      void wrappedExitCallback() async {
        // Fecha a tela de bloqueio primeiro
        AppLockNavigationService.closeAppLockScreen();
        // Executa a ação original
        onExitApp();
      }

      void wrappedOpenCallback() async {
        // Reseta gamificação antes de fechar
        await _resetModuleGamification(nicheId);
        // Fecha a tela de bloqueio
        AppLockNavigationService.closeAppLockScreen();
        // Executa a ação original
        onOpenApp();
      }

      // Implementar navegação para tela de bloqueio
      final lockEvent = AppLockEvent(
        packageName: packageName,
        appName: appName,
        appIconBytes: appIconBytes,
        nicheId: nicheId,
        alertMessage: alertMessage,
        timestamp: DateTime.now(),
        onExitApp: wrappedExitCallback,
        onOpenApp: wrappedOpenCallback,
      );

      await AppLockNavigationService.showAppLockScreen(lockEvent);
      
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar tela de bloqueio', error: e);
      rethrow;
    }
  }

  /// Processa a escolha de abrir o app
  Future<void> handleOpenApp(AppLockEvent lockEvent) async {
    try {
      LoggerService.instance.gamification('Usuário escolheu abrir app: ${lockEvent.appName}');
      
      // Resetar gamificação do módulo específico
      await _resetModuleGamification(lockEvent.nicheId);
      
      // Mostrar notificação de reset
      await _showResetNotification(lockEvent);
      
      // Executar callback
      lockEvent.onOpenApp();
      
    } catch (e) {
      LoggerService.instance.e('Erro ao processar abertura de App', error: e);
    }
  }

  /// Processa a escolha de sair do app
  Future<void> handleExitApp(AppLockEvent lockEvent) async {
    try {
      LoggerService.instance.gamification('Usuário escolheu sair do app: ${lockEvent.appName}');
      
      // Executar callback
      lockEvent.onExitApp();
      
      // Implementar fechamento do app bloqueado
      await _closeBlockedApp(lockEvent.packageName);
      
    } catch (e) {
      LoggerService.instance.e('Erro ao processar saída de App', error: e);
    }
  }

  /// Reseta a gamificação do módulo específico
  Future<void> _resetModuleGamification(NicheId nicheId) async {
    try {
      // Implementar reset específico por módulo
      switch (nicheId) {
        case NicheId.focus:
          await _resetFocusGamification();
          break;
        case NicheId.spending:
          await _resetSpendingGamification();
          break;
        case NicheId.smoking:
          await _resetSmokingGamification();
          break;
        case NicheId.diet:
          await _resetDietGamification();
          break;
        case NicheId.bingeEating:
          await _resetBingeEatingGamification();
          break;
        case NicheId.adultContent:
          await _resetAdultContentGamification();
          break;
        case NicheId.digitalDetox:
          await _resetDigitalDetoxGamification();
          break;
        default:
          LoggerService.instance.w('Módulo não reconhecido para reset: $nicheId');
          break;
      }
      
      LoggerService.instance.gamification('Gamificação resetada para módulo: $nicheId');
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar gamificação', error: e);
    }
  }

  /// Reseta gamificação do módulo Focus
  Future<void> _resetFocusGamification() async {
    try {
      // Implementar reset real para módulo Focus usando Riverpod
      if (_container != null) {
        final focusService = _container!.read(focusServiceProvider);
        await focusService.resetProgress();
        LoggerService.instance.gamification('Focus gamification resetada com sucesso');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para FocusService');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar Focus gamification', error: e);
    }
  }

  /// Reseta gamificação do módulo Spending
  Future<void> _resetSpendingGamification() async {
    try {
      // Resetar apenas gamificação (streaks, medalhas, score), NÃO apagar dados reais do usuário
      if (_container != null) {
        final gamificationNotifier = _container!.read(spendingGamificationNotifierProvider.notifier);
        await gamificationNotifier.resetProgress();
        LoggerService.instance.gamification('Spending gamification resetada com sucesso (streaks/medalhas)');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para SpendingGamificationNotifier');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar Spending gamification', error: e);
    }
  }

  /// Reseta gamificação do módulo Smoking
  Future<void> _resetSmokingGamification() async {
    try {
      // Implementar reset real para módulo Smoking usando Riverpod
      if (_container != null) {
        final smokingService = _container!.read(smokingServiceProvider);
        await smokingService.archiveAndReset();
        LoggerService.instance.gamification('Smoking gamification resetada com sucesso');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para SmokingService');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar Smoking gamification', error: e);
    }
  }

  /// Reseta gamificação do módulo Diet
  Future<void> _resetDietGamification() async {
    try {
      // Implementar reset real para módulo Diet usando novo sistema de gamificação
      if (_container != null) {
        final gamificationNotifier = _container!.read(dietGamificationNotifierProvider.notifier);
        await gamificationNotifier.resetProgress();
        LoggerService.instance.gamification('Diet gamification resetada com sucesso');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para DietGamificationNotifier');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar Diet gamification', error: e);
    }
  }

  /// Reseta gamificação do módulo Binge Eating
  Future<void> _resetBingeEatingGamification() async {
    try {
      if (_container != null) {
        final gamificationController = _container!.read(bingeEatingGamificationNotifierProvider.notifier);
        await gamificationController.resetProgress();
        LoggerService.instance.gamification('Binge Eating gamification resetada com sucesso (streak/stats)');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para BingeEatingGamificationNotifier');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar Binge Eating gamification', error: e);
    }
  }

  /// Reseta gamificação do módulo Adult Content
  Future<void> _resetAdultContentGamification() async {
    try {
      // Implementar reset real para módulo Adult Content usando Riverpod
      if (_container != null) {
        final adultContentService = _container!.read(adultContentServiceProvider);
        await adultContentService.resetStats();
        LoggerService.instance.gamification('Adult Content gamification resetada com sucesso');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para AdultContentService');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar Adult Content gamification', error: e);
    }
  }

  /// Reseta gamificação do módulo Digital Detox
  Future<void> _resetDigitalDetoxGamification() async {
    try {
      if (_container != null) {
        final userId = _container!.read(digitalDetoxCurrentUserIdProvider);
        final repository = DigitalDetoxGamificationRepository(
          ObjectBoxService.instance.store.box<DigitalDetoxGamificationEntity>()
        );
        final service = DigitalDetoxGamificationService(repository);
        
        await service.resetStreak(userId);
        LoggerService.instance.gamification('Digital Detox gamification resetada com sucesso (streak/stats)');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para DigitalDetoxGamificationService');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar Digital Detox gamification', error: e);
    }
  }

  /// Mostra notificação de reset
  Future<void> _showResetNotification(AppLockEvent lockEvent) async {
    try {
      final moduleName = _getModuleName(lockEvent.nicheId);
      
      // Implementar notificação local básica
      await _showBasicNotification(
        title: '⚠️ Gamificação Resetada',
        body: 'Você abriu ${lockEvent.appName} e perdeu seu progresso em $moduleName.',
      );
      
      LoggerService.instance.gamification('Notificação de reset exibida para ${lockEvent.appName} - Módulo: $moduleName');
      
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar notificação', error: e);
    }
  }

  /// Mostra notificação básica usando o sistema existente
  Future<void> _showBasicNotification({
    required String title,
    required String body,
  }) async {
    try {
      // Usar a instância singleton já inicializada no bootstrap
      // NOTA: Não chamar initialize() novamente pois já foi feito no AppBootstrap
      final plugin = ns.flutterLocalNotificationsPlugin;

      // Criar notificação
      await plugin.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(1000),
        title: title,
        body: body,
        payload: null,
        notificationDetails: const fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            'app_lock_channel',
            'App Lock Notifications',
            channelDescription: 'Notificações do sistema de App Lock',
            importance: fln.Importance.high,
            priority: fln.Priority.high,
            playSound: true,
            enableVibration: true,
            color: Colors.orange, // Laranja Disciplinum
          ),
        ),
      );
      
      LoggerService.instance.gamification('Notificação local exibida: $title - $body');
      
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar notificação local', error: e);
      // Fallback para logging se notificação falhar
      LoggerService.instance.gamification('NOTIFICAÇÃO: $title - $body');
    }
  }

  /// Obtém o nome do módulo para exibição
  static String _getModuleName(NicheId nicheId) {
    switch (nicheId) {
      case NicheId.focus:
        return 'Foco e Produtividade';
      case NicheId.spending:
        return 'Controle de Gastos';
      case NicheId.smoking:
        return 'Controle do Fumo';
      case NicheId.diet:
        return 'Compulsão Alimentar';
      case NicheId.bingeEating:
        return 'Compulsão Alimentar';
      case NicheId.adultContent:
        return 'Jejum 18+';
      case NicheId.digitalDetox:
        return 'Jejum Digital';
      default:
        return 'Módulo Desconhecido';
    }
  }

  /// Obtém mensagem de alerta personalizada por módulo
  static String _getModuleAlertMessage(NicheId nicheId) {
    switch (nicheId) {
      case NicheId.focus:
        return '⚠️ ATENÇÃO: Este app está bloqueado pelo seu modo Foco. Mantenha sua concentração!';
      case NicheId.spending:
        return '💰 ATENÇÃO: Este app pode afetar seu controle de gastos. Deseja continuar?';
      case NicheId.smoking:
        return '🚭 ATENÇÃO: Este app compromete sua meta de parar de fumar. Resista!';
      case NicheId.diet:
        return '🥗 ATENÇÃO: Este app pode comprometer sua dieta. Escolha sabiamente!';
      case NicheId.bingeEating:
        return '🍔 ATENÇÃO: Este app pode desencadear compulsão alimentar. Pense antes!';
      case NicheId.adultContent:
        return '🔞 ATENÇÃO: Este conteúdo está bloqueado pelo seu Jejum 18+. Mantenha seu foco!';
      case NicheId.digitalDetox:
        return '📱 ATENÇÃO: Este app está sendo monitorado pelo seu Jejum Digital. Use com consciência!';
      default:
        return '⚠️ ATENÇÃO: Este app está sendo monitorado.';
    }
  }

  /// Fecha o app bloqueado via MethodChannel
  Future<void> _closeBlockedApp(String packageName) async {
    try {
      await AppLockChannel.closeBlockedApp(packageName);
      LoggerService.instance.gamification('App bloqueado fechado: $packageName');
    } catch (e) {
      LoggerService.instance.e('Erro ao fechar app bloqueado', error: e);
    }
  }
}
