import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final histories = historyProvider.histories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử tính toán'),
        actions: [
          IconButton(
            onPressed: histories.isEmpty
                ? null
                : () async {
                    await historyProvider.clearHistory();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa lịch sử')),
                      );
                    }
                  },
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: histories.isEmpty
          ? const Center(
              child: Text(
                'Chưa có lịch sử tính toán',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              itemCount: histories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = histories[index];
                return ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: Text(item.expression),
                  subtitle: Text(
                    'Kết quả: ${item.result}\n'
                    '${DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    onPressed: () async {
                      await historyProvider.removeHistoryAt(index);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                );
              },
            ),
    );
  }
}