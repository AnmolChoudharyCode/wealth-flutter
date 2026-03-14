import 'dart:math' as math;
import '../models/financial_profile.dart';
import '../models/goal.dart';
import '../models/goal_metrics.dart';
import '../models/year_projection.dart';

abstract final class WealthCalculator {
  static const int _baseYear = 2025;

  /// Formats a rupee amount into Indian shorthand (₹Cr, ₹L, ₹K).
  static String formatRupee(double amount) {
    if (amount.isNaN || amount.isInfinite) return '₹0';
    final abs = amount.abs();
    String formatted;
    if (abs >= 10000000) {
      formatted = '₹${(abs / 10000000).toStringAsFixed(2)}Cr';
    } else if (abs >= 100000) {
      formatted = '₹${(abs / 100000).toStringAsFixed(2)}L';
    } else if (abs >= 1000) {
      formatted = '₹${(abs / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = '₹${abs.round()}';
    }
    return amount < 0 ? '-$formatted' : formatted;
  }

  /// Excel FV function equivalent.
  /// FV(rate, nper, pmt, pv, type) — type=1 means payment at beginning of period.
  /// Returns positive value when pv and pmt are negative (investments/outflows).
  static double fv(double rate, int nper, double pmt, double pv, {int type = 1}) {
    if (rate == 0) return -(pv + pmt * nper);
    final factor = math.pow(1 + rate, nper).toDouble();
    final result = pv * factor + pmt * ((factor - 1) / rate) * (1 + rate * type);
    return -result;
  }

  /// Year-by-year wealth projections matching the Excel model.
  static List<YearProjection> calculateProjections(
    FinancialProfile profile,
    List<Goal> goals,
  ) {
    final maxYear = goals.isNotEmpty
        ? goals.map((g) => g.targetYear).reduce(math.max)
        : _baseYear + 30;

    final projections = <YearProjection>[];
    var runningValue = profile.currentAUM;
    final monthlyRate = profile.expectedReturn / 100 / 12;

    final totalYears = math.min(maxYear - _baseYear, 30);

    for (var offset = 0; offset <= totalYears; offset++) {
      final year = _baseYear + offset;
      final age = (profile.currentAge + offset).floor();
      final yearBeginning = runningValue;

      final yearMonthlySIP =
          profile.monthlySIP * math.pow(1 + profile.annualSIPIncrease / 100, offset);

      // Goals due this year — inflation-adjusted using Excel FV
      double goalAmount = 0;
      final goalNames = <String>[];
      for (final goal in goals) {
        if (goal.targetYear == year) {
          final yearsFromBase = math.max(0, year - _baseYear);
          final adjusted = fv(
            profile.inflationRate / 100,
            yearsFromBase,
            0,
            -goal.targetAmount,
          );
          goalAmount += adjusted;
          goalNames.add(goal.name);
        }
      }

      // Year-end corpus: FV(monthly rate, 12 months, -monthlySIP, -beginning) - goal
      final yearEndBeforeGoal = fv(
        monthlyRate,
        12,
        -yearMonthlySIP,
        -yearBeginning,
      );
      final yearEndCorpus = yearEndBeforeGoal - goalAmount;
      runningValue = yearEndCorpus;

      projections.add(YearProjection(
        year: year,
        age: age,
        yearBeginningInvestment: yearBeginning,
        monthlySIP: yearMonthlySIP,
        annualSIP: yearMonthlySIP * 12,
        goalAmount: goalAmount,
        yearEndCorpus: yearEndCorpus,
        goalNames: List.unmodifiable(goalNames),
      ));
    }

    return projections;
  }

  /// Calculates feasibility metrics for a single goal.
  static GoalMetrics calculateGoalMetrics(Goal goal, FinancialProfile profile) {
    final adjustedTarget = _adjustedTarget(
      goal.targetAmount,
      goal.targetYear,
      profile.inflationRate,
    );

    final projected = _projectedValue(
          profile.currentAUM,
          profile.monthlySIP,
          profile.expectedReturn,
          profile.annualSIPIncrease,
          goal.targetYear,
        ) +
        goal.currentValue;

    final shortfall = adjustedTarget - projected;
    final fundingRatio = adjustedTarget > 0
        ? math.min(100.0, (projected / adjustedTarget) * 100)
        : 0.0;

    return GoalMetrics(
      adjustedTarget: adjustedTarget,
      projectedValue: projected,
      shortfall: shortfall,
      fundingRatio: fundingRatio,
      isOnTrack: shortfall <= 0,
    );
  }

  /// Total projected wealth at the furthest goal year.
  static double totalProjectedWealth(FinancialProfile profile, List<Goal> goals) {
    final currentYear = DateTime.now().year;
    final targetYear = goals.isNotEmpty
        ? goals.map((g) => g.targetYear).reduce(math.max)
        : currentYear + 30;
    return _projectedValue(
      profile.currentAUM,
      profile.monthlySIP,
      profile.expectedReturn,
      profile.annualSIPIncrease,
      targetYear,
    );
  }

  // ─── private helpers ────────────────────────────────────────────────────────

  static double _adjustedTarget(
    double amount,
    int targetYear,
    double inflationRate,
  ) {
    final years = targetYear - DateTime.now().year;
    if (years <= 0) return amount;
    return amount * math.pow(1 + inflationRate / 100, years);
  }

  static double _projectedValue(
    double currentAUM,
    double monthlySIP,
    double expectedReturn,
    double annualSIPIncrease,
    int targetYear,
  ) {
    final years = targetYear - DateTime.now().year;
    if (years <= 0) return currentAUM;

    double value = currentAUM;
    final monthlyReturn = expectedReturn / 100 / 12;
    final annualReturn = expectedReturn / 100;

    for (var y = 0; y < years; y++) {
      value *= (1 + annualReturn);
      final yearSIP = monthlySIP * math.pow(1 + annualSIPIncrease / 100, y);
      double sipContrib = 0;
      for (var m = 0; m < 12; m++) {
        sipContrib += yearSIP * math.pow(1 + monthlyReturn, 12 - m);
      }
      value += sipContrib;
    }

    return value;
  }
}
