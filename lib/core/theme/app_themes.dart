import 'package:flutter/material.dart';
import 'package:disciplinum/core/utils/fast_page_transitions.dart';

class AppColors {
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonWhite = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF050816);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);
}

class AppThemes {
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      primaryColor: AppColors.neonBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: const Color.fromARGB(255, 57, 92, 208),
        secondary: const Color.fromARGB(255, 245, 250, 251),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: const Color.fromARGB(255, 255, 255, 255),
        displayColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      cardColor: AppColors.darkCard.withValues(alpha: 0.9),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 253, 255, 255),
          foregroundColor: const Color.fromARGB(255, 10, 10, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FastPageTransitionsBuilder(),
          TargetPlatform.iOS: FastPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    const darkBlue = Color(0xFF1F13C6);

    return base.copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(
          255, 241, 241, 241), // Cor de fundo (tela perfil e configurações)
      primaryColor: darkBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: const Color.fromARGB(255, 16, 10, 88),
        secondary: const Color.fromARGB(255, 16, 10, 88),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      cardColor:
          const Color.fromARGB(255, 241, 241, 241).withValues(alpha: 0.95),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FastPageTransitionsBuilder(),
          TargetPlatform.iOS: FastPageTransitionsBuilder(),
        },
      ),
    );
  }
}
