import 'dart:math' as math;

class ExpressionParser {
  static String normalizeExpression(String expression) {
    return expression
        .replaceAll(' ', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', 'pi');
  }

  static double evaluateExpression(
    String expression, {
    required bool isDegreeMode,
  }) {
    final parser = _Parser(
      expression,
      isDegreeMode: isDegreeMode,
    );
    return parser.parse();
  }
}

class _Parser {
  final String text;
  final bool isDegreeMode;
  int pos = -1;
  int currentChar = 0;

  _Parser(this.text, {required this.isDegreeMode});

  void nextChar() {
    pos++;
    currentChar = pos < text.length ? text.codeUnitAt(pos) : -1;
  }

  bool eat(int charToEat) {
    while (currentChar == 32) {
      nextChar();
    }
    if (currentChar == charToEat) {
      nextChar();
      return true;
    }
    return false;
  }

  double parse() {
    nextChar();
    final x = parseExpression();
    if (pos < text.length) {
      throw Exception('Ký tự không hợp lệ: ${String.fromCharCode(currentChar)}');
    }
    return x;
  }

  double parseExpression() {
    double x = parseTerm();
    while (true) {
      if (eat('+'.codeUnitAt(0))) {
        x += parseTerm();
      } else if (eat('-'.codeUnitAt(0))) {
        x -= parseTerm();
      } else {
        return x;
      }
    }
  }

  double parseTerm() {
    double x = parseFactor();
    while (true) {
      if (eat('*'.codeUnitAt(0))) {
        x *= parseFactor();
      } else if (eat('/'.codeUnitAt(0))) {
        x /= parseFactor();
      } else if (eat('%'.codeUnitAt(0))) {
        x %= parseFactor();
      } else {
        return x;
      }
    }
  }

  double parseFactor() {
    if (eat('+'.codeUnitAt(0))) {
      return parseFactor();
    }
    if (eat('-'.codeUnitAt(0))) {
      return -parseFactor();
    }

    double x;
    final startPos = pos;

    if (eat('('.codeUnitAt(0))) {
      x = parseExpression();
      if (!eat(')'.codeUnitAt(0))) {
        throw Exception('Thiếu dấu )');
      }
    } else if ((currentChar >= '0'.codeUnitAt(0) &&
            currentChar <= '9'.codeUnitAt(0)) ||
        currentChar == '.'.codeUnitAt(0)) {
      while ((currentChar >= '0'.codeUnitAt(0) &&
              currentChar <= '9'.codeUnitAt(0)) ||
          currentChar == '.'.codeUnitAt(0)) {
        nextChar();
      }
      x = double.parse(text.substring(startPos, pos));
    } else if ((currentChar >= 'a'.codeUnitAt(0) &&
            currentChar <= 'z'.codeUnitAt(0)) ||
        (currentChar >= 'A'.codeUnitAt(0) &&
            currentChar <= 'Z'.codeUnitAt(0))) {
      while ((currentChar >= 'a'.codeUnitAt(0) &&
              currentChar <= 'z'.codeUnitAt(0)) ||
          (currentChar >= 'A'.codeUnitAt(0) &&
              currentChar <= 'Z'.codeUnitAt(0))) {
        nextChar();
      }

      final func = text.substring(startPos, pos);

      if (func == 'pi') {
        x = math.pi;
      } else if (func == 'e') {
        x = math.e;
      } else {
        if (eat('('.codeUnitAt(0))) {
          final arg = parseExpression();
          if (!eat(')'.codeUnitAt(0))) {
            throw Exception('Thiếu dấu ) sau hàm');
          }
          x = _applyFunction(func, arg);
        } else {
          x = parseFactor();
          x = _applyFunction(func, x);
        }
      }
    } else {
      throw Exception('Biểu thức không hợp lệ');
    }

    if (eat('^'.codeUnitAt(0))) {
      x = math.pow(x, parseFactor()).toDouble();
    }

    return x;
  }

  double _applyFunction(String func, double value) {
    switch (func) {
      case 'sqrt':
        return math.sqrt(value);
      case 'sin':
        return math.sin(isDegreeMode ? value * math.pi / 180 : value);
      case 'cos':
        return math.cos(isDegreeMode ? value * math.pi / 180 : value);
      case 'tan':
        return math.tan(isDegreeMode ? value * math.pi / 180 : value);
      case 'ln':
        return math.log(value);
      case 'log':
        return math.log(value) / math.ln10;
      case 'abs':
        return value.abs();
      case 'factorial':
        if (value < 0 || value != value.toInt()) {
          throw Exception('Giai thừa không hợp lệ');
        }
        double result = 1;
        for (int i = 1; i <= value.toInt(); i++) {
          result *= i;
        }
        return result;
      default:
        throw Exception('Hàm không hỗ trợ: $func');
    }
  }
}