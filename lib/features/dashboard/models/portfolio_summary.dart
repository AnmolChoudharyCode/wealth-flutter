import 'package:equatable/equatable.dart';

class PortfolioSummary extends Equatable {
  final double totalValue;
  final double dailyChange;
  final double dailyChangePercent;
  final double totalGainLoss;
  final double totalGainLossPercent;
  final List<AllocationItem> allocations;

  const PortfolioSummary({
    required this.totalValue,
    required this.dailyChange,
    required this.dailyChangePercent,
    required this.totalGainLoss,
    required this.totalGainLossPercent,
    required this.allocations,
  });

  bool get isDailyPositive => dailyChange >= 0;
  bool get isTotalPositive => totalGainLoss >= 0;

  @override
  List<Object?> get props => [
        totalValue,
        dailyChange,
        dailyChangePercent,
        totalGainLoss,
        totalGainLossPercent,
        allocations,
      ];
}

class AllocationItem extends Equatable {
  final String label;
  final double percentage;
  final double value;

  const AllocationItem({
    required this.label,
    required this.percentage,
    required this.value,
  });

  @override
  List<Object?> get props => [label, percentage, value];
}

/// Mock data for UI development
PortfolioSummary get mockPortfolioSummary => PortfolioSummary(
      totalValue: 284750.60,
      dailyChange: 1842.30,
      dailyChangePercent: 0.65,
      totalGainLoss: 34750.60,
      totalGainLossPercent: 13.9,
      allocations: const [
        AllocationItem(label: 'US Equities', percentage: 42.0, value: 119595.25),
        AllocationItem(label: 'Int\'l Equities', percentage: 18.0, value: 51255.11),
        AllocationItem(label: 'Fixed Income', percentage: 25.0, value: 71187.65),
        AllocationItem(label: 'Real Estate', percentage: 8.0, value: 22780.05),
        AllocationItem(label: 'Cash', percentage: 7.0, value: 19932.54),
      ],
    );
