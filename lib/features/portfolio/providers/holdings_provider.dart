import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/portfolio_repository.dart';
import '../models/holding.dart';

final holdingsProvider =
    AsyncNotifierProvider<HoldingsNotifier, List<Holding>>(
  HoldingsNotifier.new,
);

class HoldingsNotifier extends AsyncNotifier<List<Holding>> {
  @override
  Future<List<Holding>> build() => _fetch();

  Future<List<Holding>> _fetch() =>
      ref.read(portfolioRepositoryProvider).getHoldings();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
