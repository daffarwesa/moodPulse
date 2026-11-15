class DailyEntry {
  const DailyEntry({
    required this.dateKey,
    required this.moodScore,
    this.noteText,
    required this.updatedAt,
  });

  final String dateKey;
  final int moodScore;
  final String? noteText;
  final int updatedAt;
}
