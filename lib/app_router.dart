import 'package:disciplinum/screens/home/home_screen_guest.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/screens/home/home_screen.dart';
import 'package:disciplinum/screens/settings/settings_screen.dart';
import 'package:disciplinum/screens/profile/profile_screen.dart';
import 'package:disciplinum/screens/schedule_screen.dart';
import 'package:disciplinum/screens/select_apps_screen.dart';
import 'package:disciplinum/screens/opening/welcome_screen.dart';
import 'package:disciplinum/screens/auth_signup_login/auth_screen.dart';
import 'package:disciplinum/screens/auth_signup_login/reset_password_screen.dart';
import 'package:disciplinum/screens/opening/onboarding_screen.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/auth_wrapper.dart';
import 'package:disciplinum/screens/profile/my_progress_screen.dart';
import 'package:disciplinum/misc/system_stuff/fast_page_transitions.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/screens/modules/1_smoking/stop_smoking_screen.dart';
import 'package:disciplinum/screens/modules/2_bingeEating/binge_eating_screen.dart';
import 'package:disciplinum/screens/modules/3_diet/diet_settings_screen.dart';
import 'package:disciplinum/screens/modules/4_spending/spending_screen.dart';
import 'package:disciplinum/screens/modules/5_focus/focus_screen.dart';
import 'package:disciplinum/screens/modules/6_adultContent/avoid_adult_content_screen.dart';
import 'package:disciplinum/screens/modules/7_moneySavingChallenge/money_saving_challenge_screen.dart';
import 'package:disciplinum/screens/modules/1_smoking/smoking_notifications_screen.dart';

// --- IMPORT DA NOVA TELA ---
import 'package:disciplinum/screens/misc/lojinha_screen.dart';

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
  static const String shop = '/lojinha'; // Rota da lojinha

  static const String smokingNotifications = '/smoking_notifications';
  static const String auth = '/auth';

  static const String login = '/auth';
  static const String signup = '/auth';

  static Route generateRoute(RouteSettings settings) {
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

      case AppRouter.smokingNotifications:
        return FastMaterialPageRoute(
          builder: (_) => const SmokingNotificationsScreen(),
        );

      case AppRouter.nicheDetail:
        final args = settings.arguments;
        if (args is! Niche) {
          return _errorRoute('Argumento inválido para Detalhes do Nicho');
        }

        switch (args.id) {
          case NicheId.smoking:
            return FastMaterialPageRoute(
                builder: (_) => const StopSmokingScreen());
          case NicheId.bingeEating:
            return FastMaterialPageRoute(
                builder: (_) => const BingeEatingScreen());
          case NicheId.diet:
            return FastMaterialPageRoute(
                builder: (_) => const DietSettingsScreen());
          case NicheId.spending:
            return FastMaterialPageRoute(
                builder: (_) => const SpendingScreen());
          case NicheId.focus:
            return FastMaterialPageRoute(builder: (_) => const FocusScreen());
          case NicheId.adultContent:
            return FastMaterialPageRoute(
                builder: (_) => const AvoidAdultContentScreen());
          case NicheId.moneySavingChallenge:
            return FastMaterialPageRoute(
                builder: (_) => const MoneySavingChallengeScreen());
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

      default:
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
}
