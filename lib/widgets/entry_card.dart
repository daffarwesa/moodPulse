import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/mood_data.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/date_helper.dart';
import '../data/models/daily_entry.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.entry,
    required this.completedHabits,
    required this.totalHabits,
    required this.onTap,
  });

  final DailyEntry entry;
  final int completedHabits;
  final int totalHabits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = MoodData.byScore(entry.moodScore);
    final hasNote = entry.noteText?.trim().isNotEmpty == true;
    return Material(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: mood.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(mood.icon, size: 28, color: mood.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateHelper.dayShort(entry.dateKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      hasNote ? entry.noteText!.trim() : 'Tanpa catatan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: hasNote ? AppColors.outline : AppColors.muted,
                        fontStyle: hasNote
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completedHabits dari $totalHabits kebiasaan selesai',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
