import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/percentage_formatter.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/misc/responsive_grid.dart';
import '../../models/portfolio_summary.dart';

class QuickStatsRow extends StatelessWidget {
  final PortfolioSummary summary;

  const QuickStatsRow({required this.summary, super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      itemMinWidth: 150,
      children: [
        StatCard(
          label: 'Total Return',
          value: CurrencyFormatter.compact(summary.totalGainLoss),
          changeText: PercentageFormatter.format(summary.totalGainLossPercent),
          isPositive: summary.isTotalPositive,
          icon: Icons.trending_up,
        ),
        StatCard(
          label: "Today's Change",
          value: CurrencyFormatter.pnl(summary.dailyChange),
          changeText: PercentageFormatter.format(summary.dailyChangePercent),
          isPositive: summary.isDailyPositive,
          icon: Icons.today_outlined,
        ),
        StatCard(
          label: 'Invested',
          value: CurrencyFormatter.compact(
            summary.totalValue - summary.totalGainLoss,
          ),
          icon: Icons.savings_outlined,
        ),
        StatCard(
          label: 'Assets',
          value: summary.allocations.length.toString(),
          icon: Icons.pie_chart_outline,
        ),
      ],
    );
  }
}
