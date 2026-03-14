import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/percentage_formatter.dart';
import '../../../shared/widgets/empty_states/error_state_widget.dart';
import '../../../shared/widgets/loaders/shimmer_box.dart';
import '../../../shared/widgets/misc/section_header.dart';
import '../models/holding.dart';
import '../providers/holdings_provider.dart';
import 'widgets/holding_tile.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(holdingsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(holdingsProvider.notifier).refresh(),
      child: holdingsAsync.when(
        loading: () => const _PortfolioShimmer(),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(holdingsProvider),
        ),
        data: (holdings) => _PortfolioContent(holdings: holdings),
      ),
    );
  }
}

class _PortfolioContent extends StatelessWidget {
  final List<Holding> holdings;

  const _PortfolioContent({required this.holdings});

  double get _totalValue =>
      holdings.fold(0, (sum, h) => sum + h.currentValue);
  double get _totalGainLoss =>
      holdings.fold(0, (sum, h) => sum + h.gainLoss);
  double get _totalCost =>
      holdings.fold(0, (sum, h) => sum + h.costBasis);
  double get _totalGainLossPercent =>
      _totalCost > 0 ? (_totalGainLoss / _totalCost) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.darkPurple, AppColors.rose],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portfolio Value',
                style: AppTextStyles.labelLg.copyWith(
                  color: Colors.white.withAlpha(180),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                CurrencyFormatter.full(_totalValue),
                style: AppTextStyles.valueDisplayLg.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${CurrencyFormatter.pnl(_totalGainLoss)} '
                '(${PercentageFormatter.format(_totalGainLossPercent)}) total return',
                style: AppTextStyles.bodyMd.copyWith(
                  color: _totalGainLoss >= 0
                      ? Colors.greenAccent.shade100
                      : Colors.redAccent.shade100,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader(
          title: 'Holdings (${holdings.length})',
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: holdings.asMap().entries.map((entry) {
              return Column(
                children: [
                  HoldingTile(holding: entry.value),
                  if (entry.key < holdings.length - 1)
                    const Divider(height: 1, indent: AppSpacing.pagePadding),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
      ],
    );
  }
}

class _PortfolioShimmer extends StatelessWidget {
  const _PortfolioShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        ShimmerBox(width: double.infinity, height: 110, borderRadius: AppSpacing.borderRadiusLg),
        const SizedBox(height: AppSpacing.sectionGap),
        ...List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ShimmerBox(width: double.infinity, height: 64),
          ),
        ),
      ],
    );
  }
}
