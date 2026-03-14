import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/financial_profile.dart';
import '../models/goal.dart';
import '../models/year_projection.dart';
import '../providers/goals_provider.dart';
import '../utils/wealth_calculator.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsProvider);

    if (!state.isDataEntered || state.profile == null) {
      return _EmptyState(
        onSetGoal: () => context.push(RouteNames.setGoal),
      );
    }

    return _GoalsDashboard(
      profile: state.profile!,
      goals: state.goals.toList(),
      onEdit: () => context.push(RouteNames.setGoal),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onSetGoal;

  const _EmptyState({required this.onSetGoal});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/images/lottie/cycle.json',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No goals yet',
                style: AppTextStyles.headingMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Set a financial goal and track\nyour progress towards it.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSetGoal,
                  icon: const Icon(Icons.add),
                  label: const Text('Set a Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dashboard ────────────────────────────────────────────────────────────────

class _GoalsDashboard extends StatelessWidget {
  final FinancialProfile profile;
  final List<Goal> goals;
  final VoidCallback onEdit;

  const _GoalsDashboard({
    required this.profile,
    required this.goals,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final projections = WealthCalculator.calculateProjections(profile, goals);
    final projectedWealth = WealthCalculator.totalProjectedWealth(profile, goals);
    final totalGoalsAmount =
        goals.fold<double>(0, (sum, g) => sum + g.targetAmount);
    final onTrackCount =
        goals.where((g) => WealthCalculator.calculateGoalMetrics(g, profile).isOnTrack).length;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            80,
          ),
          children: [
            // ── Header ──────────────────────────────────────────────────
            _Header(name: profile.name),
            const SizedBox(height: AppSpacing.sectionGap),

            // ── 4 Metric Cards ───────────────────────────────────────────
            _MetricsGrid(
              currentAUM: profile.currentAUM,
              projectedWealth: projectedWealth,
              monthlySIP: profile.monthlySIP,
              totalGoalsAmount: totalGoalsAmount,
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // ── Goal Feasibility ─────────────────────────────────────────
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: Icons.track_changes_outlined,
                    title: 'Goal Feasibility Analysis',
                    subtitle: '$onTrackCount of ${goals.length} goals on track',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (goals.isEmpty)
                    _EmptyHint(
                        text: 'No goals added. Tap "Edit Goals" to add some.')
                  else
                    Column(
                      children: goals
                          .map((g) => _GoalFeasibilityTile(
                                goal: g,
                                profile: profile,
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // ── Year-by-Year Table ───────────────────────────────────────
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: Icons.table_chart_outlined,
                    title: 'Year-by-Year Projections',
                    subtitle: 'Detailed wealth accumulation breakdown',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProjectionsTable(projections: projections),
                ],
              ),
            ),
          ],
        ),

        // ── Sticky "Edit Goals" button ───────────────────────────────────
        Positioned(
          left: AppSpacing.pagePadding,
          right: AppSpacing.pagePadding,
          bottom: AppSpacing.md,
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile & Goals'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String name;

  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPurple, AppColors.rose],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: Colors.white, size: 32),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Goals',
                style: AppTextStyles.headingLg
                    .copyWith(color: Colors.white),
              ),
              Text(
                name,
                style: AppTextStyles.bodyMd
                    .copyWith(color: Colors.white.withAlpha(200)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Metric Cards ─────────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  final double currentAUM;
  final double projectedWealth;
  final double monthlySIP;
  final double totalGoalsAmount;

  const _MetricsGrid({
    required this.currentAUM,
    required this.projectedWealth,
    required this.monthlySIP,
    required this.totalGoalsAmount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricItem(
        label: 'Current AUM',
        value: WealthCalculator.formatRupee(currentAUM),
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF5B8CDE),
      ),
      _MetricItem(
        label: 'Projected Wealth',
        value: WealthCalculator.formatRupee(projectedWealth),
        icon: Icons.trending_up,
        color: AppColors.positive,
        valueColor: projectedWealth >= 0 ? AppColors.positive : AppColors.negative,
      ),
      _MetricItem(
        label: 'Monthly SIP',
        value: WealthCalculator.formatRupee(monthlySIP),
        icon: Icons.repeat_rounded,
        color: const Color(0xFFE8A838),
      ),
      _MetricItem(
        label: 'Total Goals',
        value: WealthCalculator.formatRupee(totalGoalsAmount),
        icon: Icons.flag_outlined,
        color: AppColors.rose,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final crossCount = constraints.maxWidth > 500 ? 4 : 2;
      return GridView.count(
        crossAxisCount: crossCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.4,
        children: items.map((item) => _MetricCard(item: item)).toList(),
      );
    });
  }
}

class _MetricItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color? valueColor;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.valueColor,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricItem item;

  const _MetricCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withAlpha(30),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: AppTextStyles.bodySm),
              Text(
                item.value,
                style: AppTextStyles.headingSm.copyWith(
                  color: item.valueColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Goal Feasibility Tile ────────────────────────────────────────────────────

class _GoalFeasibilityTile extends StatelessWidget {
  final Goal goal;
  final FinancialProfile profile;

  const _GoalFeasibilityTile({required this.goal, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metrics = WealthCalculator.calculateGoalMetrics(goal, profile);
    final borderColor =
        metrics.isOnTrack ? AppColors.positive : AppColors.negative;
    final statusColor =
        metrics.isOnTrack ? AppColors.positive : AppColors.negative;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: AppTextStyles.headingSm),
                    Text(
                      '${goal.targetYear} · ${goal.yearsAway} years away',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.borderRadiusFull),
                ),
                child: Text(
                  metrics.isOnTrack ? 'On Track' : 'Shortfall',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetricLine(
                  label: 'Adjusted Target',
                  value: WealthCalculator.formatRupee(metrics.adjustedTarget),
                ),
              ),
              Expanded(
                child: _MetricLine(
                  label: 'Projected Value',
                  value: WealthCalculator.formatRupee(metrics.projectedValue),
                ),
              ),
              Expanded(
                child: _MetricLine(
                  label: metrics.isOnTrack ? 'Surplus' : 'Shortfall',
                  value:
                      '${metrics.isOnTrack ? '+' : '-'}${WealthCalculator.formatRupee(metrics.shortfall.abs())}',
                  valueColor: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.borderRadiusFull),
                  child: LinearProgressIndicator(
                    value: metrics.fundingRatio / 100,
                    backgroundColor:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        metrics.isOnTrack ? AppColors.positive : AppColors.darkPurple),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${metrics.fundingRatio.round()}%',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm),
        Text(
          value,
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─── Projections Table ────────────────────────────────────────────────────────

class _ProjectionsTable extends StatelessWidget {
  final List<YearProjection> projections;

  const _ProjectionsTable({required this.projections});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerStyle = AppTextStyles.labelSmall.copyWith(
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary,
    );
    final cellStyle = AppTextStyles.bodySm;
    const cellPad = EdgeInsets.symmetric(horizontal: 10, vertical: 10);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 44,
        columnSpacing: 16,
        horizontalMargin: 4,
        headingRowColor: WidgetStateProperty.all(
          isDark ? AppColors.surfaceDark : AppColors.lightBg,
        ),
        border: TableBorder.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        ),
        columns: [
          DataColumn(label: Padding(padding: cellPad, child: Text('Year', style: headerStyle))),
          DataColumn(label: Padding(padding: cellPad, child: Text('Age', style: headerStyle))),
          DataColumn(label: Padding(padding: cellPad, child: Text('Yr. Begin', style: headerStyle))),
          DataColumn(label: Padding(padding: cellPad, child: Text('Monthly SIP', style: headerStyle))),
          DataColumn(label: Padding(padding: cellPad, child: Text('Annual SIP', style: headerStyle))),
          DataColumn(label: Padding(padding: cellPad, child: Text('Goal Amt', style: headerStyle))),
          DataColumn(label: Padding(padding: cellPad, child: Text('Yr. End Corpus', style: headerStyle))),
          DataColumn(label: Padding(padding: cellPad, child: Text('Goal', style: headerStyle))),
        ],
        rows: projections.map((row) {
          final hasGoal = row.goalAmount > 0;
          final isNegative = row.yearEndCorpus < 0;
          return DataRow(
            color: hasGoal
                ? WidgetStateProperty.all(
                    AppColors.darkPurple.withAlpha(15))
                : null,
            cells: [
              DataCell(Text(row.year.toString(), style: cellStyle)),
              DataCell(Text(row.age.toString(), style: cellStyle)),
              DataCell(Text(WealthCalculator.formatRupee(row.yearBeginningInvestment), style: cellStyle)),
              DataCell(Text(WealthCalculator.formatRupee(row.monthlySIP), style: cellStyle)),
              DataCell(Text(WealthCalculator.formatRupee(row.annualSIP), style: cellStyle)),
              DataCell(Text(
                hasGoal ? WealthCalculator.formatRupee(row.goalAmount) : '—',
                style: cellStyle.copyWith(
                  color: hasGoal ? AppColors.negative : null,
                  fontWeight: hasGoal ? FontWeight.w600 : null,
                ),
              )),
              DataCell(Text(
                WealthCalculator.formatRupee(row.yearEndCorpus),
                style: cellStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isNegative ? AppColors.negative : AppColors.positive,
                ),
              )),
              DataCell(Text(
                row.goalNames.isNotEmpty ? row.goalNames.join(', ') : '—',
                style: cellStyle,
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.darkPurple.withAlpha(20),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          ),
          child: Icon(icon, color: AppColors.darkPurple, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.headingSm),
            Text(subtitle, style: AppTextStyles.bodySm),
          ],
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
