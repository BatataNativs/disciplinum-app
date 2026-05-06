import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:disciplinum/features/app_lock/infrastructure/services/navigation_service.dart';
import 'package:disciplinum/features/app_lock/infrastructure/channels/app_lock_channel.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Serviço principal de App Lock
/// Gerencia o sistema de bloqueio consciente para todos os módulos
class AppLockService {
  static AppLockService? _instance;
  static AppLockService get instance => _instance ??= AppLockService._();
  
  // Container para acessar os providers
  static ProviderContainer? _container;
  
  static void setContainer(ProviderContainer container) {
    _container = container;
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
      final alertMessage = 'Atenção! Este app está sendo monitorado.';
      
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
      // Implementar reset real para módulo Spending usando Riverpod
      if (_container != null) {
        final spendingService = _container!.read(spendingServiceProvider);
        // SpendingService tem método clearAllExpenses() que deleta todas as despesas
        await spendingService.clearAllExpenses();
        LoggerService.instance.gamification('Spending gamification resetada com sucesso');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para SpendingService');
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
      // Implementar reset real para módulo Diet usando Riverpod
      if (_container != null) {
        final dietService = _container!.read(dietServiceProvider);
        await dietService.resetDailyProgress();
        LoggerService.instance.gamification('Diet gamification resetada com sucesso');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para DietService');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar Diet gamification', error: e);
    }
  }

  /// Reseta gamificação do módulo Binge Eating
  Future<void> _resetBingeEatingGamification() async {
    try {
      // Implementar reset real para módulo Binge Eating usando Riverpod
      if (_container != null) {
        final bingeEatingService = _container!.read(bingeEatingServiceProvider);
        // Para BingeEating, deletamos todos os episódios usando os métodos reais
        final episodes = bingeEatingService.episodes;
        for (final episode in episodes) {
          await bingeEatingService.deleteEpisode(episode.id);
        }
        LoggerService.instance.gamification('Binge Eating gamification resetada com sucesso');
      } else {
        LoggerService.instance.w('Container Riverpod não disponível para BingeEatingService');
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
      // Implementar notificação local real com flutter_local_notifications
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Inicializar notificações
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

      // Criar notificação
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(1000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'app_lock_channel',
            'App Lock Notifications',
            channelDescription: 'Notificações do sistema de App Lock',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            color: Colors.orange, // Laranja Disciplinum
          ),
          iOS: DarwinNotificationDetails(),
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
        return 'Evitar Conteúdo Adulto';
      default:
        return 'Módulo Desconhecido';
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
