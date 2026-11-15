import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/entry_provider.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/entry_card.dart';
import 'history_empty_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.onHome});
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final totalHabits = context.watch<HabitProvider>().habits.length;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Riwayat', style: AppTextStyles.headlineLarge),
                Text(
                  '${provider.entries.length} catatan tersimpan',
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
                : provider.entries.isEmpty
                ? HistoryEmptyState(onAdd: onHome)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: provider.entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = provider.entries[index];
                      return EntryCard(
                        entry: entry,
                        completedHabits:
                            provider.habitCounts[entry.dateKey] ?? 0,
                        totalHabits: totalHabits,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.detail,
                          arguments: entry.dateKey,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
