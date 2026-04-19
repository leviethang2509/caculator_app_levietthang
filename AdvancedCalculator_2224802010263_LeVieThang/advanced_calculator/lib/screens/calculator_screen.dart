import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calculation_history.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/button_grid.dart';
import '../widgets/display_area.dart';
import '../widgets/mode_selector.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double _baseFontScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final calculatorProvider = context.watch<CalculatorProvider>();
    final historyProvider = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Calculator'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (_) {
          calculatorProvider.deleteLast();
        },
        onScaleStart: (_) {
          _baseFontScale = calculatorProvider.settings.fontScale;
        },
        onScaleUpdate: (details) {
          calculatorProvider.setFontScale(_baseFontScale * details.scale);
        },
        child: SafeArea(
          child: Column(
            children: [
              ModeSelector(
                selectedMode: calculatorProvider.mode,
                isDegreeMode: calculatorProvider.settings.isDegreeMode,
                hasMemory: calculatorProvider.hasMemory,
                onModeChanged: calculatorProvider.setMode,
              ),
              Expanded(
                flex: 3,
                child: DisplayArea(
  expression: calculatorProvider.result,
  result: calculatorProvider.displayExpression,
  previousResult: calculatorProvider.previousResult,
  errorMessage: calculatorProvider.errorMessage,
  fontScale: calculatorProvider.settings.fontScale,
  histories: historyProvider.histories.take(3).toList(),
  onHistoryTap: (item) {
    calculatorProvider.clearEntry();
    calculatorProvider.appendValue(item.expression);
  },
),
                ),
              
              Expanded(
                flex: 5,
                child: ButtonGrid(
                  mode: calculatorProvider.mode,
                  onButtonPressed: (value) async {
                    final cp = calculatorProvider;

                    switch (value) {
                      case 'C':
                        cp.clearAll();
                        break;
                      case 'CE':
                        cp.clearEntry();
                        break;
                      case '⌫':
                        cp.deleteLast();
                        break;
                      case '=':
                        final expressionBefore = cp.expression;
                        final result = cp.evaluateExpression();
                        if (cp.errorMessage.isEmpty &&
                            expressionBefore.isNotEmpty) {
                          await historyProvider.addHistory(
                            CalculationHistory(
                              expression: expressionBefore,
                              result: result,
                              timestamp: DateTime.now(),
                            ),
                            maxSize: cp.settings.historySize,
                          );
                        }
                        break;
                      case '±':
                        cp.toggleSign();
                        break;
                      case 'MC':
                        cp.memoryClear();
                        break;
                      case 'MR':
                        cp.memoryRecall();
                        break;
                      case 'M+':
                        cp.memoryAdd();
                        break;
                      case 'M-':
                        cp.memorySubtract();
                        break;
                      case 'BIN':
                      case 'OCT':
                      case 'DEC':
                      case 'HEX':
                      case 'NOT':
                      case '<<1':
                      case '>>1':
                        cp.applyProgrammerOperation(value);
                        break;
                      default:
                        cp.appendValue(value);
                    }
                  },
                  onLongClearHistory: () async {
                    await historyProvider.clearHistory();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã xóa toàn bộ lịch sử'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}