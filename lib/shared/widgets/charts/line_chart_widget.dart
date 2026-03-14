import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LineChartPoint {
  final double x;
  final double y;

  const LineChartPoint(this.x, this.y);
}

class LineChartWidget extends StatelessWidget {
  final List<LineChartPoint> data;
  final double height;
  final Color? lineColor;
  final bool showDots;
  final bool showGrid;
  final String Function(double)? bottomLabelBuilder;
  final String Function(double)? leftLabelBuilder;

  const LineChartWidget({
    required this.data,
    this.height = 200,
    this.lineColor,
    this.showDots = false,
    this.showGrid = true,
    this.bottomLabelBuilder,
    this.leftLabelBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);

    final color = lineColor ?? AppColors.darkPurple;
    final spots = data.map((p) => FlSpot(p.x, p.y)).toList();
    final minY = data.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final maxY = data.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.dark.withAlpha(220),
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      leftLabelBuilder?.call(s.y) ?? s.y.toStringAsFixed(2),
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          gridData: FlGridData(
            show: showGrid,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.borderLight.withAlpha(100),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: bottomLabelBuilder != null,
                getTitlesWidget: (value, meta) => Text(
                  bottomLabelBuilder?.call(value) ?? '',
                  style: AppTextStyles.bodySm,
                ),
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: leftLabelBuilder != null,
                getTitlesWidget: (value, meta) => Text(
                  leftLabelBuilder?.call(value) ?? '',
                  style: AppTextStyles.bodySm,
                ),
                reservedSize: 48,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: showDots),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withAlpha(60),
                    color.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
