class YearProjection {
  final int year;
  final int age;
  final double yearBeginningInvestment;
  final double monthlySIP;
  final double annualSIP;
  final double goalAmount;
  final double yearEndCorpus;
  final List<String> goalNames;

  const YearProjection({
    required this.year,
    required this.age,
    required this.yearBeginningInvestment,
    required this.monthlySIP,
    required this.annualSIP,
    required this.goalAmount,
    required this.yearEndCorpus,
    required this.goalNames,
  });
}
