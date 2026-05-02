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
  Offset _gestureDelta = Offset.zero;
  bool _isPinching = false;

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
        onScaleStart: (details) {
          _baseFontScale = calculatorProvider.settings.fontScale;
          _gestureDelta = Offset.zero;
          _isPinching = false;
        },
        onScaleUpdate: (details) {
          if (details.pointerCount > 1) {
            _isPinching = true;
            calculatorProvider.setFontScale(_baseFontScale * details.scale);
          } else {
            _gestureDelta += details.focalPointDelta;
          }
        },
        onScaleEnd: (_) {
          if (_isPinching) {
            return;
          }

          const swipeThreshold = 48.0;
          final dx = _gestureDelta.dx;
          final dy = _gestureDelta.dy;

          if (dx.abs() > dy.abs() && dx.abs() > swipeThreshold) {
            calculatorProvider.deleteLast();
          } else if (dy < -swipeThreshold) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          }
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
                  expression: calculatorProvider.displayExpression,
                  result: calculatorProvider.result,
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
                      case 'CLR':
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
                        final result = cp.completeEvaluation();
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
                      case 'AND':
                      case 'OR':
                      case 'XOR':
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
