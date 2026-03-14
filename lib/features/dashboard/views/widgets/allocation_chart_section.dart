import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/charts/portfolio_pie_chart.dart';
import '../../models/portfolio_summary.dart';

class AllocationChartSection extends StatelessWidget {
  final PortfolioSummary summary;

  const AllocationChartSection({required this.summary, super.key});

  @override
  Widget build(BuildContext context) {
    final items = summary.allocations;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 400;
          return isWide
              ? Row(
                  children: [
                    PortfolioPieChart(
                      data: _chartData(items),
                      size: 160,
                      centerLabel: 'Portfolio',
                      centerValue: CurrencyFormatter.compact(summary.totalValue),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: _LegendList(items: items)),
                  ],
                )
              : Column(
                  children: [
                    PortfolioPieChart(
                      data: _chartData(items),
                      size: 160,
                      centerLabel: 'Portfolio',
                      centerValue: CurrencyFormatter.compact(summary.totalValue),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LegendList(items: items),
                  ],
                );
        },
      ),
    );
  }

  List<PortfolioPieChartData> _chartData(List<AllocationItem> items) {
    return items.asMap().entries.map((e) {
      return PortfolioPieChartData(
        label: e.value.label,
        percentage: e.value.percentage,
        color: AppColors.chartPalette[e.key % AppColors.chartPalette.length],
      );
    }).toList();
  }
}

class _LegendList extends StatelessWidget {
  final List<AllocationItem> items;

  const _LegendList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((e) {
        final color =
            AppColors.chartPalette[e.key % AppColors.chartPalette.length];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.value.label,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                '${e.value.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
