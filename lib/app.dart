import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/detail/edit_entry_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash/splash_screen.dart';

class MoodPulseApp extends StatelessWidget {
  const MoodPulseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MoodPulse',
    theme: AppTheme.light,
    debugShowCheckedModeBanner: false,
    initialRoute: AppRoutes.splash,
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case AppRoutes.splash:
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        case AppRoutes.main:
          return MaterialPageRoute(
            builder: (_) => MainShell(
              initialTab: settings.arguments is int
                  ? settings.arguments as int
                  : 0,
            ),
          );
        case AppRoutes.detail:
          final key = settings.arguments;
          if (key is String) {
            return MaterialPageRoute(
              builder: (_) => DetailScreen(dateKey: key),
            );
          }
        case AppRoutes.edit:
          final key = settings.arguments;
          if (key is String) {
            return MaterialPageRoute(
              builder: (_) => EditEntryScreen(dateKey: key),
            );
          }
      }
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    },
  );
}
