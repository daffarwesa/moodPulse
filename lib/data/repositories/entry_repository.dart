import '../demo_store.dart';
import '../models/daily_entry.dart';
import '../models/entry_detail.dart';

class EntryRepository {
  const EntryRepository(this.store);
  final DemoStore store;

  Future<List<DailyEntry>> all() async {
    final entries = store.entries.values.toList();
    entries.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return entries;
  }

  Future<Map<String, int>> completedCounts() async {
    final validIds = store.habits.map((habit) => habit.id).toSet();
    return {
      for (final key in store.entries.keys)
        key: (store.completedHabits[key] ?? {}).intersection(validIds).length,
    };
  }

  Future<EntryDetail?> detail(String dateKey) async {
    final entry = store.entries[dateKey];
    if (entry == null) return null;
    final checked = store.completedHabits[dateKey] ?? {};
    return EntryDetail(
      entry: entry,
      completedHabits: store.habits
          .where((habit) => checked.contains(habit.id))
          .toList(),
    );
  }

  Future<void> save(DailyEntry entry, Set<int> habitIds) async {
    store.entries[entry.dateKey] = entry;
    final validIds = store.habits.map((habit) => habit.id).toSet();
    store.completedHabits[entry.dateKey] = habitIds.intersection(validIds);
  }

  Future<void> delete(String dateKey) async {
    store.entries.remove(dateKey);
    store.completedHabits.remove(dateKey);
  }
}
