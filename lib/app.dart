import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/theme/app_themes.dart';
import 'package:disciplinum/core/theme/theme_controller.dart';
import 'package:disciplinum/main.dart';

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
