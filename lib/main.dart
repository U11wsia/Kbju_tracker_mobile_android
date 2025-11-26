import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kbju_tracker/providers/settings_provider.dart';
import 'package:kbju_tracker/providers/tracker_provider.dart';
import 'package:kbju_tracker/data/storage.dart';
import 'package:kbju_tracker/ui/pages/home_page.dart';

void main() {
  final storage = StorageService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storage)..init()),
        ChangeNotifierProvider(create: (_) => TrackerProvider(storage)..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<SettingsProvider>().settings.themeMode,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true, brightness: Brightness.dark),
      home: const HomePage(),
    );
  }
}
