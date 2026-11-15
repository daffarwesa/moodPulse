import 'package:flutter/foundation.dart';

import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  HabitProvider(this.repository);
  final HabitRepository repository;
  List<Habit> habits = [];
  bool loading = true;

  Future<void> refresh() async {
    habits = await repository.all();
    loading = false;
    notifyListeners();
  }

  Future<void> add(String title) async {
    if (title.trim().isEmpty) throw ArgumentError('Nama kebiasaan wajib diisi');
    await repository.add(title);
    await refresh();
  }

  Future<void> update(int id, String title) async {
    if (title.trim().isEmpty) throw ArgumentError('Nama kebiasaan wajib diisi');
    await repository.update(id, title);
    await refresh();
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    await refresh();
  }
}
