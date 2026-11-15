import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/habit.dart';
import '../../providers/entry_provider.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/confirm_dialog.dart';
import 'habit_form_dialog.dart';
import 'habit_icon.dart';
import 'habits_empty_state.dart';

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  Future<void> edit(
    BuildContext context, {
    Habit? habit,
    String? suggestion,
  }) async {
    final title = await showHabitForm(
      context,
      initialTitle: habit?.title ?? suggestion,
      editing: habit != null,
    );
    if (title == null || !context.mounted) return;
    try {
      final provider = context.read<HabitProvider>();
      if (habit == null) {
        await provider.add(title);
      } else {
        await provider.update(habit.id, title);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan kebiasaan')),
        );
      }
    }
  }

  Future<void> delete(BuildContext context, Habit habit) async {
    if (!await confirmDelete(
      context,
      'kebiasaan "${habit.title}"',
      description:
          'Kebiasaan "${habit.title}" akan dihapus dari daftar dan dari semua catatan lama.',
    )) {
      return;
    }
    if (!context.mounted) return;
    try {
      await context.read<HabitProvider>().delete(habit.id);
      if (context.mounted) await context.read<EntryProvider>().refresh();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus kebiasaan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final count = provider.habits.length;
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kelola Kebiasaan',
                            style: AppTextStyles.headlineLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count == 0
                          ? '0 kebiasaan aktif'
                          : '$count kebiasaan aktif terdaftar',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : count == 0
                    ? HabitsEmptyState(
                        onSuggestion: (title) =>
                            edit(context, suggestion: title),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: count,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final habit = provider.habits[index];
                          return _HabitTile(
                            habit: habit,
                            onEdit: () => edit(context, habit: habit),
                            onDelete: () => delete(context, habit),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (!provider.loading)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                heroTag: 'add-habit',
                onPressed: () => edit(context),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                tooltip: 'Tambah Kebiasaan Baru',
                child: const Icon(Icons.add, size: 28),
              ),
            ),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryLight,
          child: Icon(
            habitIcon(habit.title),
            size: 22,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            habit.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineSmall,
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: AppColors.outline,
          tooltip: 'Ubah ${habit.title}',
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          padding: EdgeInsets.zero,
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 20),
          color: AppColors.error,
          tooltip: 'Hapus ${habit.title}',
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          padding: EdgeInsets.zero,
        ),
      ],
    ),
  );
}
