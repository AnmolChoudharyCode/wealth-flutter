class GoalMetrics {
  final double adjustedTarget;
  final double projectedValue;
  final double shortfall;
  final double fundingRatio;
  final bool isOnTrack;

  const GoalMetrics({
    required this.adjustedTarget,
    required this.projectedValue,
    required this.shortfall,
    required this.fundingRatio,
    required this.isOnTrack,
  });
}
