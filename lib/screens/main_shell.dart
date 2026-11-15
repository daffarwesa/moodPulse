import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'history/history_screen.dart';
import 'habits/manage_habits_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int tab = widget.initialTab;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: tab,
      children: [
        HomeScreen(
          active: tab == 0,
          onNavigate: (index) => setState(() => tab = index),
        ),
        HistoryScreen(onHome: () => setState(() => tab = 0)),
        const ManageHabitsScreen(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (index) => setState(() => tab = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
        NavigationDestination(icon: Icon(Icons.task_alt), label: 'Kebiasaan'),
      ],
    ),
  );
}
