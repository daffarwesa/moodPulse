import 'daily_entry.dart';
import 'habit.dart';

class EntryDetail {
  const EntryDetail({required this.entry, required this.completedHabits});

  final DailyEntry entry;
  final List<Habit> completedHabits;
}
