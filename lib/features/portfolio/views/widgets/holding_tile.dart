import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/percentage_formatter.dart';
import '../../models/holding.dart';

class HoldingTile extends StatelessWidget {
  final Holding holding;

  const HoldingTile({required this.holding, super.key});

  @override
  Widget build(BuildContext context) {
    final changeColor = PercentageFormatter.color(holding.gainLoss);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          // Ticker badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkPurple.withAlpha(40),
                  AppColors.rose.withAlpha(40),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Center(
              child: Text(
                holding.symbol.length > 4
                    ? holding.symbol.substring(0, 3)
                    : holding.symbol,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name and shares
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(holding.symbol, style: AppTextStyles.headingSm),
                Text(
                  '${holding.shares.toStringAsFixed(2)} shares',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          // Value and P&L
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.full(holding.currentValue),
                style: AppTextStyles.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    holding.isPositive
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 11,
                    color: changeColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${CurrencyFormatter.pnl(holding.gainLoss)} '
                    '(${PercentageFormatter.format(holding.gainLossPercent)})',
                    style: AppTextStyles.bodySm.copyWith(color: changeColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
