import 'dart:math' as math;

import 'package:advancedcalculator/providers/calculator_provider.dart';
import 'package:advancedcalculator/services/storage_service.dart';
import 'package:advancedcalculator/utils/calculator_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorLogic', () {
    test('handles operator precedence and parentheses', () {
      final result = CalculatorLogic.evaluate(
        '(5 + 3) * 2 - 4 / 2',
        isDegreeMode: true,
        precision: 4,
      );

      expect(result, '14');
    });

    test('handles nested parentheses', () {
      final result = CalculatorLogic.evaluate(
        '((2 + 3) * (4 - 1)) / 5',
        isDegreeMode: true,
        precision: 4,
      );

      expect(result, '3');
    });

    test('handles degree trigonometry', () {
      final result = CalculatorLogic.evaluate(
        'sin(45) + cos(45)',
        isDegreeMode: true,
        precision: 3,
      );

      expect(double.parse(result), closeTo(math.sqrt2, 0.001));
    });

    test('handles constants, implicit multiplication, and square root', () {
      final result = CalculatorLogic.evaluate(
        '2*pi*sqrt(9)',
        isDegreeMode: true,
        precision: 2,
      );

      expect(double.parse(result), closeTo(18.85, 0.01));
    });

    test('handles logarithm, power, cube root, and factorial', () {
      expect(
        CalculatorLogic.evaluate('log2(8)', isDegreeMode: true, precision: 4),
        '3',
      );
      expect(
        CalculatorLogic.evaluate('2^3', isDegreeMode: true, precision: 4),
        '8',
      );
      expect(
        CalculatorLogic.evaluate('cbrt(27)', isDegreeMode: true, precision: 4),
        '3',
      );
      expect(
        CalculatorLogic.evaluate('5!', isDegreeMode: true, precision: 4),
        '120',
      );
    });

    test('throws for invalid expressions', () {
      expect(
        () => CalculatorLogic.evaluate(
          '5 / 0',
          isDegreeMode: true,
          precision: 4,
        ),
        throwsException,
      );
    });
  });

  group('CalculatorProvider memory', () {
    test('handles 5 M+ 3 M+ MR = 8', () {
      final provider = CalculatorProvider(StorageService());

      provider.appendValue('5');
      provider.memoryAdd();
      provider.appendValue('3');
      provider.memoryAdd();
      provider.memoryRecall();

      expect(provider.expression, '8');
      expect(provider.result, '8');
      expect(provider.memoryValue, 8);
    });
  });
}
