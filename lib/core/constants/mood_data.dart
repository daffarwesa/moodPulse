import 'package:flutter/material.dart';

import 'app_colors.dart';

class MoodLevel {
  const MoodLevel(
    this.score,
    this.label,
    this.icon,
    this.color,
    this.background,
  );

  final int score;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
}

abstract final class MoodData {
  static const levels = [
    MoodLevel(
      1,
      'Sangat Buruk',
      Icons.sentiment_very_dissatisfied,
      AppColors.error,
      Color(0x66FFDAD6),
    ),
    MoodLevel(
      2,
      'Buruk',
      Icons.sentiment_dissatisfied,
      AppColors.outline,
      AppColors.surfaceHigh,
    ),
    MoodLevel(
      3,
      'Biasa',
      Icons.sentiment_neutral,
      AppColors.onTertiaryContainer,
      Color(0x4DFFE17A),
    ),
    MoodLevel(
      4,
      'Baik',
      Icons.sentiment_satisfied,
      AppColors.secondary,
      Color(0x80A3F5B2),
    ),
    MoodLevel(
      5,
      'Sangat Baik',
      Icons.sentiment_very_satisfied,
      AppColors.onSecondaryContainer,
      Color(0x4DA0F2AF),
    ),
  ];

  static MoodLevel byScore(int score) => levels[score.clamp(1, 5) - 1];
}
