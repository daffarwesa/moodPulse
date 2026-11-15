import 'package:flutter/foundation.dart';

import '../core/utils/date_helper.dart';
import '../data/models/daily_entry.dart';
import '../data/models/entry_detail.dart';
import '../data/repositories/entry_repository.dart';

class EntryProvider extends ChangeNotifier {
  EntryProvider(this.repository);
  final EntryRepository repository;
  List<DailyEntry> entries = [];
  Map<String, int> habitCounts = {};
  bool loading = true;

  Future<void> refresh() async {
    entries = await repository.all();
    habitCounts = await repository.completedCounts();
    loading = false;
    notifyListeners();
  }

  Future<EntryDetail?> detail(String key) => repository.detail(key);

  Future<void> save(
    String key,
    int mood,
    String note,
    Set<int> habitIds,
  ) async {
    if (mood < 1 || mood > 5) throw ArgumentError('Pilih mood terlebih dahulu');
    if (note.runes.length > 280) {
      throw ArgumentError('Catatan maksimal 280 karakter');
    }
    await repository.save(
      DailyEntry(
        dateKey: key,
        moodScore: mood,
        noteText: note.trim().isEmpty ? null : note.trim(),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
      habitIds,
    );
    await refresh();
  }

  Future<void> delete(String key) async {
    await repository.delete(key);
    await refresh();
  }

  double? get weekAverage {
    final start = DateHelper.key(
      DateTime.now().subtract(const Duration(days: 6)),
    );
    final recent = entries
        .where(
          (e) =>
              e.dateKey.compareTo(start) >= 0 &&
              e.dateKey.compareTo(DateHelper.key(DateTime.now())) <= 0,
        )
        .toList();
    if (recent.isEmpty) return null;
    return recent.fold<int>(0, (sum, e) => sum + e.moodScore) / recent.length;
  }

  int get streak {
    final keys = entries.map((e) => e.dateKey).toSet();
    var day = DateTime.now();
    if (!keys.contains(DateHelper.key(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (keys.contains(DateHelper.key(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }
}
