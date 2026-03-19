import 'package:flutter/material.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/app/bootstrap.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/theme/theme_controller.dart';
import 'package:disciplinum/core/theme/app_themes.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
  try {
    final startupData = await AppBootstrap.initialize();
    
    runApp(
      ProviderScope(
        child: provider.MultiProvider(
          providers: AppBootstrap.setupProviders(startupData.prefs),
          child: DisciplinumApp(
            initialRoute: startupData.seenOnboarding 
              ? AppRouter.authWrapper 
              : AppRouter.onboarding,
          ),
        ),
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

class DisciplinumApp extends StatelessWidget {
  final String initialRoute;
  
  const DisciplinumApp({super.key, required this.initialRoute});
  
  @override
  Widget build(BuildContext context) {
    // Usamos context.watch do Provider para reagir ao tema
    final themeController = provider.Provider.of<ThemeController>(context);
    
    return MaterialApp(
      title: 'Disciplinum',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
