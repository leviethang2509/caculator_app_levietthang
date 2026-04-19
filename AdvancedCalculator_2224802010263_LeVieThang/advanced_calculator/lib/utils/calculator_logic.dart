import 'dart:math' as math;

import 'expression_parser.dart';

class CalculatorLogic {
  static String evaluate(
    String expression, {
    required bool isDegreeMode,
    required int precision,
  }) {
    if (expression.trim().isEmpty) {
      return '0';
    }

    final normalized = ExpressionParser.normalizeExpression(expression);
    final value = ExpressionParser.evaluateExpression(
      normalized,
      isDegreeMode: isDegreeMode,
    );

    if (value.isNaN || value.isInfinite) {
      throw Exception('Biểu thức không hợp lệ');
    }

    return _formatNumber(value, precision);
  }

  static String _formatNumber(double value, int precision) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    String text = value.toStringAsFixed(precision);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }

  static double sinValue(double x, bool isDegreeMode) {
    final angle = isDegreeMode ? x * math.pi / 180 : x;
    return math.sin(angle);
  }

  static double cosValue(double x, bool isDegreeMode) {
    final angle = isDegreeMode ? x * math.pi / 180 : x;
    return math.cos(angle);
  }

  static double tanValue(double x, bool isDegreeMode) {
    final angle = isDegreeMode ? x * math.pi / 180 : x;
    return math.tan(angle);
  }

  static double log10Value(double x) {
    return math.log(x) / math.ln10;
  }

  static double lnValue(double x) {
    return math.log(x);
  }

  static double factorialValue(double x) {
    if (x < 0 || x != x.toInt()) {
      throw Exception('Giai thừa không hợp lệ');
    }

    int n = x.toInt();
    double result = 1;
    for (int i = 1; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}