import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({
    required bool isDark,
    required Color primaryColor,
  })  : _isDark = isDark,
        _primaryColor = primaryColor;

  static const _isDarkKey = 'isDark';
  static const _primaryKey = 'primaryColor';

  bool _isDark;
  Color _primaryColor;

  bool get isDark => _isDark;
  Color get primaryColor => _primaryColor;

  Future<void> toggleDarkMode(bool value) async {
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkKey, value);
  }

  Future<void> setPrimary(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryKey, color.value);
  }

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_isDarkKey) ?? false;
    final primary = prefs.getInt(_primaryKey) ?? const Color(0xFFFFB703).value;
    return ThemeController(
      isDark: isDark,
      primaryColor: Color(primary),
    );
  }
}
