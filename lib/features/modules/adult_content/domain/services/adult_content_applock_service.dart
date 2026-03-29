import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service_isar.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_service.dart';
import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço de integração entre AdultContent e AppLock
/// Gerencia o bloqueio de apps durante o controle de conteúdo adulto
class AdultContentAppLockService {
  static AdultContentAppLockService? _instance;
  static AdultContentAppLockService get instance => _instance ??= AdultContentAppLockService._internal();
  
  AdultContentAppLockService._internal();

  final AdultContentServiceIsar _adultService = AdultContentServiceIsar.instance;

  /// Verifica se um app deve ser bloqueado pelo AdultContent
  Future<bool> shouldBlockApp(String packageName) async {
    try {
      final config = await _adultService.getConfig();
      
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
      final config = await _adultService.getConfig();
      
      // Aplica cooldown de bloqueio (mais longo para conteúdo adulto)
      final blockedUntil = DateTime.now().add(Duration(minutes: config.appLockCooldownMinutes));
      
      // Atualiza configuração com período de bloqueio
      final updatedConfig = config.copyWith(
        blockedUntil: blockedUntil,
        blockReason: "Violação do AppLock: $packageName",
      );
      
      await _adultService.saveConfig(updatedConfig);
      
      LoggerService.instance.i('AppLock violation processed: $packageName blocked until $blockedUntil');
    } catch (e) {
      LoggerService.instance.e('Erro ao processar violação de AppLock', error: e);
    }
  }

  /// Mostra a tela de AppLock para AdultContent
  Future<void> showAppLockScreen(String packageName, String appName, String appIcon) async {
    try {
      await AppLockService.instance.showAppLockScreen(
        packageName: packageName,
        appName: appName,
        appIcon: appIcon,
        nicheId: NicheId.adultContent,
        onOpenApp: () => _handleOpenApp(packageName),
        onExitApp: () => _handleExitApp(packageName),
      );
      
      LoggerService.instance.i('AppLock screen shown for Adult Content: $appName');
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
          appIcon: _getAppIcon(packageName),
          nicheId: NicheId.adultContent,
          alertMessage: "Você escolheu acessar conteúdo adulto durante seu período de controle.",
          timestamp: DateTime.now(),
          onExitApp: () => _handleExitApp(packageName),
          onOpenApp: () => _handleOpenApp(packageName),
        ),
      );
      
      // Registra a violação
      await handleAppLockViolation(packageName);
      
      LoggerService.instance.i('User chose to open app during Adult Content control: $packageName');
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
          appIcon: _getAppIcon(packageName),
          nicheId: NicheId.adultContent,
          alertMessage: "Excelente! Você resistiu à tentação durante seu controle de conteúdo adulto.",
          timestamp: DateTime.now(),
          onExitApp: () => _handleExitApp(packageName),
          onOpenApp: () => _handleOpenApp(packageName),
        ),
      );
      
      LoggerService.instance.i('User chose to exit app during Adult Content control: $packageName');
    } catch (e) {
      LoggerService.instance.e('Erro ao processar saída de app', error: e);
    }
  }

  /// Lista de apps comuns para conteúdo adulto
  List<String> getCommonAdultContentApps() {
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
      'com.badoo.mobile',          // Badoo
      'com.okcupid.okcupid',       // OkCupid
      'com.match.dating',          // Match
      'com.grindrapp.android',     // Grindr
      'com.scorpion.mobile',       // Hornet
      'com.jackd.android',         // Jack'd
    ];
  }

  /// Adiciona apps comuns de conteúdo adulto
  Future<void> addCommonAdultContentApps() async {
    try {
      final commonApps = getCommonAdultContentApps();
      final config = await _adultService.getConfig();
      
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
        await _adultService.saveConfig(updatedConfig);
        
        LoggerService.instance.i('Common Adult Content apps added: ${commonApps.length} apps');
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
      'com.badoo.mobile': 'Badoo',
      'com.okcupid.okcupid': 'OkCupid',
      'com.match.dating': 'Match',
      'com.grindrapp.android': 'Grindr',
      'com.scorpion.mobile': 'Hornet',
      'com.jackd.android': "Jack'd",
    };
    
    return appNames[packageName] ?? packageName;
  }

  String _getAppIcon(String packageName) {
    // Mapeamento simples de package names para ícones
    final appIcons = {
      'com.instagram.android': '📷',
      'com.facebook.katana': '📘',
      'com.tinder': '🔥',
      'com.zhiliaoapp.musically': '🎵',
      'com.snapchat.android': '👻',
      'com.twitter.android': '🐦',
      'com.pinterest': '📌',
      'com.netflix.mediaclient': '🎬',
      'com.amazon.avod.thirdpartyclient': '📺',
      'com.google.android.youtube': '▶️',
      'com.spotify.music': '🎶',
      'com.whatsapp': '💬',
      'com.discord': '💎',
      'com.reddit.frontpage': '🤖',
      'com.badoo.mobile': '💑',
      'com.okcupid.okcupid': '❤️',
      'com.match.dating': '💝',
      'com.grindrapp.android': '🌈',
      'com.scorpion.mobile': '🦂',
      'com.jackd.android': '🦁',
    };
    
    return appIcons[packageName] ?? '📱';
  }
}
