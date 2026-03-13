import 'package:flutter/material.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:disciplinum/app.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/app/bootstrap.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/infrastructure/ads/ad_service.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/core/theme/theme_controller.dart';
import 'package:disciplinum/core/events/event_bootstrap.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Mantido para compatibilidade com arquivos que possam usar isso.
class AppRuntimeConfig {
  static String get bannerAdUnitId =>
      'placeholder'; // Será movido para AppConfig
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialização centralizada via bootstrap
    final startupData = await AppBootstrap.initialize();

    // Inicializar sistema de eventos
    await EventBootstrap.initialize();

    // Determinar rota inicial
    final String initialRoute = startupData.seenOnboarding
        ? AppRouter.authWrapper
        : AppRouter.onboarding;

    runApp(
      MultiProvider(
        providers: [
          // Providers do bootstrap
          ...AppBootstrap.setupProviders(),

          // Providers existentes (serão migrados gradualmente)
          ChangeNotifierProvider<AdService>(create: (_) => AdService()),
          ChangeNotifierProvider<ProcrastinationService>(
            create: (context) => ProcrastinationService(
              Provider.of<GamificationService>(context, listen: false),
              startupData.prefs,
            ),
          ),
          ChangeNotifierProvider<ReadingService>(
            create: (context) => ReadingService(
              startupData.prefs,
              context.read<GamificationService>(),
            ),
          ),
          ChangeNotifierProvider<MoneySavingChallengeService>(
            create: (_) => MoneySavingChallengeService(),
          ),
          ChangeNotifierProvider<SpendingService>(
            create: (context) => SpendingService(startupData.prefs),
          ),
          ChangeNotifierProvider<IapService>(
            create: (_) => IapService()..initialize(),
          ),
        ],
        child: DisciplinumApp(initialRoute: initialRoute),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      LoggerService.instance.e('Erro durante inicialização do app', error: e);
    }

    // Fallback para inicialização mínima em caso de erro
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GamificationService.instance),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => ThemeController()),
        ],
        child: DisciplinumApp(initialRoute: AppRouter.onboarding),
      ),
    );
  }
}
