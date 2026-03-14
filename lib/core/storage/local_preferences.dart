import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localPrefsProvider = Provider<LocalPreferencesService>(
  (_) => LocalPreferencesService._instance,
);

class LocalPreferencesService {
  static final _instance = LocalPreferencesService._();
  LocalPreferencesService._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _themeKey = 'theme_mode';

  ThemeMode get themeMode {
    final value = _prefs.getString(_themeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return _prefs.setString(_themeKey, value);
  }
}
