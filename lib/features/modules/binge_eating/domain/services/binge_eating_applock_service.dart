import 'dart:typed_data';

import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service_isar.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_service.dart';
import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço de integração entre BingeEating e AppLock
/// Gerencia o bloqueio de apps durante o controle alimentar
class BingeEatingAppLockService {
  static BingeEatingAppLockService? _instance;
  static BingeEatingAppLockService get instance => _instance ??= BingeEatingAppLockService._internal();
  
  BingeEatingAppLockService._internal();

  final BingeEatingServiceIsar _bingeService = BingeEatingServiceIsar.instance;

  /// Verifica se um app deve ser bloqueado pelo BingeEating
  Future<bool> shouldBlockApp(String packageName) async {
    try {
      final config = await _bingeService.getConfig();
      
      // Verifica se AppLock está habilitado e o módulo está ativo
      if (!config.enableAppLock || !config.isEnabled) {
        return false;
      }
      
      // Verifica se o app está na lista de monitorados
      if (!config.monitoredApps.contains(packageName)) {
        return false;
      }
      
      // Verifica se está em período de bloqueio
      if (config.blockedUntil != null && config.blockedUntil!.isAfter(DateTime.now())) {
        return true;
      }
      
      return false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar bloqueio de app', error: e);
      return false;
    }
  }

  /// Processa uma violação de AppLock
  Future<void> handleAppLockViolation(String packageName) async {
    try {
      final config = await _bingeService.getConfig();
      
      // Aplica cooldown de bloqueio
      final blockedUntil = DateTime.now().add(Duration(minutes: config.appLockCooldownMinutes));
      
      // Atualiza configuração com período de bloqueio
      final updatedConfig = config.copyWith(
        blockedUntil: blockedUntil,
        blockReason: "Violação do AppLock: $packageName",
      );
      
      await _bingeService.saveConfig(updatedConfig);
      
      LoggerService.instance.i('AppLock violation processed: $packageName blocked until $blockedUntil');
    } catch (e) {
      LoggerService.instance.e('Erro ao processar violação de AppLock', error: e);
    }
  }

  /// Mostra a tela de AppLock para BingeEating
  Future<void> showAppLockScreen(String packageName, String appName, Uint8List? appIconBytes) async {
    try {
      await AppLockService.instance.showAppLockScreen(
        packageName: packageName,
        appName: appName,
        appIconBytes: appIconBytes,
        nicheId: NicheId.bingeEating,
        onOpenApp: () => _handleOpenApp(packageName),
        onExitApp: () => _handleExitApp(packageName),
      );
      
      LoggerService.instance.i('AppLock screen shown for BingeEating: $appName');
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar tela de AppLock', error: e);
    }
  }

  /// Callback quando usuário escolhe abrir o app
  Future<void> _handleOpenApp(String packageName) async {
    try {
      await AppLockService.instance.handleOpenApp(
        AppLockEvent(
          packageName: packageName,
          appName: _getAppName(packageName),
          appIconBytes: null, // Será buscado automaticamente
          nicheId: NicheId.bingeEating,
          alertMessage: "Você escolheu abrir o app durante seu controle alimentar.",
          timestamp: DateTime.now(),
          onExitApp: () => _handleExitApp(packageName),
          onOpenApp: () => _handleOpenApp(packageName),
        ),
      );
      
      // Registra a violação
      await handleAppLockViolation(packageName);
      
      LoggerService.instance.i('User chose to open app during BingeEating: $packageName');
    } catch (e) {
      LoggerService.instance.e('Erro ao processar abertura de app', error: e);
    }
  }

  /// Callback quando usuário escolhe sair do app
  Future<void> _handleExitApp(String packageName) async {
    try {
      await AppLockService.instance.handleExitApp(
        AppLockEvent(
          packageName: packageName,
          appName: _getAppName(packageName),
          appIconBytes: null, // Será buscado automaticamente
          nicheId: NicheId.bingeEating,
          alertMessage: "Ótimo! Você resistiu à tentação durante seu controle alimentar.",
          timestamp: DateTime.now(),
          onExitApp: () => _handleExitApp(packageName),
          onOpenApp: () => _handleOpenApp(packageName),
        ),
      );
      
      LoggerService.instance.i('User chose to exit app during BingeEating: $packageName');
    } catch (e) {
      LoggerService.instance.e('Erro ao processar saída de app', error: e);
    }
  }

  /// Lista de apps comuns para compulsão alimentar
  List<String> getCommonBingeEatingApps() {
    return [
      'com.instagram.android',      // Instagram
      'com.facebook.katana',       // Facebook
      'com.tinder',                // Tinder
      'com.zhiliaoapp.musically', // TikTok
      'com.snapchat.android',      // Snapchat
      'com.twitter.android',       // Twitter
      'com.pinterest',             // Pinterest
      'com.netflix.mediaclient',   // Netflix
      'com.amazon.avod.thirdpartyclient', // Prime Video
      'com.google.android.youtube', // YouTube
      'com.spotify.music',         // Spotify
      'com.whatsapp',              // WhatsApp
      'com.discord',               // Discord
      'com.reddit.frontpage',      // Reddit
    ];
  }

  /// Adiciona apps comuns de compulsão alimentar
  Future<void> addCommonBingeEatingApps() async {
    try {
      final commonApps = getCommonBingeEatingApps();
      final config = await _bingeService.getConfig();
      
      final updatedApps = List<String>.from(config.monitoredApps);
      bool hasChanges = false;
      
      for (final app in commonApps) {
        if (!updatedApps.contains(app)) {
          updatedApps.add(app);
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        final updatedConfig = config.copyWith(monitoredApps: updatedApps);
        await _bingeService.saveConfig(updatedConfig);
        
        LoggerService.instance.i('Common BingeEating apps added: ${commonApps.length} apps');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao adicionar apps comuns', error: e);
    }
  }

  String _getAppName(String packageName) {
    // Mapeamento simples de package names para nomes amigáveis
    final appNames = {
      'com.instagram.android': 'Instagram',
      'com.facebook.katana': 'Facebook',
      'com.tinder': 'Tinder',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.snapchat.android': 'Snapchat',
      'com.twitter.android': 'Twitter',
      'com.pinterest': 'Pinterest',
      'com.netflix.mediaclient': 'Netflix',
      'com.amazon.avod.thirdpartyclient': 'Prime Video',
      'com.google.android.youtube': 'YouTube',
      'com.spotify.music': 'Spotify',
      'com.whatsapp': 'WhatsApp',
      'com.discord': 'Discord',
      'com.reddit.frontpage': 'Reddit',
    };
    
    return appNames[packageName] ?? packageName;
  }
}
