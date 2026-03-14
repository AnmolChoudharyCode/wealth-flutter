import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PortfolioPieChartData {
  final String label;
  final double percentage;
  final Color? color;

  const PortfolioPieChartData({
    required this.label,
    required this.percentage,
    this.color,
  });
}

class PortfolioPieChart extends StatefulWidget {
  final List<PortfolioPieChartData> data;
  final double size;
  final String? centerLabel;
  final String? centerValue;

  const PortfolioPieChart({
    required this.data,
    this.size = 180,
    this.centerLabel,
    this.centerValue,
    super.key,
  });

  @override
  State<PortfolioPieChart> createState() => _PortfolioPieChartState();
}

class _PortfolioPieChartState extends State<PortfolioPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    setState(() => _touchedIndex = -1);
                    return;
                  }
                  setState(() {
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: _buildSections(),
              centerSpaceRadius: widget.size * 0.28,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
          ),
          if (widget.centerLabel != null || widget.centerValue != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.centerValue != null)
                    Text(
                      widget.centerValue!,
                      style: AppTextStyles.headingSm,
                    ),
                  if (widget.centerLabel != null)
                    Text(
                      widget.centerLabel!,
                      style: AppTextStyles.bodySm,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == _touchedIndex;
      final color = item.color ?? AppColors.chartPalette[index % AppColors.chartPalette.length];

      return PieChartSectionData(
        value: item.percentage,
        color: color,
        radius: isTouched ? widget.size * 0.32 : widget.size * 0.28,
        title: isTouched ? '${item.percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();
  }
}
