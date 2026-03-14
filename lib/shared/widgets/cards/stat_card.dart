import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? changeText;
  final bool? isPositive;
  final IconData? icon;
  final Color? iconColor;

  const StatCard({
    required this.label,
    required this.value,
    this.changeText,
    this.isPositive,
    this.icon,
    this.iconColor,
    super.key,
  });

  Color get _changeColor {
    if (isPositive == null) return AppColors.neutral;
    return isPositive! ? AppColors.positive : AppColors.negative;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14,
                    color: iconColor ?? AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.valueDisplay,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (changeText != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isPositive == true
                        ? Icons.arrow_upward
                        : isPositive == false
                            ? Icons.arrow_downward
                            : Icons.remove,
                    size: 12,
                    color: _changeColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    changeText!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _changeColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
