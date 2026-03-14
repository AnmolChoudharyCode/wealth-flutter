import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_states/error_state_widget.dart';
import '../../../shared/widgets/loaders/shimmer_box.dart';
import '../../../shared/widgets/misc/section_header.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/allocation_chart_section.dart';
import 'widgets/portfolio_value_header.dart';
import 'widgets/quick_stats_row.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      child: summaryAsync.when(
        loading: () => const _DashboardShimmer(),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            PortfolioValueHeader(summary: summary),
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Overview'),
            const SizedBox(height: AppSpacing.md),
            QuickStatsRow(summary: summary),
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Asset Allocation'),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: AllocationChartSection(summary: summary),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
        ),
      ),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        ShimmerBox(width: double.infinity, height: 120, borderRadius: AppSpacing.borderRadiusLg),
        const SizedBox(height: AppSpacing.sectionGap),
        Row(
          children: List.generate(
            4,
            (_) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ShimmerBox(width: double.infinity, height: 88),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ShimmerBox(width: double.infinity, height: 240),
      ],
    );
  }
}
