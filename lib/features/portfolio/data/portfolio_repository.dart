import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/holding.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>(
  (_) => PortfolioRepository(),
);

class PortfolioRepository {
  Future<List<Holding>> getHoldings() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return mockHoldings;
  }
}
