import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/entry_provider.dart';
import 'section_card.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<EntryProvider>();
    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rata-rata mood 7 hari',
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  entries.weekAverage?.toStringAsFixed(1) ?? '-',
                  style: AppTextStyles.headlineSmall,
                ),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.surfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Streak', style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(
                  '${entries.streak} hari',
                  style: AppTextStyles.headlineSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
