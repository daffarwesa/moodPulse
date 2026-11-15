import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/mood_data.dart';
import '../core/theme/app_text_styles.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({super.key, required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: MoodData.levels.map((mood) {
      final selected = value == mood.score;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: mood.label,
          child: InkWell(
            onTap: () => onChanged(mood.score),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: selected ? 52 : 48,
                        height: selected ? 52 : 48,
                        decoration: BoxDecoration(
                          color: mood.background,
                          shape: BoxShape.circle,
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          mood.icon,
                          size: selected ? 30 : 28,
                          color: mood.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mood.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: selected ? AppColors.text : AppColors.outline,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}
