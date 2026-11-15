import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/demo_store.dart';
import 'data/repositories/entry_repository.dart';
import 'data/repositories/habit_repository.dart';
import 'providers/entry_provider.dart';
import 'providers/habit_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final store = DemoStore();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EntryProvider(EntryRepository(store))..refresh(),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(HabitRepository(store))..refresh(),
        ),
      ],
      child: const MoodPulseApp(),
    ),
  );
}
