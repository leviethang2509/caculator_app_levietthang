import 'dart:math' as math;

class ExpressionParser {
  static String normalizeExpression(String expression) {
    final compact = expression
        .replaceAll(' ', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', 'pi')
        .replaceAll('√', 'sqrt')
        .replaceAll('∛', 'cbrt')
        .replaceAll('log₂', 'logtwo')
        .replaceAll('log2', 'logtwo');

    return _addImplicitMultiplication(compact);
  }

  static double evaluateExpression(
    String expression, {
    required bool isDegreeMode,
  }) {
    final parser = _Parser(expression, isDegreeMode: isDegreeMode);
    return parser.parse();
  }

  static String _addImplicitMultiplication(String input) {
    final buffer = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      final current = input[i];
      buffer.write(current);

      if (i == input.length - 1) {
        continue;
      }

      final next = input[i + 1];
      final currentEndsValue = _isDigit(current) || current == ')' || current == '!';
      final nextStartsValue = next == '(' || _isLetter(next);
      final constantFollowedByValue =
          (current == 'i' || current == 'e') && (next == '(' || _isDigit(next));

      if ((currentEndsValue && nextStartsValue) || constantFollowedByValue) {
        buffer.write('*');
      }
    }

    return buffer.toString();
  }

  static bool _isDigit(String value) {
    return RegExp(r'[0-9.]').hasMatch(value);
  }

  static bool _isLetter(String value) {
    return RegExp(r'[a-zA-Z]').hasMatch(value);
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
        final divisor = parseFactor();
        if (divisor == 0) {
          throw Exception('Không thể chia cho 0');
        }
        x /= divisor;
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
    } else if (_isNumberChar(currentChar)) {
      while (_isNumberChar(currentChar)) {
        nextChar();
      }
      x = double.parse(text.substring(startPos, pos));
    } else if (_isNameChar(currentChar)) {
      while (_isNameChar(currentChar)) {
        nextChar();
      }

      final name = text.substring(startPos, pos);

      if (name == 'pi') {
        x = math.pi;
      } else if (name == 'e') {
        x = math.e;
      } else {
        if (eat('('.codeUnitAt(0))) {
          final arg = parseExpression();
          if (!eat(')'.codeUnitAt(0))) {
            throw Exception('Thiếu dấu ) sau hàm');
          }
          x = _applyFunction(name, arg);
        } else {
          x = _applyFunction(name, parseFactor());
        }
      }
    } else {
      throw Exception('Biểu thức không hợp lệ');
    }

    while (true) {
      if (eat('^'.codeUnitAt(0))) {
        x = math.pow(x, parseFactor()).toDouble();
      } else if (eat('!'.codeUnitAt(0))) {
        x = _factorial(x);
      } else {
        return x;
      }
    }
  }

  bool _isNumberChar(int char) {
    return (char >= '0'.codeUnitAt(0) && char <= '9'.codeUnitAt(0)) ||
        char == '.'.codeUnitAt(0);
  }

  bool _isNameChar(int char) {
    return (char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0)) ||
        (char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0));
  }

  double _applyFunction(String func, double value) {
    switch (func) {
      case 'sqrt':
        return math.sqrt(value);
      case 'cbrt':
        return value < 0
            ? -math.pow(-value, 1 / 3).toDouble()
            : math.pow(value, 1 / 3).toDouble();
      case 'sin':
        return math.sin(_toRadians(value));
      case 'cos':
        return math.cos(_toRadians(value));
      case 'tan':
        return math.tan(_toRadians(value));
      case 'asin':
        return _fromRadians(math.asin(value));
      case 'acos':
        return _fromRadians(math.acos(value));
      case 'atan':
        return _fromRadians(math.atan(value));
      case 'ln':
        return math.log(value);
      case 'log':
        return math.log(value) / math.ln10;
      case 'logtwo':
        return math.log(value) / math.ln2;
      case 'abs':
        return value.abs();
      case 'factorial':
        return _factorial(value);
      default:
        throw Exception('Hàm không hỗ trợ: $func');
    }
  }

  double _toRadians(double value) {
    return isDegreeMode ? value * math.pi / 180 : value;
  }

  double _fromRadians(double value) {
    return isDegreeMode ? value * 180 / math.pi : value;
  }

  double _factorial(double value) {
    if (value < 0 || value != value.toInt()) {
      throw Exception('Giai thừa không hợp lệ');
    }

    double result = 1;
    for (int i = 1; i <= value.toInt(); i++) {
      result *= i;
    }
    return result;
  }
}
