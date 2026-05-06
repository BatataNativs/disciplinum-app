import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/core/theme/app_themes.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';

/// Controller de temas usando StateNotifier (Riverpod)
/// 
/// Suporta múltiplos temas: light, dark, pink, halloween
/// 
/// USO: Acesse o tema atual via Theme.of(context) nas widgets
/// use Theme.of(context).brightness == Brightness.dark
class ThemeController extends StateNotifier<AppTheme> {
  static const String _themeKey = 'app_theme';
  
  final ObjectBoxPreferencesRepository _preferences;
  
  ThemeController(this._preferences) : super(AppTheme.light) {
    _loadSavedTheme();
  }

  /// Tema atual
  AppTheme get currentTheme => state;
  
  /// ThemeData a ser aplicado no MaterialApp
  ThemeData get themeData {
    return switch (state) {
      AppTheme.light => AppThemes.lightTheme,
      AppTheme.dark => AppThemes.darkTheme,
      AppTheme.pink => AppThemes.pinkTheme,
      AppTheme.halloween => AppThemes.halloweenTheme,
    };
  }

  /// Define um novo tema
  Future<void> setTheme(AppTheme theme) async {
    if (state != theme) {
      state = theme;
      await _saveTheme(theme);
    }
  }

  /// Carrega tema salvo
  Future<void> _loadSavedTheme() async {
    try {
      final savedTheme = await _preferences.getString(_themeKey);
      if (savedTheme != null && savedTheme.isNotEmpty) {
        state = AppTheme.fromString(savedTheme);
      }
    } catch (e) {
      // Fallback para tema claro em caso de erro
      state = AppTheme.light;
    }
  }

  /// Salva tema atual
  Future<void> _saveTheme(AppTheme theme) async {
    try {
      await _preferences.setString(_themeKey, theme.name);
    } catch (e) {
      // Silenciosamente ignora erro de persistência
    }
  }
}
