import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'misc/system_stuff/app_themes.dart';
import 'misc/system_stuff/theme_controller.dart';
import 'main.dart'; // Import para acessar o navigatorKey

class DisciplinumApp extends StatelessWidget {
  final String initialRoute; // Novo parâmetro

  const DisciplinumApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return MaterialApp(
      title: 'Disciplinum',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      initialRoute: initialRoute, // Usa a rota dinâmica
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
