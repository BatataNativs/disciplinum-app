import 'package:flutter/material.dart';

// Exportações dos widgets compartilhados com tema neon
export 'forms/custom_text_field.dart';
export 'forms/neon_switch.dart';
export 'forms/neon_checkbox.dart';
export 'cards/neon_card.dart';
export 'cards/stats_card.dart';
export 'buttons/custom_button.dart';
export 'buttons/neon_button.dart';
export 'buttons/neon_floating_action_button.dart';
export 'dialogs/confirmation_dialog.dart';
export 'dialogs/neon_dialog.dart';
export 'dialogs/app_dialog.dart';
export 'loading/neon_loading_indicator.dart';
export 'indicators/neon_progress_indicator.dart';
export 'indicators/neon_badge.dart';
export 'lists/neon_list_tile.dart';

// Cores do tema neon
class AppColors {
  static const neonBlue = Color(0xFF00FFFF);
  static const neonPink = Color(0xFFFF6B6B);
  static const neonGreen = Color(0xFF00FF88);
  static const neonYellow = Color(0xFFFFFF00);
  static const neonPurple = Color(0xFF8B00FF);
  static const neonOrange = Color(0xFFFFA500);
}

// Gradientes neon
class AppGradients {
  static final neonBlueGradient = LinearGradient(
    colors: [AppColors.neonBlue, AppColors.neonBlue.withValues(alpha: 0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final neonPinkGradient = LinearGradient(
    colors: [AppColors.neonPink, AppColors.neonPink.withValues(alpha: 0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final neonGreenGradient = LinearGradient(
    colors: [AppColors.neonGreen, AppColors.neonGreen.withValues(alpha: 0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final neonYellowGradient = LinearGradient(
    colors: [AppColors.neonYellow, AppColors.neonYellow.withValues(alpha: 0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Helpers para UI consistente
class UIHelpers {
  static BoxDecoration getNeonBorder({
    Color borderColor = AppColors.neonBlue,
    Color glowColor = AppColors.neonBlue,
    double borderWidth = 2,
    double glowBlur = 8,
    double glowSpread = 2,
  }) {
    return BoxDecoration(
      color: Colors.black,
      border: Border.all(
        color: borderColor.withValues(alpha: 0.5),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.2),
          blurRadius: glowBlur,
          spreadRadius: glowSpread,
        ),
      ],
    );
  }

  static TextStyle getNeonTextStyle({
    Color color = AppColors.neonBlue,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  static EdgeInsets getNeonPadding() {
    return const EdgeInsets.all(16);
  }

  static BorderRadius getNeonBorderRadius() {
    return BorderRadius.circular(12);
  }

  static List<BoxShadow> getNeonBoxShadow({
    Color color = AppColors.neonBlue,
    double blurRadius = 8,
    double spreadRadius = 2,
    double alpha = 0.2,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}

// Temas neon pré-definidos
class NeonThemes {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.neonBlue,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.black,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.neonBlue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.neonBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonBlue,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }
}

// Constantes de design
class DesignConstants {
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  
  static const double smallBorderRadius = 8.0;
  static const double mediumBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  
  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 14.0;
  static const double largeFontSize = 16.0;
  static const double extraLargeFontSize = 18.0;
  static const double titleFontSize = 24.0;
}
