import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

abstract final class PercentageFormatter {
  /// Format as "+2.45%" or "-1.23%"
  static String format(double value, {int decimals = 2}) {
    final abs = value.abs().toStringAsFixed(decimals);
    return value >= 0 ? '+$abs%' : '-$abs%';
  }

  /// Returns the semantic color for a percentage change
  static Color color(double value) {
    if (value > 0) return AppColors.positive;
    if (value < 0) return AppColors.negative;
    return AppColors.neutral;
  }
}
