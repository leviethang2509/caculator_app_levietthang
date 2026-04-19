import '../models/calculator_mode.dart';

class AppConstants {
  static const List<String> basicButtons = [
    'C', 'CE', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  static const List<String> scientificButtons = [
    'sin', 'cos', 'tan', 'ln', 'log', '√',
    'x²', 'x³', 'xʸ', '(', ')', '÷',
    'MC', '7', '8', '9', 'C', '×',
    'MR', '4', '5', '6', 'CE', '-',
    'M+', '1', '2', '3', '%', '+',
    'M-', '±', '0', '.', 'π', '=',
  ];

  static const List<String> programmerButtons = [
    'BIN', 'OCT', 'DEC', 'HEX',
    'AND', 'OR', 'XOR', 'NOT',
    '7', '8', '9', '<<1',
    '4', '5', '6', '>>1',
    '1', '2', '3', 'C',
    '0', '.', '=', 'CE',
  ];

  static List<String> getButtonsForMode(CalculatorMode mode) {
    switch (mode) {
      case CalculatorMode.basic:
        return basicButtons;
      case CalculatorMode.scientific:
        return scientificButtons;
      case CalculatorMode.programmer:
        return programmerButtons;
    }
  }
}