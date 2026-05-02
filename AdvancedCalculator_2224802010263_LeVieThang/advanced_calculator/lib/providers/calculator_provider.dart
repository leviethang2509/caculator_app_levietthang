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
  String? _pendingBitwiseOperation;
  int? _pendingBitwiseValue;
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
        .replaceAll('/', '÷')
        .replaceAll('sqrt', '√')
        .replaceAll('cbrt', '∛')
        .replaceAll('log2', 'log₂');
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
      case '∛':
        _expression += 'cbrt(';
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
      case 'n!':
        _expression += '!';
        break;
      case 'log₂':
        _expression += 'log2(';
        break;
      case 'ln':
      case 'log':
      case 'sin':
      case 'cos':
      case 'tan':
      case 'asin':
      case 'acos':
      case 'atan':
        _expression += '$value(';
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
    _pendingBitwiseOperation = null;
    _pendingBitwiseValue = null;
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
    } catch (_) {
      _errorMessage = 'Lỗi biểu thức';
      notifyListeners();
      return _result;
    }
  }

  String completeEvaluation() {
    if (_pendingBitwiseOperation != null && _pendingBitwiseValue != null) {
      _completeBitwiseOperation();
      return _result;
    }

    return evaluateExpression();
  }

  void useResultInExpression() {
    _expression = _result;
    _errorMessage = '';
    notifyListeners();
  }

  void setMode(CalculatorMode newMode) {
    _mode = newMode;
    _pendingBitwiseOperation = null;
    _pendingBitwiseValue = null;
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
    _expression = _formatMemoryValue(_memoryValue);
    _result = _expression;
    _errorMessage = '';
    notifyListeners();
  }

  void memoryAdd() {
    final value = double.tryParse(evaluateExpression()) ?? 0;
    _memoryValue += value;
    _expression = '';
    _result = _formatMemoryValue(_memoryValue);
    _errorMessage = '';
    saveSettings();
    notifyListeners();
  }

  void memorySubtract() {
    final value = double.tryParse(evaluateExpression()) ?? 0;
    _memoryValue -= value;
    _expression = '';
    _result = _formatMemoryValue(_memoryValue);
    _errorMessage = '';
    saveSettings();
    notifyListeners();
  }

  void applyProgrammerOperation(String op) {
    try {
      final current = _parseProgrammerValue(_expression);

      switch (op) {
        case 'NOT':
          _setProgrammerResult(~current);
          return;
        case '<<1':
          _setProgrammerResult(current << 1);
          return;
        case '>>1':
          _setProgrammerResult(current >> 1);
          return;
        case 'BIN':
          _result = current.toRadixString(2);
          notifyListeners();
          return;
        case 'OCT':
          _result = current.toRadixString(8);
          notifyListeners();
          return;
        case 'HEX':
          _result = '0x${current.toRadixString(16).toUpperCase()}';
          notifyListeners();
          return;
        case 'DEC':
          _result = current.toString();
          notifyListeners();
          return;
        case 'AND':
        case 'OR':
        case 'XOR':
          _pendingBitwiseOperation = op;
          _pendingBitwiseValue = current;
          _expression = '';
          _result = '$current $op';
          notifyListeners();
          return;
      }
    } catch (_) {
      _errorMessage = 'Lỗi chế độ lập trình';
      notifyListeners();
    }
  }

  int applyBitwiseExpression(String first, String op, String second) {
    final a = _parseProgrammerValue(first);
    final b = _parseProgrammerValue(second);
    switch (op) {
      case 'AND':
        return a & b;
      case 'OR':
        return a | b;
      case 'XOR':
        return a ^ b;
      default:
        throw Exception('Phép toán bit không hợp lệ');
    }
  }

  void _completeBitwiseOperation() {
    try {
      final second = _parseProgrammerValue(_expression);
      final value = applyBitwiseExpression(
        _pendingBitwiseValue.toString(),
        _pendingBitwiseOperation!,
        second.toString(),
      );
      _setProgrammerResult(value);
      _pendingBitwiseOperation = null;
      _pendingBitwiseValue = null;
    } catch (_) {
      _errorMessage = 'Lỗi phép toán bit';
      notifyListeners();
    }
  }

  void _setProgrammerResult(int value) {
    _result = value.toString();
    _previousResult = _result;
    _expression = value.toString();
    notifyListeners();
  }

  int _parseProgrammerValue(String value) {
    final text = value.trim();
    if (text.isEmpty) return 0;
    if (text.toLowerCase().startsWith('0x')) {
      return int.parse(text.substring(2), radix: 16);
    }
    if (RegExp(r'^[A-Fa-f]+$').hasMatch(text)) {
      return int.parse(text, radix: 16);
    }
    return int.parse(text);
  }

  String _formatMemoryValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(math.min(_settings.decimalPrecision, 10));
  }
}
