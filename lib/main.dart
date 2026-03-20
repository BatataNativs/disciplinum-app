import 'package:flutter/material.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/app/bootstrap.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/theme/app_themes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:disciplinum/core/di/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
  try {
    final startupData = await AppBootstrap.initialize();
    
    runApp(
      ProviderScope(
        overrides: [
          seenOnboardingProvider.overrideWithValue(startupData.seenOnboarding),
          sharedPreferencesProvider.overrideWithValue(startupData.prefs),
        ],
        child: const DisciplinumApp(),
      ),
    );
  } catch (e, stackTrace) {
    LoggerService.instance.e('Error during initialization', error: e, stackTrace: stackTrace);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SelectableText('Critical error during app startup:\n$e'),
        ),
      ),
    ));
  }
}

class DisciplinumApp extends ConsumerWidget {
  const DisciplinumApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.watch(themeControllerProvider);
    final seenOnboarding = ref.watch(seenOnboardingProvider);
    
    return MaterialApp(
      title: 'Disciplinum',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: seenOnboarding 
          ? AppRouter.authWrapper 
          : AppRouter.onboarding,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
