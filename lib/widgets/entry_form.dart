import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/date_helper.dart';
import '../data/models/entry_detail.dart';
import '../providers/entry_provider.dart';
import '../providers/habit_provider.dart';
import 'habit_chip.dart';
import 'mood_selector.dart';
import 'section_card.dart';

class EntryForm extends StatefulWidget {
  const EntryForm({
    super.key,
    required this.dateKey,
    this.initial,
    this.onSaved,
    this.onManage,
    this.showHeader = true,
  });
  final String dateKey;
  final EntryDetail? initial;
  final VoidCallback? onSaved;
  final VoidCallback? onManage;
  final bool showHeader;

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  late final TextEditingController note = TextEditingController(
    text: widget.initial?.entry.noteText ?? '',
  );
  late int? mood = widget.initial?.entry.moodScore;
  late Set<int> selected =
      widget.initial?.completedHabits.map((h) => h.id).toSet() ?? {};
  bool saving = false;

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) ...[
          Text(
            DateHelper.full(widget.dateKey),
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 16),
        ],
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mood hari ini', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              MoodSelector(
                value: mood,
                onChanged: (value) => setState(() => mood = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kebiasaan hari ini',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  if (widget.onManage != null)
                    TextButton(
                      onPressed: widget.onManage,
                      child: Text(
                        'Kelola',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (habits.isEmpty)
                Text(
                  'Belum ada kebiasaan. Tambahkan dari tab Kebiasaan.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final habit in habits)
                    HabitChip(
                      habit: habit,
                      checked: selected.contains(habit.id),
                      onChanged: (checked) => setState(() {
                        if (checked) {
                          selected.add(habit.id);
                        } else {
                          selected.remove(habit.id);
                        }
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catatan singkat', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              TextField(
                controller: note,
                minLines: 3,
                maxLines: 5,
                maxLength: 280,
                inputFormatters: [LengthLimitingTextInputFormatter(280)],
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Tulis sesuatu tentang hari ini...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.outline,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceLow,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: note,
                  builder: (context, value, _) => Text(
                    '${value.text.characters.length}/280',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: saving
                ? null
                : () async {
                    if (mood == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pilih mood terlebih dahulu'),
                        ),
                      );
                      return;
                    }
                    setState(() => saving = true);
                    try {
                      await context.read<EntryProvider>().save(
                        widget.dateKey,
                        mood!,
                        note.text,
                        selected.intersection(habits.map((h) => h.id).toSet()),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catatan tersimpan')),
                      );
                      widget.onSaved?.call();
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal menyimpan catatan'),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => saving = false);
                    }
                  },
            icon: const Icon(Icons.save_outlined, size: 20),
            label: Text(
              saving ? 'Menyimpan...' : 'Simpan',
              style: AppTextStyles.labelLarge,
            ),
          ),
        ),
      ],
    );
  }
}
