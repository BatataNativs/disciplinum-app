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
  /// Tema Dark Completo - Todas as cores extraídas do tema escuro do app
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
      textTheme: base.textTheme
          .apply(
            fontFamily: 'Roboto',
            bodyColor: onSurfacePrimary,
            displayColor: onSurfacePrimary,
          )
          .copyWith(
            // Títulos - branco 100%
            displayLarge:
                base.textTheme.displayLarge?.copyWith(color: onSurfacePrimary),
            displayMedium:
                base.textTheme.displayMedium?.copyWith(color: onSurfacePrimary),
            displaySmall:
                base.textTheme.displaySmall?.copyWith(color: onSurfacePrimary),
            headlineLarge:
                base.textTheme.headlineLarge?.copyWith(color: onSurfacePrimary),
            headlineMedium: base.textTheme.headlineMedium
                ?.copyWith(color: onSurfacePrimary),
            headlineSmall:
                base.textTheme.headlineSmall?.copyWith(color: onSurfacePrimary),
            titleLarge:
                base.textTheme.titleLarge?.copyWith(color: onSurfacePrimary),
            titleMedium:
                base.textTheme.titleMedium?.copyWith(color: onSurfacePrimary),
            titleSmall:
                base.textTheme.titleSmall?.copyWith(color: onSurfacePrimary),

            // Corpo - branco 100% ou 70%
            bodyLarge:
                base.textTheme.bodyLarge?.copyWith(color: onSurfacePrimary),
            bodyMedium:
                base.textTheme.bodyMedium?.copyWith(color: onSurfaceSecondary),
            bodySmall:
                base.textTheme.bodySmall?.copyWith(color: onSurfaceTertiary),

            // Labels - branco 70% ou 60%
            labelLarge:
                base.textTheme.labelLarge?.copyWith(color: onSurfaceSecondary),
            labelMedium:
                base.textTheme.labelMedium?.copyWith(color: onSurfaceTertiary),
            labelSmall:
                base.textTheme.labelSmall?.copyWith(color: onSurfaceMuted),
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
  /// Baseado em tons de rosa com fundo quente e boa legibilidade
  static ThemeData get pinkTheme {
    final base = ThemeData.light();

    // Cores do tema rosa com boa legibilidade
    const pinkPrimary = Color(0xFFC2185B); // Rosa escuro (melhor legibilidade)
    const pinkLight = Color.fromARGB(255, 249, 212, 227); // Rosa claro
    const pinkSecondary = Color(0xFFE91E63); // Rosa médio
    const scaffoldBg = Color(0xFFFCE4EC); // Pink 50 (fundo rosa para contraste)
    const surfaceLight = Color(0xFFF8BBD0); // Pink 100
    const surfaceElevated = Color(0xFFFFFFFF); // Cards brancos
    const onSurfacePrimary =
        Color(0xFF210016); // Texto escuro (alta legibilidade)
    const onSurfaceSecondary = Color(0xFF5D4037); // Texto marrom escuro
    const outlineColor = Color(0x1FC2185B); // Rosa com opacidade

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: pinkPrimary,

      // ColorScheme completo
      colorScheme: base.colorScheme.copyWith(
        primary: pinkPrimary,
        onPrimary: Colors.white, // Texto branco sobre rosa escuro
        primaryContainer: pinkLight,
        onPrimaryContainer: pinkPrimary,

        secondary: pinkSecondary,
        onSecondary: Colors.white,
        secondaryContainer: pinkLight.withValues(alpha: 0.5),
        onSecondaryContainer: pinkSecondary,

        surface: surfaceLight,
        onSurface: onSurfacePrimary,
        surfaceContainerHighest: surfaceElevated,
        surfaceContainerHigh: surfaceElevated.withValues(alpha: 0.95),
        surfaceContainer: surfaceElevated,
        surfaceTint: pinkPrimary,

        error: const Color(0xFFD32F2F),
        onError: Colors.white,

        outline: outlineColor,
        outlineVariant: outlineColor.withValues(alpha: 0.5),

        brightness: Brightness.light,
      ),

      // TextTheme com boa legibilidade
      textTheme: base.textTheme
          .apply(
            fontFamily: 'Roboto',
            bodyColor: onSurfacePrimary,
            displayColor: onSurfacePrimary,
          )
          .copyWith(
            displayLarge:
                base.textTheme.displayLarge?.copyWith(color: onSurfacePrimary),
            displayMedium:
                base.textTheme.displayMedium?.copyWith(color: onSurfacePrimary),
            displaySmall:
                base.textTheme.displaySmall?.copyWith(color: onSurfacePrimary),
            headlineLarge:
                base.textTheme.headlineLarge?.copyWith(color: onSurfacePrimary),
            headlineMedium: base.textTheme.headlineMedium
                ?.copyWith(color: onSurfacePrimary),
            headlineSmall:
                base.textTheme.headlineSmall?.copyWith(color: pinkPrimary),
            titleLarge: base.textTheme.titleLarge?.copyWith(
                color: onSurfacePrimary, fontWeight: FontWeight.bold),
            titleMedium:
                base.textTheme.titleMedium?.copyWith(color: onSurfacePrimary),
            titleSmall:
                base.textTheme.titleSmall?.copyWith(color: onSurfaceSecondary),
            bodyLarge:
                base.textTheme.bodyLarge?.copyWith(color: onSurfacePrimary),
            bodyMedium:
                base.textTheme.bodyMedium?.copyWith(color: onSurfaceSecondary),
            bodySmall:
                base.textTheme.bodySmall?.copyWith(color: onSurfaceSecondary),
            labelLarge: base.textTheme.labelLarge?.copyWith(color: pinkPrimary),
            labelMedium:
                base.textTheme.labelMedium?.copyWith(color: onSurfaceSecondary),
            labelSmall:
                base.textTheme.labelSmall?.copyWith(color: onSurfaceSecondary),
          ),

      // Componentes específicos
      cardColor: surfaceElevated.withValues(alpha: 0.95),

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

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pinkPrimary,
          side: const BorderSide(color: pinkPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: pinkSecondary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
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
          borderSide: const BorderSide(color: pinkPrimary),
        ),
        hintStyle: TextStyle(color: onSurfaceSecondary.withValues(alpha: 0.6)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
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
        backgroundColor: pinkLight.withValues(alpha: 0.3),
        deleteIconColor: pinkPrimary,
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

  /// Tema Halloween 🎃
  /// Baseado em laranja, preto e roxo com boa legibilidade
  static ThemeData get halloweenTheme {
    final base = ThemeData.dark();

    // Cores do tema halloween com boa legibilidade
    const orangePrimary = Color(0xFFFF6D00); // Laranja abóbora moranga vivo
    const orangeLight = Color(0xFFFFB74D); // Laranja claro
    const purpleSecondary = Color(0xFF6A1B9A); // Roxo escuro
    const purpleLight = Color(0xFFCE93D8); // Roxo claro
    const scaffoldBg =
        Color(0xFF0F0F1A); // Fundo quase preto (melhor contraste)
    const surfaceDark = Color(0xFF14141E); // Surface escuro
    const surfaceElevated = Color(0xFF1F1F2E); // Dialogs e containers
    const onSurfacePrimary = Colors.white; // Texto branco (alta legibilidade)
    const onSurfaceSecondary = Color(0xFFE0E0E0); // Texto cinza claro
    const outlineColor =
        Color.fromARGB(37, 255, 255, 255); // Laranja com opacidade

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: orangePrimary,

      // ColorScheme completo
      colorScheme: base.colorScheme.copyWith(
        primary: orangePrimary,
        onPrimary:
            Colors.black, // Texto preto sobre laranja (alta legibilidade)
        primaryContainer: orangeLight.withValues(alpha: 0.2),
        onPrimaryContainer: orangeLight,

        secondary: purpleSecondary,
        onSecondary: Colors.white,
        secondaryContainer: purpleLight.withValues(alpha: 0.15),
        onSecondaryContainer: purpleLight,

        surface: surfaceDark,
        onSurface: onSurfacePrimary,
        surfaceContainerHighest: surfaceElevated,
        surfaceContainerHigh: surfaceElevated.withValues(alpha: 0.95),
        surfaceContainer: surfaceElevated,
        surfaceTint: orangePrimary,

        error: const Color(0xFFEF4444),
        onError: Colors.white,

        outline: outlineColor,
        outlineVariant: outlineColor.withValues(alpha: 0.5),

        brightness: Brightness.dark,
      ),

      // TextTheme com boa legibilidade
      textTheme: base.textTheme
          .apply(
            fontFamily: 'Roboto',
            bodyColor: onSurfacePrimary,
            displayColor: onSurfacePrimary,
          )
          .copyWith(
            displayLarge:
                base.textTheme.displayLarge?.copyWith(color: orangePrimary),
            displayMedium:
                base.textTheme.displayMedium?.copyWith(color: orangePrimary),
            displaySmall:
                base.textTheme.displaySmall?.copyWith(color: orangePrimary),
            headlineLarge:
                base.textTheme.headlineLarge?.copyWith(color: orangePrimary),
            headlineMedium:
                base.textTheme.headlineMedium?.copyWith(color: orangePrimary),
            headlineSmall:
                base.textTheme.headlineSmall?.copyWith(color: orangePrimary),
            titleLarge: base.textTheme.titleLarge?.copyWith(
                color: onSurfacePrimary, fontWeight: FontWeight.bold),
            titleMedium:
                base.textTheme.titleMedium?.copyWith(color: onSurfacePrimary),
            titleSmall:
                base.textTheme.titleSmall?.copyWith(color: onSurfaceSecondary),
            bodyLarge:
                base.textTheme.bodyLarge?.copyWith(color: onSurfacePrimary),
            bodyMedium:
                base.textTheme.bodyMedium?.copyWith(color: onSurfaceSecondary),
            bodySmall:
                base.textTheme.bodySmall?.copyWith(color: onSurfaceSecondary),
            labelLarge:
                base.textTheme.labelLarge?.copyWith(color: orangePrimary),
            labelMedium:
                base.textTheme.labelMedium?.copyWith(color: onSurfaceSecondary),
            labelSmall:
                base.textTheme.labelSmall?.copyWith(color: onSurfaceSecondary),
          ),

      // Componentes específicos
      cardColor: orangePrimary,

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

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: orangePrimary,
          side: const BorderSide(color: orangePrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: purpleSecondary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
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
          borderSide: const BorderSide(color: orangePrimary),
        ),
        hintStyle: TextStyle(color: onSurfaceSecondary.withValues(alpha: 0.6)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
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
        backgroundColor: orangeLight.withValues(alpha: 0.15),
        deleteIconColor: orangePrimary,
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
}
