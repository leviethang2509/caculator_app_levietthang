import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/calculator_provider.dart';
import 'providers/history_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/calculator_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService)..loadTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(storageService)..loadHistory(),
        ),
        ChangeNotifierProvider(
          create: (_) => CalculatorProvider(storageService)..loadSettings(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Advanced Calculator',
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            home: const CalculatorScreen(),
          );
        },
      ),
    );
  }
}