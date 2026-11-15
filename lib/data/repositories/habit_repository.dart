import '../demo_store.dart';
import '../models/habit.dart';

class HabitRepository {
  const HabitRepository(this.store);
  final DemoStore store;

  Future<List<Habit>> all() async => List.of(store.habits);

  Future<void> add(String title) async {
    store.habits.add(
      Habit(
        id: store.nextHabitId++,
        title: title.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> update(int id, String title) async {
    final index = store.habits.indexWhere((habit) => habit.id == id);
    if (index < 0) return;
    final previous = store.habits[index];
    store.habits[index] = Habit(
      id: id,
      title: title.trim(),
      createdAt: previous.createdAt,
    );
  }

  Future<void> delete(int id) async {
    store.habits.removeWhere((habit) => habit.id == id);
    for (final completed in store.completedHabits.values) {
      completed.remove(id);
    }
  }
}
