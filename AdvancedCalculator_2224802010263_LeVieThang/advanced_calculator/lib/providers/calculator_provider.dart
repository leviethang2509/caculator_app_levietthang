import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';
import '../utils/calculator_logic.dart';

class CalculatorProvider extends ChangeNotifier {
  final StorageService _storageService;

  CalculatorProvider(this._storageService);

  String _expression = '';
  String _result = '0';
  String _previousResult = '';
  String _errorMessage = '';
  double _memoryValue = 0;
  CalculatorMode _mode = CalculatorMode.basic;
  CalculatorSettings _settings = CalculatorSettings.defaultSettings();

  String get expression => _expression;
  String get result => _result;
  String get previousResult => _previousResult;
  String get errorMessage => _errorMessage;
  double get memoryValue => _memoryValue;
  CalculatorMode get mode => _mode;
  CalculatorSettings get settings => _settings;
  bool get hasMemory => _memoryValue != 0;

  String get displayExpression {
    if (_expression.isEmpty) return '0';

    return _expression
        .replaceAll('pi', 'π')
        .replaceAll('*', '×')
        .replaceAll('/', '÷');
  }

  Future<void> loadSettings() async {
    _settings = _storageService.loadSettings();
    _mode = _storageService.loadCalculatorMode();
    _memoryValue = _storageService.loadMemoryValue();
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await _storageService.saveSettings(_settings);
    await _storageService.saveCalculatorMode(_mode);
    await _storageService.saveMemoryValue(_memoryValue);
  }

  void appendValue(String value) {
    _errorMessage = '';

    switch (value) {
      case 'π':
        _expression += 'pi';
        break;
      case 'e':
        _expression += 'e';
        break;
      case '×':
        _expression += '*';
        break;
      case '÷':
        _expression += '/';
        break;
      case '−':
        _expression += '-';
        break;
      case '√':
        _expression += 'sqrt(';
        break;
      case 'x²':
        _expression += '^2';
        break;
      case 'x³':
        _expression += '^3';
        break;
      case 'xʸ':
        _expression += '^';
        break;
      case 'ln':
        _expression += 'ln(';
        break;
      case 'log':
        _expression += 'log(';
        break;
      case 'sin':
        _expression += 'sin(';
        break;
      case 'cos':
        _expression += 'cos(';
        break;
      case 'tan':
        _expression += 'tan(';
        break;
      case 'mod':
        _expression += '%';
        break;
      default:
        _expression += value;
    }

    notifyListeners();
  }

  void clearAll() {
    _expression = '';
    _result = '0';
    _previousResult = '';
    _errorMessage = '';
    notifyListeners();
  }

  void clearEntry() {
    _expression = '';
    _errorMessage = '';
    notifyListeners();
  }

  void deleteLast() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _errorMessage = '';
      notifyListeners();
    }
  }

  void toggleSign() {
    if (_expression.isEmpty) return;

    if (_expression.startsWith('-')) {
      _expression = _expression.substring(1);
    } else {
      _expression = '-$_expression';
    }
    notifyListeners();
  }

  String evaluateExpression() {
    try {
      _errorMessage = '';

      final evaluated = CalculatorLogic.evaluate(
        _expression,
        isDegreeMode: _settings.isDegreeMode,
        precision: _settings.decimalPrecision,
      );

      _result = evaluated;
      _previousResult = _result;
      notifyListeners();
      return _result;
    } catch (e) {
      _errorMessage = 'Lỗi biểu thức';
      notifyListeners();
      return _result;
    }
  }

  void useResultInExpression() {
    _expression = _result;
    _errorMessage = '';
    notifyListeners();
  }

  void setMode(CalculatorMode newMode) {
    _mode = newMode;
    saveSettings();
    notifyListeners();
  }

  void setDecimalPrecision(int precision) {
    _settings = _settings.copyWith(decimalPrecision: precision);
    saveSettings();
    notifyListeners();
  }

  void setAngleMode(bool isDegree) {
    _settings = _settings.copyWith(isDegreeMode: isDegree);
    saveSettings();
    notifyListeners();
  }

  void setHapticFeedback(bool value) {
    _settings = _settings.copyWith(hapticFeedback: value);
    saveSettings();
    notifyListeners();
  }

  void setSoundEffects(bool value) {
    _settings = _settings.copyWith(soundEffects: value);
    saveSettings();
    notifyListeners();
  }

  void setHistorySize(int size) {
    _settings = _settings.copyWith(historySize: size);
    saveSettings();
    notifyListeners();
  }

  void setFontScale(double scale) {
    _settings = _settings.copyWith(fontScale: scale.clamp(0.8, 1.8));
    saveSettings();
    notifyListeners();
  }

  void memoryClear() {
    _memoryValue = 0;
    saveSettings();
    notifyListeners();
  }

  void memoryRecall() {
    _expression += _formatMemoryValue(_memoryValue);
    notifyListeners();
  }

  void memoryAdd() {
    try {
      final value = double.tryParse(evaluateExpression()) ?? 0;
      _memoryValue += value;
      saveSettings();
      notifyListeners();
    } catch (_) {}
  }

  void memorySubtract() {
    try {
      final value = double.tryParse(evaluateExpression()) ?? 0;
      _memoryValue -= value;
      saveSettings();
      notifyListeners();
    } catch (_) {}
  }

  void applyScientificShortcut(String key) {
    switch (key) {
      case '1/x':
        _expression = '1/($_expression)';
        break;
      case 'n!':
        _expression = 'factorial($_expression)';
        break;
      default:
        appendValue(key);
        return;
    }
    notifyListeners();
  }

  void applyProgrammerOperation(String op) {
    try {
      final current = int.tryParse(_expression) ?? 0;
      int resultValue = current;

      switch (op) {
        case 'NOT':
          resultValue = ~current;
          break;
        case '<<1':
          resultValue = current << 1;
          break;
        case '>>1':
          resultValue = current >> 1;
          break;
        case 'BIN':
          _result = current.toRadixString(2);
          notifyListeners();
          return;
        case 'OCT':
          _result = current.toRadixString(8);
          notifyListeners();
          return;
        case 'HEX':
          _result = current.toRadixString(16).toUpperCase();
          notifyListeners();
          return;
        case 'DEC':
          _result = current.toString();
          notifyListeners();
          return;
      }

      _result = resultValue.toString();
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Lỗi chế độ lập trình';
      notifyListeners();
    }
  }

  void applyBinaryOperation(String op, String secondValue) {
    try {
      final a = int.tryParse(_expression) ?? 0;
      final b = int.tryParse(secondValue) ?? 0;
      int resultValue = 0;

      switch (op) {
        case 'AND':
          resultValue = a & b;
          break;
        case 'OR':
          resultValue = a | b;
          break;
        case 'XOR':
          resultValue = a ^ b;
          break;
      }

      _result = resultValue.toString();
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Lỗi phép toán bit';
      notifyListeners();
    }
  }

  String _formatMemoryValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(
      math.min(_settings.decimalPrecision, 10),
    );
  }
}