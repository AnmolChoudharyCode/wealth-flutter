import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/financial_profile.dart';
import '../models/goal.dart';

@immutable
class GoalsState {
  final FinancialProfile? profile;
  final List<Goal> goals;
  final bool isDataEntered;

  const GoalsState({
    this.profile,
    this.goals = const [],
    this.isDataEntered = false,
  });

  GoalsState copyWith({
    FinancialProfile? profile,
    List<Goal>? goals,
    bool? isDataEntered,
  }) {
    return GoalsState(
      profile: profile ?? this.profile,
      goals: goals ?? this.goals,
      isDataEntered: isDataEntered ?? this.isDataEntered,
    );
  }
}

class GoalsNotifier extends StateNotifier<GoalsState> {
  GoalsNotifier() : super(const GoalsState());

  void save({required FinancialProfile profile, required List<Goal> goals}) {
    state = state.copyWith(
      profile: profile,
      goals: List.unmodifiable(goals),
      isDataEntered: true,
    );
  }

  void reset() {
    state = const GoalsState();
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>(
  (ref) => GoalsNotifier(),
);
