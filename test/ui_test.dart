import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moodpulseapp/data/demo_store.dart';
import 'package:moodpulseapp/data/models/daily_entry.dart';
import 'package:moodpulseapp/data/models/habit.dart';
import 'package:moodpulseapp/data/repositories/entry_repository.dart';
import 'package:moodpulseapp/data/repositories/habit_repository.dart';
import 'package:moodpulseapp/providers/entry_provider.dart';
import 'package:moodpulseapp/providers/habit_provider.dart';
import 'package:moodpulseapp/screens/detail/detail_screen.dart';
import 'package:moodpulseapp/screens/home/home_screen.dart';
import 'package:moodpulseapp/screens/history/history_screen.dart';
import 'package:moodpulseapp/screens/habits/manage_habits_screen.dart';
import 'package:moodpulseapp/screens/splash/splash_screen.dart';
import 'package:moodpulseapp/widgets/entry_card.dart';
import 'package:moodpulseapp/widgets/habit_chip.dart';
import 'package:moodpulseapp/widgets/mood_selector.dart';
import 'package:moodpulseapp/widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('splash menuju halaman utama setelah dua detik', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const SplashScreen(),
        routes: {'/main': (_) => const Scaffold(body: Text('Beranda'))},
      ),
    );
    expect(find.text('MoodPulse'), findsOneWidget);
    expect(find.text('Catat mood, bangun kebiasaan'), findsOneWidget);
    expect(find.text('Versi 1.0'), findsOneWidget);
    expect(find.bySemanticsLabel('Logo MoodPulse'), findsOneWidget);
    expect(find.bySemanticsLabel('Memuat aplikasi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('pemilihan mood memanggil callback dengan skor', (tester) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodSelector(
            value: null,
            onChanged: (score) => selected = score,
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.sentiment_satisfied));
    expect(selected, 4);
  });

  testWidgets('chip kebiasaan bisa dicentang', (tester) async {
    bool? changed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitChip(
            habit: const Habit(id: 1, title: 'Olahraga', createdAt: 0),
            checked: false,
            onChanged: (value) => changed = value,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Olahraga'));
    expect(changed, true);
  });

  testWidgets('Home menampilkan form dan statistik dummy', (tester) async {
    await initializeDateFormatting('id_ID');
    final store = DemoStore();
    final entries = EntryProvider(EntryRepository(store));
    final habits = HabitProvider(HabitRepository(store));
    await entries.refresh();
    await habits.refresh();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<EntryProvider>.value(value: entries),
          ChangeNotifierProvider<HabitProvider>.value(value: habits),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: HomeScreen(active: true, onNavigate: _noNavigation),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Bagaimana harimu?'), findsOneWidget);
    expect(find.text('Mood hari ini'), findsOneWidget);
    expect(find.text('Kebiasaan hari ini'), findsOneWidget);
    expect(find.text('Catatan singkat'), findsOneWidget);
    expect(find.text('0/280'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Rata-rata mood 7 hari'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Streak'), findsOneWidget);
  });

  testWidgets('kartu riwayat menampilkan tanggal, catatan, dan progres', (
    tester,
  ) async {
    await initializeDateFormatting('id_ID');
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntryCard(
            entry: const DailyEntry(
              dateKey: '2025-11-17',
              moodScore: 4,
              noteText: 'Hari ini produktif',
              updatedAt: 0,
            ),
            completedHabits: 3,
            totalHabits: 5,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('Senin, 17 Nov 2025'), findsOneWidget);
    expect(find.text('Hari ini produktif'), findsOneWidget);
    expect(find.text('3 dari 5 kebiasaan selesai'), findsOneWidget);
    await tester.tap(find.text('Hari ini produktif'));
    expect(tapped, true);
  });

  testWidgets('Riwayat menampilkan data dummy dan menuju Detail', (
    tester,
  ) async {
    await initializeDateFormatting('id_ID');
    final store = DemoStore(today: DateTime(2025, 11, 18));
    final entries = EntryProvider(EntryRepository(store));
    final habits = HabitProvider(HabitRepository(store));
    await entries.refresh();
    await habits.refresh();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<EntryProvider>.value(value: entries),
          ChangeNotifierProvider<HabitProvider>.value(value: habits),
        ],
        child: MaterialApp(
          home: Scaffold(body: HistoryScreen(onHome: () {})),
          routes: {
            '/detail': (_) => const Scaffold(body: Text('Halaman Detail')),
          },
        ),
      ),
    );
    expect(find.text('5 catatan tersimpan'), findsOneWidget);
    expect(find.text('3 dari 5 kebiasaan selesai'), findsOneWidget);
    await tester.tap(find.text('Senin, 17 Nov 2025'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman Detail'), findsOneWidget);
  });

  testWidgets('Riwayat kosong kembali ke Home melalui tombol', (tester) async {
    final store = DemoStore();
    store.entries.clear();
    store.completedHabits.clear();
    final entries = EntryProvider(EntryRepository(store));
    final habits = HabitProvider(HabitRepository(store));
    await entries.refresh();
    await habits.refresh();
    var navigatedHome = false;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<EntryProvider>.value(value: entries),
          ChangeNotifierProvider<HabitProvider>.value(value: habits),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: HistoryScreen(onHome: () => navigatedHome = true),
          ),
        ),
      ),
    );
    expect(find.text('0 catatan tersimpan'), findsOneWidget);
    expect(find.text('Belum ada catatan'), findsOneWidget);
    await tester.tap(find.text('Catat Hari Ini'));
    expect(navigatedHome, true);
  });

  testWidgets('Detail menampilkan mood, semua kebiasaan, dan waktu catatan', (
    tester,
  ) async {
    await initializeDateFormatting('id_ID');
    final store = DemoStore(today: DateTime(2025, 11, 18));
    const key = '2025-11-17';
    final original = store.entries[key]!;
    store.entries[key] = DailyEntry(
      dateKey: key,
      moodScore: original.moodScore,
      noteText: original.noteText,
      updatedAt: DateTime(2025, 11, 17, 21, 15).millisecondsSinceEpoch,
    );
    final entries = EntryProvider(EntryRepository(store));
    final habits = HabitProvider(HabitRepository(store));
    await entries.refresh();
    await habits.refresh();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<EntryProvider>.value(value: entries),
          ChangeNotifierProvider<HabitProvider>.value(value: habits),
        ],
        child: const MaterialApp(home: DetailScreen(dateKey: key)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Senin, 17 November 2025'), findsOneWidget);
    expect(find.text('Baik'), findsOneWidget);
    expect(find.text('Skor 4 dari 5'), findsOneWidget);
    expect(find.text('3 dari 5 selesai'), findsOneWidget);
    expect(find.text('Olahraga'), findsOneWidget);
    expect(find.text('Tidur 7 Jam'), findsOneWidget);
    expect(find.text('Selesai'), findsNWidgets(3));
    expect(find.text('Terlewat'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('Diperbarui 17 Nov 2025, 21.15'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(original.noteText!), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Hapus'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus catatan ini?'), findsOneWidget);
    expect(
      find.text('Catatan tanggal 17 November 2025 akan dihapus permanen.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(entries.entries.length, 5);
  });

  testWidgets('dialog bersama membatalkan atau mengonfirmasi hapus kebiasaan', (
    tester,
  ) async {
    bool? confirmed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => confirmed = await confirmDelete(
                context,
                'kebiasaan "Olahraga"',
                description: 'Kebiasaan "Olahraga" akan dihapus permanen.',
              ),
              child: const Text('Buka dialog'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Buka dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus kebiasaan "Olahraga"?'), findsOneWidget);
    expect(
      find.text('Kebiasaan "Olahraga" akan dihapus permanen.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(confirmed, false);
    await tester.tap(find.text('Buka dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(confirmed, true);
  });

  testWidgets('Kelola Kebiasaan menambah dan mengubah nama melalui dialog', (tester) async {
    final store = DemoStore();
    final entries = EntryProvider(EntryRepository(store));
    final habits = HabitProvider(HabitRepository(store));
    await entries.refresh();
    await habits.refresh();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<EntryProvider>.value(value: entries),
        ChangeNotifierProvider<HabitProvider>.value(value: habits),
      ],
      child: const MaterialApp(home: Scaffold(body: ManageHabitsScreen())),
    ));
    expect(find.text('5 kebiasaan aktif terdaftar'), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    await tester.tap(find.byTooltip('Tambah Kebiasaan Baru'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Kebiasaan'), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Nama kebiasaan wajib diisi'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Jalan pagi');
    await tester.pump();
    expect(find.text('10/40'), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('6 kebiasaan aktif terdaftar'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Jalan pagi'), 200,
      scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.byTooltip('Ubah Jalan pagi'));
    await tester.tap(find.byTooltip('Ubah Jalan pagi'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Kebiasaan'), findsOneWidget);
    expect(find.text('10/40'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Jalan sore');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Jalan sore'), findsOneWidget);
    expect(find.text('6 kebiasaan aktif terdaftar'), findsOneWidget);
  });

  testWidgets('Kelola Kebiasaan menampilkan konfirmasi hapus tanpa menghapus saat Batal', (tester) async {
    final store = DemoStore();
    final entries = EntryProvider(EntryRepository(store));
    final habits = HabitProvider(HabitRepository(store));
    await entries.refresh();
    await habits.refresh();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<EntryProvider>.value(value: entries),
        ChangeNotifierProvider<HabitProvider>.value(value: habits),
      ],
      child: const MaterialApp(home: Scaffold(body: ManageHabitsScreen())),
    ));
    await tester.tap(find.byTooltip('Hapus Olahraga'));
    await tester.pumpAndSettle();
    expect(find.text('Kebiasaan "Olahraga" akan dihapus dari daftar dan dari semua catatan lama.'),
      findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Olahraga'), findsOneWidget);
    expect(habits.habits.length, 5);
  });

  testWidgets('Kebiasaan kosong membuka dialog berisi inspirasi', (tester) async {
    final store = DemoStore();
    store.habits.clear();
    final entries = EntryProvider(EntryRepository(store));
    final habits = HabitProvider(HabitRepository(store));
    await entries.refresh();
    await habits.refresh();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<EntryProvider>.value(value: entries),
        ChangeNotifierProvider<HabitProvider>.value(value: habits),
      ],
      child: const MaterialApp(home: Scaffold(body: ManageHabitsScreen())),
    ));
    expect(find.text('0 kebiasaan aktif'), findsOneWidget);
    expect(find.text('Belum ada kebiasaan'), findsOneWidget);
    expect(find.text('Mulai dengan yang mudah'), findsOneWidget);
    await tester.tap(find.text('Minum air'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Kebiasaan'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Minum air 1 gelas'), findsOneWidget);
    expect(find.text('17/40'), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('1 kebiasaan aktif terdaftar'), findsOneWidget);
  });
}

void _noNavigation(int _) {}
