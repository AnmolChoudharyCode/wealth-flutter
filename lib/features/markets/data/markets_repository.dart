import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_ticker.dart';

final marketsRepositoryProvider = Provider<MarketsRepository>(
  (_) => MarketsRepository(),
);

class MarketsRepository {
  Future<List<MarketTicker>> getMarketData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return mockMarketTickers;
  }
}
