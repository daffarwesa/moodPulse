import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/habit.dart';

class HabitChip extends StatelessWidget {
  const HabitChip({
    super.key,
    required this.habit,
    required this.checked,
    required this.onChanged,
  });

  final Habit habit;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: checked,
    child: Material(
      color: checked ? AppColors.primary : AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (checked) ...[
                  const Icon(Icons.check, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  habit.title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: checked ? Colors.white : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
