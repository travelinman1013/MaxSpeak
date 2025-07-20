import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  late SharedPreferences _prefs;

  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final themeIndex = _prefs.getInt(_themeKey) ?? 0;
      state = AppThemeMode.values[themeIndex];
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      // Keep default system theme
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    try {
      state = theme;
      await _prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  bool get isDarkMode {
    switch (state) {
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.system:
        // This will be handled at the widget level with MediaQuery
        return false;
    }
  }
}

/// Provider for theme management
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>(
  (ref) => ThemeNotifier(),
);

/// Provider for getting the current ThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeMode = ref.watch(themeProvider);
  return themeMode.themeMode;
});