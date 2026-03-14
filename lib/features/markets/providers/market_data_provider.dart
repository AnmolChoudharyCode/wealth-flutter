import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/markets_repository.dart';
import '../models/market_ticker.dart';

final marketDataProvider =
    AsyncNotifierProvider<MarketDataNotifier, List<MarketTicker>>(
  MarketDataNotifier.new,
);

class MarketDataNotifier extends AsyncNotifier<List<MarketTicker>> {
  @override
  Future<List<MarketTicker>> build() => _fetch();

  Future<List<MarketTicker>> _fetch() =>
      ref.read(marketsRepositoryProvider).getMarketData();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  void toggleWatchlist(String symbol) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((t) {
        if (t.symbol == symbol) {
          return t.copyWith(isWatchlisted: !t.isWatchlisted);
        }
        return t;
      }).toList(),
    );
  }
}
