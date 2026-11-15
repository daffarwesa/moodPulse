import 'package:flutter_test/flutter_test.dart';
import 'package:moodpulseapp/core/utils/date_helper.dart';
import 'package:moodpulseapp/data/demo_store.dart';
import 'package:moodpulseapp/data/models/daily_entry.dart';
import 'package:moodpulseapp/data/repositories/entry_repository.dart';
import 'package:moodpulseapp/data/repositories/habit_repository.dart';
import 'package:moodpulseapp/providers/entry_provider.dart';

void main() {
  late DemoStore store;
  late EntryRepository entries;
  late HabitRepository habits;

  setUp(() {
    store = DemoStore(today: DateTime(2025, 11, 18));
    entries = EntryRepository(store);
    habits = HabitRepository(store);
  });

  test('data contoh ada di riwayat, hari ini siap diisi', () async {
    expect((await entries.all()).length, 5);
    expect((await habits.all()).length, 5);
    expect(await entries.detail('2025-11-18'), isNull);
    expect((await entries.all()).first.dateKey, '2025-11-17');
  });

  test('edit mengganti checklist tanpa membuat entri duplikat', () async {
    const key = '2025-11-18';
    await entries.save(
      const DailyEntry(dateKey: key, moodScore: 4, updatedAt: 1),
      {1},
    );
    await entries.save(
      const DailyEntry(
        dateKey: key,
        moodScore: 5,
        noteText: 'Lebih baik',
        updatedAt: 2,
      ),
      {3},
    );
    expect((await entries.all()).where((e) => e.dateKey == key).length, 1);
    final detail = (await entries.detail(key))!;
    expect(detail.entry.moodScore, 5);
    expect(detail.completedHabits.map((h) => h.title), ['Baca Buku']);
  });

  test('hapus kebiasaan membersihkan centang, tanpa menghapus entri', () async {
    await entries.save(
      const DailyEntry(dateKey: '2025-11-18', moodScore: 4, updatedAt: 1),
      {1},
    );
    await habits.delete(1);
    expect((await entries.detail('2025-11-18'))!.completedHabits, isEmpty);
    expect((await entries.all()).length, 6);
    await entries.delete('2025-11-18');
    expect(await entries.detail('2025-11-18'), isNull);
  });

  test(
    'penambahan dan edit kebiasaan tetap terlihat di sesi yang sama',
    () async {
      await habits.add('Napas hening');
      final added = (await habits.all()).last;
      await habits.update(added.id, 'Jalan sore');
      expect((await habits.all()).last.title, 'Jalan sore');
      expect(DemoStore(today: DateTime(2025, 11, 18)).habits.length, 5);
    },
  );

  test('validasi skor dan catatan; riwayat terbaru dulu', () async {
    final provider = EntryProvider(entries);
    await provider.save('2025-11-18', 3, 'Catatan', {});
    expect(provider.entries.first.dateKey, '2025-11-18');
    await expectLater(
      provider.save('2025-11-19', 0, '', {}),
      throwsArgumentError,
    );
    await expectLater(
      provider.save('2025-11-19', 5, 'x' * 281, {}),
      throwsArgumentError,
    );
    expect((await entries.all()).length, 6);
  });

  test('dateKey memakai format stabil', () {
    expect(DateHelper.key(DateTime(2025, 1, 9)), '2025-01-09');
  });
}
