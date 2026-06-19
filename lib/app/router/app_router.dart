import 'package:disciplinum/features/home/presentation/screens/home_screen_guest.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/features/home/presentation/screens/home_screen.dart';
import 'package:disciplinum/features/settings/presentation/screens/settings_screen.dart';
import 'package:disciplinum/features/profile/presentation/screens/profile_screen.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:disciplinum/features/auth/presentation/screens/auth_screen.dart';
import 'package:disciplinum/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:disciplinum/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/app/auth_wrapper.dart';
import 'package:disciplinum/features/profile/presentation/screens/my_progress_screen.dart';
import 'package:disciplinum/core/utils/fast_page_transitions.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/stop_smoking_screen.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/screens/binge_eating_screen.dart';
import 'package:disciplinum/features/modules/diet/presentation/screens/diet_settings_screen.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/spending_screen.dart';
import 'package:disciplinum/features/modules/focus/presentation/screens/focus_screen.dart';
import 'package:disciplinum/features/modules/adult_content/presentation/screens/avoid_adult_content_screen.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/money_saving_challenge_screen.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/screens/procrastination_screen.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/reading_screen.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_screen.dart';

// --- IMPORT DA NOVA TELA ---
import 'package:disciplinum/features/iap/presentation/screens/lojinha_screen.dart';
import 'package:disciplinum/features/app_lock/presentation/screens/app_lock_screen.dart';
import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';

class AppRouter {
  static const homeGuest = '/home_guest';
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String authWrapper = '/auth_wrapper';
  static const String nicheDetail = '/niche_detail';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String schedule = '/schedule';
  static const String selectApps = '/select_apps';
  static const String resetPassword = '/reset-password';
  static const String myProgress = '/my_progress';
  static const String stopSmoking = '/stop_smoking';
  static const String reading = '/reading'; // Módulo 9
  static const String shop = '/lojinha'; // Rota da lojinha
  static const String auth = '/auth';

  static const String login = '/auth';
  static const String signup = '/auth';
  static const String appLock = '/lock'; // Rota para LockActivity nativa

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.welcome:
        return FastMaterialPageRoute(builder: (_) => const WelcomeScreen());

      case homeGuest:
        return MaterialPageRoute(builder: (_) => const HomeScreenGuest());

      case AppRouter.home:
        return FastMaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      // --- CORREÇÃO AQUI: Adicionando a rota da Lojinha ---
      case AppRouter.shop:
        return FastMaterialPageRoute(
          builder: (_) => const LojinhaScreen(),
        );
      // ---------------------------------------------------

      case AppRouter.myProgress:
        return FastMaterialPageRoute(
          builder: (_) => const MyProgressScreen(),
        );

      case AppRouter.stopSmoking:
        return FastMaterialPageRoute(
          builder: (_) => const StopSmokingScreen(),
        );

      case AppRouter.nicheDetail:
        final args = settings.arguments;
        Niche? niche;
        String? heroTag;

        if (args is Niche) {
          niche = args;
        } else if (args is Map<String, dynamic>) {
          niche = args['niche'] as Niche?;
          heroTag = args['heroTag'] as String?;
        }

        if (niche == null) {
          return _errorRoute('Argumento inválido para Detalhes do Nicho');
        }

        switch (niche.nicheId) {
          case NicheId.smoking:
            return FastMaterialPageRoute(
                builder: (_) => StopSmokingScreen(heroTag: heroTag));
          case NicheId.bingeEating:
            return FastMaterialPageRoute(
                builder: (_) => BingeEatingScreen(heroTag: heroTag));
          case NicheId.diet:
            return FastMaterialPageRoute(
                builder: (_) => DietSettingsScreen(heroTag: heroTag));
          case NicheId.spending:
            return FastMaterialPageRoute(
                builder: (_) => SpendingScreen(heroTag: heroTag));
          case NicheId.focus:
            return FastMaterialPageRoute(
                builder: (_) => FocusScreen(heroTag: heroTag));
          case NicheId.adultContent:
            return FastMaterialPageRoute(
                builder: (_) => AvoidAdultContentScreen(heroTag: heroTag));
          case NicheId.moneySavingChallenge:
            return FastMaterialPageRoute(
                builder: (_) => MoneySavingChallengeScreen(heroTag: heroTag));
          case NicheId.procrastination:
            final initialTabIndex = (args is Map<String, dynamic>)
                ? (args['initialTabIndex'] as int? ?? 0)
                : 0;
            return FastMaterialPageRoute(
                builder: (_) => ProcrastinationScreen(
                    heroTag: heroTag ?? 'procrastination_default',
                    initialTabIndex: initialTabIndex));
          case NicheId.reading:
            final initialTabIndex = (args is Map<String, dynamic>)
                ? (args['initialTabIndex'] as int? ?? 0)
                : 0;
            return FastMaterialPageRoute(
                builder: (_) => ReadingScreen(
                    heroTag: heroTag, initialTabIndex: initialTabIndex));
          case NicheId.digitalDetox:
            return FastMaterialPageRoute(
                builder: (_) => DigitalDetoxScreen(heroTag: heroTag));
        }

      case AppRouter.settings:
        return FastMaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      case AppRouter.profile:
        return FastMaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case AppRouter.schedule:
        final args = settings.arguments;
        if (args is! ScheduleScreenArgs) {
          return _errorRoute('Faltam argumentos para Agendamento');
        }
        return FastMaterialPageRoute(
          builder: (_) => ScheduleScreen(args: args),
        );

      case AppRouter.selectApps:
        final args = settings.arguments;
        if (args is! SelectAppsScreenArgs) {
          return _errorRoute('Faltam argumentos para Seleção de Apps');
        }
        return FastMaterialPageRoute(
          builder: (_) => SelectAppsScreen(args: args),
        );

      case AppRouter.auth:
        final initialMode = settings.arguments as int? ?? 0;
        return FastMaterialPageRoute(
          builder: (_) => AuthScreen(initialAuthMode: initialMode),
        );

      case AppRouter.resetPassword:
        return FastMaterialPageRoute(
            builder: (_) => const ResetPasswordScreen());

      case AppRouter.onboarding:
        return FastMaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRouter.authWrapper:
        return FastMaterialPageRoute(
            builder: (_) => const AuthWrapperWithoutHomeValues());

      case AppRouter.appLock:
        // Extrair parâmetros da query string passados pela LockActivity nativa
        // Formato: /lock?package=com.instagram.android&module=instagram&name=Instagram
        final uri = Uri.parse(settings.name ?? '');
        final packageName = uri.queryParameters['package'] ?? '';
        final moduleId = uri.queryParameters['module'] ?? '';
        final moduleName = uri.queryParameters['name'] ?? '';

        // Criar AppLockEvent com os parâmetros
        final lockEvent = AppLockEvent(
          packageName: packageName,
          appName: moduleName,
          appIconBytes: null, // Ícone será buscado depois se necessário
          nicheId: _getNicheIdFromModuleId(moduleId),
          alertMessage: _getCustomMessageForModule(moduleId),
          timestamp: DateTime.now(),
          onExitApp: () {
            // Callback será configurado pelo AppLockService
          },
          onOpenApp: () {
            // Callback será configurado pelo AppLockService
          },
        );

        return FastMaterialPageRoute(
          builder: (_) => AppLockScreen(lockEvent: lockEvent),
          fullscreenDialog: true,
        );

      default:
        // Se a rota começa com /lock, tratar como appLock (pois pode ter query params)
        if (settings.name != null && settings.name!.startsWith('/lock')) {
          final uri = Uri.parse(settings.name!);
          final packageName = uri.queryParameters['package'] ?? '';
          final moduleId = uri.queryParameters['module'] ?? '';
          final moduleName = uri.queryParameters['name'] ?? '';

          final lockEvent = AppLockEvent(
            packageName: packageName,
            appName: moduleName,
            appIconBytes: null,
            nicheId: _getNicheIdFromModuleId(moduleId),
            alertMessage: _getCustomMessageForModule(moduleId),
            timestamp: DateTime.now(),
            onExitApp: () {},
            onOpenApp: () {},
          );

          return FastMaterialPageRoute(
            builder: (_) => AppLockScreen(lockEvent: lockEvent),
            fullscreenDialog: true,
          );
        }

        if (settings.name == '/login' || settings.name == '/signup') {
          final mode = settings.name == '/signup' ? 1 : 0;
          return FastMaterialPageRoute(
            builder: (_) => AuthScreen(initialAuthMode: mode),
          );
        }
        return FastMaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }

  static Route _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erro de Navegação')),
        body: Center(child: Text(message)),
      ),
    );
  }

  /// Converte moduleId do LockDecisionEngine para NicheId
  static NicheId _getNicheIdFromModuleId(String moduleId) {
    switch (moduleId) {
      case 'instagram':
      case 'facebook':
      case 'twitter':
      case 'tiktok':
      case 'youtube':
      case 'reddit':
      case 'snapchat':
      case 'whatsapp':
      case 'linkedin':
      case 'pinterest':
        return NicheId.digitalDetox; // Apps sociais são monitorados por Digital Detox
      default:
        return NicheId.digitalDetox; // Fallback
    }
  }

  /// Retorna mensagem customizada para o módulo
  static String _getCustomMessageForModule(String moduleId) {
    switch (moduleId) {
      case 'instagram':
        return 'Você configurou o Jejum Digital. Deseja abrir Instagram?';
      case 'facebook':
        return 'Você configurou o Jejum Digital. Deseja abrir Facebook?';
      case 'twitter':
        return 'Você configurou o Jejum Digital. Deseja abrir X (Twitter)?';
      case 'tiktok':
        return 'Você configurou o Jejum Digital. Deseja abrir TikTok?';
      case 'youtube':
        return 'Você configurou o Jejum Digital. Deseja abrir YouTube?';
      default:
        return 'Você configurou um módulo de monitoramento. Deseja continuar?';
    }
  }
}
