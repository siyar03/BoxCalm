import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'providers/presets_provider.dart';
import 'providers/reminders_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();

  final settings = await SettingsProvider.load();
  final notificationService = NotificationService();
  await notificationService.init();

  final audio = AudioService(settings);
  await audio.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: settings),
        Provider.value(value: audio),
        Provider.value(value: notificationService),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) => PresetsProvider(storage: storage, settings: settings),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsProvider(storage: storage),
        ),
        ChangeNotifierProvider(
          create: (_) => RemindersProvider(
            storage: storage,
            notifications: notificationService,
          ),
        ),
      ],
      child: const BoxCalmApp(),
    ),
  );
}

class BoxCalmApp extends StatelessWidget {
  const BoxCalmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final palette = AppPalette.byId(settings.paletteId);
    return MaterialApp(
      title: 'BoxCalm',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.build(palette, Brightness.light),
      darkTheme: AppTheme.build(palette, Brightness.dark),
      home: const SplashScreen(),
    );
  }
}
