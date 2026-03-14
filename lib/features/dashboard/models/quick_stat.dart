import 'package:flutter/material.dart';

class QuickStat {
  final String label;
  final String value;
  final String? changeText;
  final bool? isPositive;
  final IconData icon;

  const QuickStat({
    required this.label,
    required this.value,
    this.changeText,
    this.isPositive,
    required this.icon,
  });
}
