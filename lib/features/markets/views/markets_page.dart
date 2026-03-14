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
import '../models/market_ticker.dart';
import '../providers/market_data_provider.dart';
import 'widgets/market_ticker_tile.dart';

class MarketsPage extends ConsumerWidget {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketAsync = ref.watch(marketDataProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(marketDataProvider.notifier).refresh(),
      child: marketAsync.when(
        loading: () => const _MarketsShimmer(),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(marketDataProvider),
        ),
        data: (tickers) => _MarketsContent(tickers: tickers),
      ),
    );
  }
}

class _MarketsContent extends ConsumerWidget {
  final List<MarketTicker> tickers;

  const _MarketsContent({required this.tickers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indices = tickers.where((t) => ['S&P 500', 'NASDAQ', 'DOW'].contains(t.symbol)).toList();
    final watchlisted = tickers.where((t) => t.isWatchlisted).toList();
    final allStocks = tickers.where((t) => !['S&P 500', 'NASDAQ', 'DOW'].contains(t.symbol)).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        // Market indices strip
        if (indices.isNotEmpty) ...[
          const SectionHeader(title: 'Market Indices'),
          const SizedBox(height: AppSpacing.md),
          _IndicesStrip(indices: indices),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
        // Watchlist
        if (watchlisted.isNotEmpty) ...[
          const SectionHeader(title: 'Watchlist'),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: watchlisted.asMap().entries.map((entry) {
                return Column(
                  children: [
                    MarketTickerTile(
                      ticker: entry.value,
                      onWatchlistToggle: () => ref
                          .read(marketDataProvider.notifier)
                          .toggleWatchlist(entry.value.symbol),
                    ),
                    if (entry.key < watchlisted.length - 1)
                      const Divider(height: 1, indent: AppSpacing.pagePadding),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
        // All markets
        SectionHeader(title: 'All Markets (${allStocks.length})'),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: allStocks.asMap().entries.map((entry) {
              return Column(
                children: [
                  MarketTickerTile(
                    ticker: entry.value,
                    onWatchlistToggle: () => ref
                        .read(marketDataProvider.notifier)
                        .toggleWatchlist(entry.value.symbol),
                  ),
                  if (entry.key < allStocks.length - 1)
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

class _IndicesStrip extends StatelessWidget {
  final List<MarketTicker> indices;

  const _IndicesStrip({required this.indices});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: indices.map((ticker) {
          final color = PercentageFormatter.color(ticker.change);
          return Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticker.symbol, style: AppTextStyles.labelSmall),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.noDecimal(ticker.price),
                  style: AppTextStyles.headingSm,
                ),
                const SizedBox(height: 2),
                Text(
                  PercentageFormatter.format(ticker.changePercent),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MarketsShimmer extends StatelessWidget {
  const _MarketsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ShimmerBox(width: double.infinity, height: 80),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ...List.generate(
          6,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ShimmerBox(width: double.infinity, height: 64),
          ),
        ),
      ],
    );
  }
}
