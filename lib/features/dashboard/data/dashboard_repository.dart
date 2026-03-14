import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/portfolio_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (_) => DashboardRepository(),
);

class DashboardRepository {
  Future<PortfolioSummary> getPortfolioSummary() async {
    // TODO: Replace with real API call via Dio
    await Future.delayed(const Duration(milliseconds: 800));
    return mockPortfolioSummary;
  }
}
