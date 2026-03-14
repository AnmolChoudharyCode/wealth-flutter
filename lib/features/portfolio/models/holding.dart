import 'package:equatable/equatable.dart';

class Holding extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final String assetClass;
  final double shares;
  final double currentPrice;
  final double avgCostBasis;
  final double? logoUrl;

  const Holding({
    required this.id,
    required this.symbol,
    required this.name,
    required this.assetClass,
    required this.shares,
    required this.currentPrice,
    required this.avgCostBasis,
    this.logoUrl,
  });

  double get currentValue => shares * currentPrice;
  double get costBasis => shares * avgCostBasis;
  double get gainLoss => currentValue - costBasis;
  double get gainLossPercent => costBasis > 0 ? (gainLoss / costBasis) * 100 : 0;
  bool get isPositive => gainLoss >= 0;

  @override
  List<Object?> get props => [id, symbol, shares, currentPrice, avgCostBasis];
}

/// Mock holdings data
List<Holding> get mockHoldings => [
      const Holding(
        id: '1',
        symbol: 'AAPL',
        name: 'Apple Inc.',
        assetClass: 'US Equities',
        shares: 50,
        currentPrice: 189.30,
        avgCostBasis: 142.50,
      ),
      const Holding(
        id: '2',
        symbol: 'MSFT',
        name: 'Microsoft Corp.',
        assetClass: 'US Equities',
        shares: 30,
        currentPrice: 415.80,
        avgCostBasis: 310.00,
      ),
      const Holding(
        id: '3',
        symbol: 'VTI',
        name: 'Vanguard Total Market ETF',
        assetClass: 'US Equities',
        shares: 120,
        currentPrice: 242.15,
        avgCostBasis: 198.00,
      ),
      const Holding(
        id: '4',
        symbol: 'BND',
        name: 'Vanguard Bond Market ETF',
        assetClass: 'Fixed Income',
        shares: 200,
        currentPrice: 73.45,
        avgCostBasis: 76.00,
      ),
      const Holding(
        id: '5',
        symbol: 'VNQ',
        name: 'Vanguard Real Estate ETF',
        assetClass: 'Real Estate',
        shares: 80,
        currentPrice: 84.60,
        avgCostBasis: 79.50,
      ),
    ];
