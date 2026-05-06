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
  /// Tema Dark Completo - Todas as cores extraídas dos isDark do app
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    
    // Cores primárias do app (indigo/violeta)
    const primaryIndigo = Color(0xFF6366F1);
    const primaryIndigoLight = Color(0xFF818CF8);
    const secondaryViolet = Color(0xFF8B5CF6);
    
    // Cores de fundo (extraídas dos gradientes e scaffold)
    const scaffoldBg = Color(0xFF000000); // Colors.black
    const surfaceDark = Color(0xFF0F0F0F); // Fundo escuro principal
    const surfaceElevated = Color(0xFF1A1A2E); // Cards/bottom sheets
    const surfaceContainer = Color(0xFF1E1E1E); // Dialogs
    // Cores de texto (opacidades do white)
    const onSurfacePrimary = Colors.white; // 100%
    const onSurfaceSecondary = Color(0xB3FFFFFF); // white70 ~70%
    const onSurfaceTertiary = Color(0x99FFFFFF); // white60 ~60%
    const onSurfaceMuted = Color(0x8AFFFFFF); // white54 ~54%
    const onSurfaceDisabled = Color(0x61FFFFFF); // white38 ~38%
    
    // Cores de borda e outline
    const outlineColor = Color(0x14FFFFFF); // white.withAlpha(20) ~8%
    const outlineVariant = Color(0x0AFFFFFF); // white.withAlpha(10) ~4%
    
    // Cores de estado/feedback
    const errorColor = Color(0xFFEF4444);
    
    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primaryIndigo,
      
      // ColorScheme completo
      colorScheme: base.colorScheme.copyWith(
        primary: primaryIndigo,
        onPrimary: Colors.black, // Texto sobre indigo
        primaryContainer: Color(0x1F6366F1), // indigo.withAlpha(31) ~12%
        onPrimaryContainer: primaryIndigoLight,
        
        secondary: secondaryViolet,
        onSecondary: Colors.white,
        secondaryContainer: Color(0x1F8B5CF6), // violet.withAlpha(31)
        onSecondaryContainer: secondaryViolet,
        
        surface: surfaceDark,
        onSurface: onSurfacePrimary,
        surfaceContainerHighest: surfaceElevated,
        surfaceContainerHigh: surfaceContainer,
        surfaceContainer: surfaceContainer,
        surfaceTint: primaryIndigo,
        
        error: errorColor,
        onError: Colors.white,
        
        outline: outlineColor,
        outlineVariant: outlineVariant,
        
        brightness: Brightness.dark,
      ),
      
      // TextTheme com todas as opacidades
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: onSurfacePrimary,
        displayColor: onSurfacePrimary,
      ).copyWith(
        // Títulos - branco 100%
        displayLarge: base.textTheme.displayLarge?.copyWith(color: onSurfacePrimary),
        displayMedium: base.textTheme.displayMedium?.copyWith(color: onSurfacePrimary),
        displaySmall: base.textTheme.displaySmall?.copyWith(color: onSurfacePrimary),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(color: onSurfacePrimary),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(color: onSurfacePrimary),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(color: onSurfacePrimary),
        titleLarge: base.textTheme.titleLarge?.copyWith(color: onSurfacePrimary),
        titleMedium: base.textTheme.titleMedium?.copyWith(color: onSurfacePrimary),
        titleSmall: base.textTheme.titleSmall?.copyWith(color: onSurfacePrimary),
        
        // Corpo - branco 100% ou 70%
        bodyLarge: base.textTheme.bodyLarge?.copyWith(color: onSurfacePrimary),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(color: onSurfaceSecondary),
        bodySmall: base.textTheme.bodySmall?.copyWith(color: onSurfaceTertiary),
        
        // Labels - branco 70% ou 60%
        labelLarge: base.textTheme.labelLarge?.copyWith(color: onSurfaceSecondary),
        labelMedium: base.textTheme.labelMedium?.copyWith(color: onSurfaceTertiary),
        labelSmall: base.textTheme.labelSmall?.copyWith(color: onSurfaceMuted),
      ),
      
      // Componentes específicos
      cardColor: surfaceElevated.withValues(alpha: 0.9),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: onSurfacePrimary),
        titleTextStyle: TextStyle(
          color: onSurfacePrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Botões claros no dark
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurfacePrimary,
          side: const BorderSide(color: outlineColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: onSurfaceSecondary,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryIndigo),
        ),
        hintStyle: const TextStyle(color: onSurfaceDisabled),
      ),
      
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: outlineColor,
        thickness: 1,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: primaryIndigo.withValues(alpha: 0.1),
        deleteIconColor: onSurfaceSecondary,
        labelStyle: const TextStyle(color: onSurfacePrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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

  /// Tema Rosa 🌸
  /// Baseado em tons de rosa com fundo quente
  static ThemeData get pinkTheme {
    final base = ThemeData.light();
    const pinkPrimary = Color(0xFFE91E63);
    const pinkSecondary = Color(0xFFF48FB1);
    
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFFF0F5), // Lavender Blush
      primaryColor: pinkPrimary,
      colorScheme: base.colorScheme.copyWith(
        primary: pinkPrimary,
        secondary: pinkSecondary,
        surface: const Color.fromARGB(255, 232, 134, 152),
        onSurface: const Color(0xFF4A0033),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: const Color(0xFF4A0033),
        displayColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      cardColor: Colors.white.withValues(alpha: 0.95),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: pinkPrimary),
        titleTextStyle: TextStyle(
          color: pinkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pinkPrimary,
          foregroundColor: Colors.white,
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

  /// Tema Halloween 🎃
  /// Baseado em laranja, preto e roxo
  static ThemeData get halloweenTheme {
    final base = ThemeData.dark();
    const orangePrimary = Color(0xFFFF6D00);
    const purpleSecondary = Color(0xFF7B1FA2);
    
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF1A0F00), // Fundo escuro alaranjado
      primaryColor: orangePrimary,
      colorScheme: base.colorScheme.copyWith(
        primary: orangePrimary,
        secondary: purpleSecondary,
        surface: const Color(0xFF2A1F0A),
        onSurface: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: Colors.white,
        displayColor: orangePrimary,
      ),
      cardColor: const Color(0xFF2A1F0A).withValues(alpha: 0.9),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: orangePrimary),
        titleTextStyle: TextStyle(
          color: orangePrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangePrimary,
          foregroundColor: Colors.black,
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
}
