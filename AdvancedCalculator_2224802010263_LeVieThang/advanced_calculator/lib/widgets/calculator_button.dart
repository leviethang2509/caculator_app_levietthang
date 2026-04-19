import 'package:flutter/material.dart';

class CalculatorButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onLongPress,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOperator = _isOperatorButton(widget.label);
    final isEqual = widget.label == '=';
    final isMemory = ['MC', 'MR', 'M+', 'M-'].contains(widget.label);

    Color backgroundColor = theme.colorScheme.secondary.withOpacity(0.14);
    Color foregroundColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    if (isOperator) {
      backgroundColor = theme.colorScheme.tertiary.withOpacity(0.18);
      foregroundColor = theme.colorScheme.tertiary;
    }

    if (isMemory) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.10);
    }

    if (isEqual) {
      backgroundColor = theme.colorScheme.tertiary;
      foregroundColor = Colors.white;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onPressed,
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isOperatorButton(String value) {
    return [
      '÷',
      '×',
      '-',
      '+',
      '=',
      '%',
      '√',
      'x²',
      'x³',
      'xʸ',
      'sin',
      'cos',
      'tan',
      'ln',
      'log',
      'AND',
      'OR',
      'XOR',
      'NOT',
      '<<1',
      '>>1',
    ].contains(value);
  }
}