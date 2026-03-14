import 'package:flutter/foundation.dart';

@immutable
class Goal {
  final String id;
  final String name;
  final String category;
  final int targetYear;
  final double targetAmount;
  final double currentValue;

  const Goal({
    required this.id,
    required this.name,
    required this.category,
    required this.targetYear,
    required this.targetAmount,
    this.currentValue = 0.0,
  });

  int get yearsAway => targetYear - DateTime.now().year;

  Goal copyWith({
    String? id,
    String? name,
    String? category,
    int? targetYear,
    double? targetAmount,
    double? currentValue,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetYear: targetYear ?? this.targetYear,
      targetAmount: targetAmount ?? this.targetAmount,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}
