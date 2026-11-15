import 'package:flutter/material.dart';

IconData habitIcon(String title) {
  final name = title.toLowerCase();
  if (name.contains('olahraga') || name.contains('latihan')) {
    return Icons.fitness_center;
  }
  if (name.contains('tidur')) return Icons.bedtime_outlined;
  if (name.contains('baca') || name.contains('membaca')) {
    return Icons.menu_book_outlined;
  }
  if (name.contains('minum') || name.contains('air')) {
    return Icons.water_drop_outlined;
  }
  if (name.contains('meditasi') || name.contains('napas')) {
    return Icons.self_improvement;
  }
  return Icons.task_alt;
}
