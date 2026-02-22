import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/services/review/review_service.dart';
import 'package:disciplinum/services/user_privacy/privacy_service.dart';
import 'package:disciplinum/services/8_procrastination/procrastination_service.dart';
import 'package:disciplinum/services/4_spending/spending_service.dart';
import 'package:disciplinum/services/9_reading/reading_service.dart';
import 'package:disciplinum/services/7_moneySavingChallenge/money_saving_challenge_service.dart';
import 'package:disciplinum/misc/system_stuff/theme_controller.dart';
import 'package:disciplinum/app.dart';
import 'package:disciplinum/app_router.dart';
import 'package:disciplinum/config/app_config.dart';
import 'package:disciplinum/services/ads/ad_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Mantido para compatibilidade com arquivos que possam usar isso.
class AppRuntimeConfig {
  static String get bannerAdUnitId => AppConfig.admobBannerUnitId;
}

// _Ads e _Tracking removidos/movidos
class _Ads {
  static bool _initialized = false;
  static Future<void> initAtStartup() async {
    if (kIsWeb) return;
    if (_initialized) return;
    try {
      final testDeviceId = AppConfig.admobTestDeviceId;
      final testDevices =
          testDeviceId.isNotEmpty ? <String>[testDeviceId] : <String>[];
      if (testDevices.isNotEmpty) {
        await MobileAds.instance.updateRequestConfiguration(
            RequestConfiguration(testDeviceIds: testDevices));
      }
      MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      debugPrint("Erro ao inicializar AdMob: $e");
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // 🔴🔴🔴 ATENÇÃO: DESCOMENTE A LINHA ABAIXO, RODE O APP UMA VEZ, E DEPOIS COMENTE DE NOVO 🔴🔴🔴
  // Isso é necessário porque o Android restaura o backup mesmo se você desinstalar.
  // Precisamos forçar o 'seen_onboarding' a ser falso para testar se a permissão sumiu.

  //await prefs.clear(); // <--- TIRE O // DESTA LINHA PARA O TESTE LIMPO

  final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  final String initialRoute =
      seenOnboarding ? AppRouter.authWrapper : AppRouter.onboarding;

  if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
    throw Exception(
      'SUPABASE_URL/SUPABASE_ANON_KEY não foram definidos. '
      'Use --dart-define ou --dart-define-from-file.',
    );
  }

  // Ads sempre (mobile), independente do consentimento.
  await _Ads.initAtStartup();

  // Inicializa sistema de notificações locais (CRÍTICO para módulos funcionarem)
  await initNotifications();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Inicializa Privacidade (sem UI, apenas background)
  await PrivacyService.initAtStartup();

  // Verifica se deve pedir review (não bloqueia app)
  ReviewService.checkRequestReview();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),

        // GamificationService é criado aqui. Graças à "blindagem" no arquivo dele,
        // ele não vai pedir permissão se seenOnboarding for false.
        ChangeNotifierProvider(create: (_) => GamificationService()),

        // AdService instanciado diretamente aqui (mantido para futuros anúncios globais)
        ChangeNotifierProvider(create: (_) => AdService()),

        ChangeNotifierProvider(
          create: (context) => ProcrastinationService(
            Provider.of<GamificationService>(context, listen: false),
            prefs,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ReadingService(prefs),
        ),
        ChangeNotifierProvider<MoneySavingChallengeService>(
          create: (_) => MoneySavingChallengeService(),
        ),
        ChangeNotifierProvider(
          create: (context) => SpendingService(prefs),
        ),

        ChangeNotifierProvider(
          create: (context) {
            final authService = AuthService();

            // LÓGICA DE CALLBACK MELHORADA (Sua solicitação)
            // Define o callback, mas busca o Provider apenas na hora da execução.
            authService.onLogoutCallback = () {
              try {
                // listen: false é crucial aqui para não recriar widgets
                Provider.of<GamificationService>(context, listen: false)
                    .stopMonitoringApps();
              } catch (e) {
                debugPrint('Erro seguro ao tentar parar monitoramento: $e');
              }
            };

            return authService;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => IapService()..initialize(),
        ),
      ],
      child: DisciplinumApp(initialRoute: initialRoute),
    ),
  );
}
