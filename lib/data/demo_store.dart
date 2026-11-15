import '../core/utils/date_helper.dart';
import 'models/daily_entry.dart';
import 'models/habit.dart';

/// Shared session-only data for the frontend prototype.
class DemoStore {
  DemoStore({DateTime? today}) {
    final now = today ?? DateTime.now();
    final createdAt = now.millisecondsSinceEpoch;
    habits.addAll([
      Habit(id: 1, title: 'Olahraga', createdAt: createdAt),
      Habit(id: 2, title: 'Tidur 7 Jam', createdAt: createdAt),
      Habit(id: 3, title: 'Baca Buku', createdAt: createdAt),
      Habit(id: 4, title: 'Minum 2L Air', createdAt: createdAt),
      Habit(id: 5, title: 'Meditasi', createdAt: createdAt),
    ]);

    final notes = [
      'Hari ini lumayan produktif, tadi sempat jogging.',
      'Akhir pekan yang menyenangkan kumpul bersama keluarga.',
      null,
      'Pekerjaan kantor menumpuk dan badan terasa lelah.',
      'Tidur cukup dan target membaca satu bab buku tercapai.',
    ];
    final moods = [4, 5, 3, 2, 4];
    final checked = [
      {1, 3, 4},
      {1, 2, 3, 4, 5},
      {2, 4},
      {4},
      {2, 3, 4, 5},
    ];
    for (var i = 0; i < notes.length; i++) {
      final day = DateTime(now.year, now.month, now.day - i - 1);
      final key = DateHelper.key(day);
      entries[key] = DailyEntry(
        dateKey: key,
        moodScore: moods[i],
        noteText: notes[i],
        updatedAt: day.millisecondsSinceEpoch,
      );
      completedHabits[key] = checked[i];
    }
  }

  final Map<String, DailyEntry> entries = {};
  final List<Habit> habits = [];
  final Map<String, Set<int>> completedHabits = {};
  int nextHabitId = 6;
}
