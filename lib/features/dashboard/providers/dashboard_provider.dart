import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../models/portfolio_summary.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, PortfolioSummary>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<PortfolioSummary> {
  @override
  Future<PortfolioSummary> build() => _fetch();

  Future<PortfolioSummary> _fetch() =>
      ref.read(dashboardRepositoryProvider).getPortfolioSummary();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
