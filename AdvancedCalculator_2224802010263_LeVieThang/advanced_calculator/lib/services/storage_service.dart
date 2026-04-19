import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';

class StorageService {
  static const String _themeKey = 'theme_mode';
  static const String _historyKey = 'history';
  static const String _modeKey = 'calculator_mode';
  static const String _settingsKey = 'calculator_settings';
  static const String _memoryKey = 'memory_value';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs?.setString(_themeKey, mode.name);
  }

  ThemeMode loadThemeMode() {
    final value = _prefs?.getString(_themeKey) ?? ThemeMode.system.name;
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveHistory(List<CalculationHistory> history) async {
    final data = history.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs?.setStringList(_historyKey, data);
  }

  List<CalculationHistory> loadHistory() {
    final data = _prefs?.getStringList(_historyKey) ?? [];
    return data
        .map((e) => CalculationHistory.fromMap(jsonDecode(e)))
        .toList();
  }

  Future<void> saveCalculatorMode(CalculatorMode mode) async {
    await _prefs?.setString(_modeKey, mode.name);
  }

  CalculatorMode loadCalculatorMode() {
    final value = _prefs?.getString(_modeKey) ?? CalculatorMode.basic.name;
    return CalculatorMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CalculatorMode.basic,
    );
  }

  Future<void> saveSettings(CalculatorSettings settings) async {
    await _prefs?.setString(_settingsKey, jsonEncode(settings.toMap()));
  }

  CalculatorSettings loadSettings() {
    final value = _prefs?.getString(_settingsKey);
    if (value == null) {
      return CalculatorSettings.defaultSettings();
    }

    return CalculatorSettings.fromMap(jsonDecode(value));
  }

  Future<void> saveMemoryValue(double value) async {
    await _prefs?.setDouble(_memoryKey, value);
  }

  double loadMemoryValue() {
    return _prefs?.getDouble(_memoryKey) ?? 0;
  }
}