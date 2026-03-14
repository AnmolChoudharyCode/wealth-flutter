import 'package:flutter/foundation.dart';

@immutable
class FinancialProfile {
  final String name;
  final String mobileNo;
  final double currentAge;
  final double monthlySIP;
  final double expectedReturn;
  final double currentAUM;
  final double annualSIPIncrease;
  final double inflationRate;

  const FinancialProfile({
    required this.name,
    required this.mobileNo,
    required this.currentAge,
    required this.monthlySIP,
    required this.expectedReturn,
    required this.currentAUM,
    required this.annualSIPIncrease,
    required this.inflationRate,
  });

  FinancialProfile copyWith({
    String? name,
    String? mobileNo,
    double? currentAge,
    double? monthlySIP,
    double? expectedReturn,
    double? currentAUM,
    double? annualSIPIncrease,
    double? inflationRate,
  }) {
    return FinancialProfile(
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      currentAge: currentAge ?? this.currentAge,
      monthlySIP: monthlySIP ?? this.monthlySIP,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      currentAUM: currentAUM ?? this.currentAUM,
      annualSIPIncrease: annualSIPIncrease ?? this.annualSIPIncrease,
      inflationRate: inflationRate ?? this.inflationRate,
    );
  }
}
