import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculatorProvider = context.watch<CalculatorProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const ListTile(
            title: Text(
              'Giao diện',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            title: const Text('Light'),
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            title: const Text('Dark'),
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            title: const Text('System'),
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          const Divider(),

          const ListTile(
            title: Text(
              'Tính toán',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            value: calculatorProvider.settings.isDegreeMode,
            title: const Text('Angle Mode: Degree'),
            subtitle: const Text('Bật = DEG, Tắt = RAD'),
            onChanged: (value) {
              calculatorProvider.setAngleMode(value);
            },
          ),
          ListTile(
            title: const Text('Decimal Precision'),
            subtitle: Text(
              '${calculatorProvider.settings.decimalPrecision} chữ số',
            ),
          ),
          Slider(
            value: calculatorProvider.settings.decimalPrecision.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            label: calculatorProvider.settings.decimalPrecision.toString(),
            onChanged: (value) {
              calculatorProvider.setDecimalPrecision(value.round());
            },
          ),
          const Divider(),

          const ListTile(
            title: Text(
              'Phản hồi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            value: calculatorProvider.settings.hapticFeedback,
            title: const Text('Haptic Feedback'),
            onChanged: (value) {
              calculatorProvider.setHapticFeedback(value);
            },
          ),
          SwitchListTile(
            value: calculatorProvider.settings.soundEffects,
            title: const Text('Sound Effects'),
            onChanged: (value) {
              calculatorProvider.setSoundEffects(value);
            },
          ),
          const Divider(),

          const ListTile(
            title: Text(
              'Lịch sử',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('History Size'),
            subtitle: Text(
              '${calculatorProvider.settings.historySize} phép tính',
            ),
          ),
          Slider(
            value: calculatorProvider.settings.historySize.toDouble(),
            min: 25,
            max: 100,
            divisions: 3,
            label: calculatorProvider.settings.historySize.toString(),
            onChanged: (value) {
              int newSize = 50;
              if (value < 37.5) {
                newSize = 25;
              } else if (value < 62.5) {
                newSize = 50;
              } else if (value < 87.5) {
                newSize = 75;
              } else {
                newSize = 100;
              }
              calculatorProvider.setHistorySize(newSize);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear All History'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xóa lịch sử'),
                  content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await context.read<HistoryProvider>().clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa toàn bộ lịch sử')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}