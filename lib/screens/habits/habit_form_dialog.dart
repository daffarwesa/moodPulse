import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

Future<String?> showHabitForm(
  BuildContext context, {
  String? initialTitle,
  bool editing = false,
}) => showDialog<String>(
  context: context,
  builder: (_) => HabitFormDialog(initialTitle: initialTitle, editing: editing),
);

class HabitFormDialog extends StatefulWidget {
  const HabitFormDialog({super.key, this.initialTitle, this.editing = false});

  final String? initialTitle;
  final bool editing;

  @override
  State<HabitFormDialog> createState() => _HabitFormDialogState();
}

class _HabitFormDialogState extends State<HabitFormDialog> {
  late final TextEditingController controller = TextEditingController(
    text: widget.initialTitle ?? '',
  )..addListener(_onChanged);
  bool showError = false;

  void _onChanged() {
    if (mounted) setState(() => showError = false);
  }

  void save() {
    final title = controller.text.trim();
    if (title.isEmpty) {
      setState(() => showError = true);
      return;
    }
    Navigator.pop(context, title);
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    scrollable: true,
    contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
    actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 312),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.editing ? 'Edit Kebiasaan' : 'Tambah Kebiasaan',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Langkah kecil yang konsisten untuk jiwamu.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceLow,
                child: Icon(
                  widget.editing ? Icons.edit_outlined : Icons.add_task,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Nama kebiasaan', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLength: 40,
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => save(),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Contoh: Jalan kaki 30 menit',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.outline,
              ),
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.psychology_outlined,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Pilih yang mudah dijaga',
                  style: AppTextStyles.labelSmall,
                ),
              ),
              Text(
                '${controller.text.characters.length}/40',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
          if (showError) ...[
            const SizedBox(height: 8),
            Text(
              'Nama kebiasaan wajib diisi',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Batal',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.outline),
        ),
      ),
      FilledButton.icon(
        onPressed: save,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('Simpan', style: AppTextStyles.labelLarge),
      ),
    ],
  );
}
