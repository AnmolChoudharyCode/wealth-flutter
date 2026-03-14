import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/percentage_formatter.dart';
import '../../models/market_ticker.dart';

class MarketTickerTile extends StatelessWidget {
  final MarketTicker ticker;
  final VoidCallback? onWatchlistToggle;

  const MarketTickerTile({
    required this.ticker,
    this.onWatchlistToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = PercentageFormatter.color(ticker.change);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          // Symbol badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ticker.isPositive
                  ? AppColors.positive.withAlpha(20)
                  : AppColors.negative.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Center(
              child: Text(
                ticker.symbol.length > 3
                    ? ticker.symbol.substring(0, 3)
                    : ticker.symbol,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ticker.isPositive ? AppColors.positive : AppColors.negative,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticker.symbol, style: AppTextStyles.headingSm),
                Text(
                  ticker.name,
                  style: AppTextStyles.bodySm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Price and change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.full(ticker.price),
                style: AppTextStyles.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withAlpha(20),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.borderRadiusFull),
                ),
                child: Text(
                  PercentageFormatter.format(ticker.changePercent),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
              ),
            ],
          ),
          if (onWatchlistToggle != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: Icon(
                ticker.isWatchlisted ? Icons.star : Icons.star_border,
                color: ticker.isWatchlisted
                    ? AppColors.darkPurple
                    : AppColors.neutral,
                size: 20,
              ),
              onPressed: onWatchlistToggle,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
