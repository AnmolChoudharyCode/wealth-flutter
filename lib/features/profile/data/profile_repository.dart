import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (_) => ProfileRepository(),
);

class ProfileRepository {
  Future<UserProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserProfile(
      id: 'user_001',
      name: 'Alex Johnson',
      email: 'alex.johnson@example.com',
      phone: '+1 (555) 234-5678',
      country: 'United States',
      joinedAt: DateTime(2022, 3, 15),
    );
  }
}
