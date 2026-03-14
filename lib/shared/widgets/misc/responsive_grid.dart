import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double itemMinWidth;
  final double spacing;

  const ResponsiveGrid({
    required this.children,
    this.itemMinWidth = 160.0,
    this.spacing = AppSpacing.md,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colCount =
            (constraints.maxWidth / itemMinWidth).floor().clamp(1, 4);
        final itemWidth =
            (constraints.maxWidth - spacing * (colCount - 1)) / colCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
