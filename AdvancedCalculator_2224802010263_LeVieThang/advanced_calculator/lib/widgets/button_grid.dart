import 'package:flutter/material.dart';

import '../models/calculator_mode.dart';
import '../utils/constants.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  final CalculatorMode mode;
  final ValueChanged<String> onButtonPressed;
  final VoidCallback onLongClearHistory;

  const ButtonGrid({
    super.key,
    required this.mode,
    required this.onButtonPressed,
    required this.onLongClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = AppConstants.getButtonsForMode(mode);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _crossAxisCount(mode);
        final rows = (buttons.length / columns).ceil();
        final spacing = _spacingForHeight(constraints.maxHeight);
        const horizontalPadding = 12.0;
        const bottomPadding = 12.0;

        final usableWidth =
            constraints.maxWidth - horizontalPadding * 2 - spacing * (columns - 1);
        final usableHeight =
            constraints.maxHeight - bottomPadding - spacing * (rows - 1);
        final itemWidth = usableWidth / columns;
        final itemHeight = usableHeight / rows;
        final aspectRatio = itemHeight <= 0 ? 1.0 : itemWidth / itemHeight;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            bottomPadding,
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: buttons.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio.clamp(0.75, 2.4),
            ),
            itemBuilder: (context, index) {
              final label = buttons[index];
              final isClear = label == 'C';
              return CalculatorButton(
                label: label,
                onPressed: () => onButtonPressed(label),
                onLongPress: isClear ? onLongClearHistory : null,
              );
            },
          ),
        );
      },
    );
  }

  int _crossAxisCount(CalculatorMode mode) {
    switch (mode) {
      case CalculatorMode.basic:
        return 4;
      case CalculatorMode.scientific:
        return 6;
      case CalculatorMode.programmer:
        return 4;
    }
  }

  double _spacingForHeight(double height) {
    if (height < 330) return 6;
    if (height < 430) return 8;
    return 10;
  }
}
