import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class HabitsEmptyState extends StatelessWidget {
  const HabitsEmptyState({super.key, required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
    children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.surface,
                        child: Icon(
                          Icons.checklist_rtl,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: -4,
                    right: -4,
                    child: Icon(
                      Icons.spa,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada kebiasaan',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                'Tekan tombol + untuk menambah kebiasaan pertamamu',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'INSPIRASI LANGKAH KECIL',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _Suggestion(
                  label: 'Minum air',
                  title: 'Minum air 1 gelas',
                  icon: Icons.water_drop_outlined,
                  onTap: onSuggestion,
                ),
                _Suggestion(
                  label: 'Jalan 10 menit',
                  title: 'Jalan kaki 10 menit',
                  icon: Icons.directions_walk,
                  onTap: onSuggestion,
                ),
                _Suggestion(
                  label: 'Napas hening',
                  title: 'Tarik napas hening',
                  icon: Icons.air,
                  onTap: onSuggestion,
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.eco, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mulai dengan yang mudah',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Kebiasaan kecil yang konsisten memberi ruang ketenangan bagi pikiranmu.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({
    required this.label,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String title;
  final IconData icon;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
    onPressed: () => onTap(title),
    avatar: Icon(icon, size: 16, color: AppColors.primary),
    label: Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    ),
    backgroundColor: AppColors.surfaceLow,
    side: BorderSide.none,
    shape: const StadiumBorder(),
  );
}
