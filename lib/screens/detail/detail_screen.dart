import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/mood_data.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/entry_detail.dart';
import '../../data/models/habit.dart';
import '../../providers/entry_provider.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/section_card.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.dateKey});
  final String dateKey;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<EntryDetail?> detail = context.read<EntryProvider>().detail(
    widget.dateKey,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detail Catatan', style: AppTextStyles.headlineSmall),
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    body: FutureBuilder<EntryDetail?>(
      future: detail,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat catatan'));
        }
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('Catatan tidak ditemukan'));
        }
        final habits = context.watch<HabitProvider>().habits;
        final completed = data.completedHabits.map((habit) => habit.id).toSet();
        final mood = MoodData.byScore(data.entry.moodScore);
        final note = data.entry.noteText?.trim();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SectionCard(
              padding: const EdgeInsets.all(20),
              shadow: true,
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              DateHelper.full(widget.dateKey),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: mood.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(mood.icon, size: 44, color: mood.color),
                  ),
                  const SizedBox(height: 12),
                  Text(mood.label, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Skor ${mood.score} dari 5',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              padding: const EdgeInsets.all(20),
              shadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Kebiasaan',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                      Text(
                        '${completed.length} dari ${habits.length} selesai',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (habits.isEmpty)
                    Text(
                      'Belum ada kebiasaan.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  for (final habit in habits)
                    _HabitStatusRow(
                      habit: habit,
                      completed: completed.contains(habit.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              padding: const EdgeInsets.all(20),
              shadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catatan', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Text(
                    note?.isNotEmpty == true ? note! : 'Tanpa catatan',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontStyle: note?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic,
                      color: note?.isNotEmpty == true
                          ? AppColors.text
                          : AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Diperbarui ${DateHelper.dateTime(data.entry.updatedAt)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.edit,
                        arguments: widget.dateKey,
                      );
                      if (mounted) {
                        setState(
                          () => detail = context.read<EntryProvider>().detail(
                            widget.dateKey,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: const Text('Edit', style: AppTextStyles.labelLarge),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (!await confirmDelete(
                        context,
                        'catatan ini',
                        description:
                        'Catatan tanggal ${DateHelper.dateLong(widget.dateKey)} akan dihapus permanen.',
                      )) {
                        return;
                      }
                      if (!context.mounted) return;
                      try {
                        await context.read<EntryProvider>().delete(
                          widget.dateKey,
                        );
                        if (context.mounted) Navigator.pop(context);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menghapus catatan'),
                            ),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.errorContainer,
                      foregroundColor: AppColors.error,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Hapus', style: AppTextStyles.labelLarge),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

class _HabitStatusRow extends StatelessWidget {
  const _HabitStatusRow({required this.habit, required this.completed});

  final Habit habit;
  final bool completed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: completed ? AppColors.surfaceLow : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: completed ? AppColors.primary : AppColors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : const Center(
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: AppColors.outlineVariant,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: completed ? AppColors.text : AppColors.outline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            completed ? 'Selesai' : 'Terlewat',
            style: AppTextStyles.labelSmall.copyWith(
              color: completed ? AppColors.primary : AppColors.outline,
            ),
          ),
        ],
      ),
    ),
  );
}
