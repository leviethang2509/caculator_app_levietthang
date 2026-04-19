import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;

  ThemeProvider(this._storageService);

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1E1E1E),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1E1E1E),
          secondary: Color(0xFF424242),
          tertiary: Color(0xFFFF6B6B),
        ),
        useMaterial3: true,
      );

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF121212),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF121212),
          secondary: Color(0xFF2C2C2C),
          tertiary: Color(0xFF4ECDC4),
        ),
        useMaterial3: true,
      );

  void loadTheme() {
    _themeMode = _storageService.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storageService.saveThemeMode(mode);
    notifyListeners();
  }
}