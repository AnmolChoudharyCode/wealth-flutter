import 'package:equatable/equatable.dart';

class MarketTicker extends Equatable {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final bool isWatchlisted;

  const MarketTicker({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    this.isWatchlisted = false,
  });

  bool get isPositive => change >= 0;

  MarketTicker copyWith({bool? isWatchlisted}) => MarketTicker(
        symbol: symbol,
        name: name,
        price: price,
        change: change,
        changePercent: changePercent,
        isWatchlisted: isWatchlisted ?? this.isWatchlisted,
      );

  @override
  List<Object?> get props =>
      [symbol, name, price, change, changePercent, isWatchlisted];
}

List<MarketTicker> get mockMarketTickers => [
      const MarketTicker(symbol: 'S&P 500', name: 'S&P 500 Index', price: 5248.49, change: 23.15, changePercent: 0.44),
      const MarketTicker(symbol: 'NASDAQ', name: 'NASDAQ Composite', price: 16432.26, change: -45.32, changePercent: -0.28),
      const MarketTicker(symbol: 'DOW', name: 'Dow Jones Industrial', price: 39131.53, change: 134.21, changePercent: 0.34),
      const MarketTicker(symbol: 'AAPL', name: 'Apple Inc.', price: 189.30, change: 1.45, changePercent: 0.77, isWatchlisted: true),
      const MarketTicker(symbol: 'MSFT', name: 'Microsoft Corp.', price: 415.80, change: -2.30, changePercent: -0.55, isWatchlisted: true),
      const MarketTicker(symbol: 'GOOGL', name: 'Alphabet Inc.', price: 175.50, change: 0.85, changePercent: 0.49),
      const MarketTicker(symbol: 'AMZN', name: 'Amazon.com Inc.', price: 208.30, change: -1.70, changePercent: -0.81),
      const MarketTicker(symbol: 'TSLA', name: 'Tesla Inc.', price: 176.75, change: 5.25, changePercent: 3.06, isWatchlisted: true),
      const MarketTicker(symbol: 'BTC', name: 'Bitcoin', price: 67432.50, change: 1234.50, changePercent: 1.87),
      const MarketTicker(symbol: 'ETH', name: 'Ethereum', price: 3542.80, change: -45.20, changePercent: -1.26),
    ];
