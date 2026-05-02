import 'package:flutter/material.dart';

import '../models/calculation_history.dart';

class DisplayArea extends StatelessWidget {
  final String expression;
  final String result;
  final String previousResult;
  final String errorMessage;
  final double fontScale;
  final List<CalculationHistory> histories;
  final ValueChanged<CalculationHistory> onHistoryTap;

  const DisplayArea({
    super.key,
    required this.expression,
    required this.result,
    required this.previousResult,
    required this.errorMessage,
    required this.fontScale,
    required this.histories,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 230;
        final padding = compact ? 10.0 : 16.0;
        final margin = compact
            ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
            : const EdgeInsets.fromLTRB(16, 10, 16, 12);
        final historyHeight = compact ? 0.0 : 64.0;

        return Container(
          width: double.infinity,
          margin: margin,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (histories.isNotEmpty && !compact)
                SizedBox(
                  height: historyHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: histories.length,
                    itemBuilder: (context, index) {
                      final item = histories[index];
                      return GestureDetector(
                        onTap: () => onHistoryTap(item),
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.expression,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12 * fontScale,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.result,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (histories.isNotEmpty && !compact) const SizedBox(height: 8),

              SizedBox(
                height: compact ? 18 : 22,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    previousResult.isEmpty ? '' : 'Ans: $previousResult',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (compact ? 12 : 15) * fontScale,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                    ),
                  ),
                ),
              ),

              SizedBox(height: compact ? 3 : 6),

              Expanded(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      expression.isEmpty ? '0' : expression,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: (compact ? 20 : 26) * fontScale,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: compact ? 2 : 4),

              Flexible(
                flex: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: errorMessage.isNotEmpty
                          ? Text(
                              errorMessage,
                              key: ValueKey(errorMessage),
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: (compact ? 13 : 15) * fontScale,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Text(
                              result,
                              key: ValueKey(result),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: (compact ? 26 : 34) * fontScale,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
