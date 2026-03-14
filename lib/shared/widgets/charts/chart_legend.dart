import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ChartLegendItem {
  final Color color;
  final String label;
  final String? value;

  const ChartLegendItem({
    required this.color,
    required this.label,
    this.value,
  });
}

class ChartLegend extends StatelessWidget {
  final List<ChartLegendItem> items;
  final bool wrap;

  const ChartLegend({required this.items, this.wrap = true, super.key});

  @override
  Widget build(BuildContext context) {
    final children = items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(item.label, style: AppTextStyles.bodySm),
                if (item.value != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    item.value!,
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ],
            ),
          ),
        )
        .toList();

    if (wrap) {
      return Wrap(children: children);
    }
    return Row(children: children);
  }
}
