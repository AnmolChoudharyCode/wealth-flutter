import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/percentage_formatter.dart';
import '../../models/portfolio_summary.dart';

class PortfolioValueHeader extends StatelessWidget {
  final PortfolioSummary summary;

  const PortfolioValueHeader({required this.summary, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPurple, AppColors.rose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Portfolio Value',
            style: AppTextStyles.labelLg.copyWith(
              color: Colors.white.withAlpha(180),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.full(summary.totalValue),
            style: AppTextStyles.valueDisplayLg.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      summary.isDailyPositive
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${CurrencyFormatter.pnl(summary.dailyChange)} '
                      '(${PercentageFormatter.format(summary.dailyChangePercent)}) today',
                      style: AppTextStyles.bodySm.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
