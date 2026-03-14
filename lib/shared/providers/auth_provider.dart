import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../../features/auth/data/auth_repository.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  // Tracks demo sessions (in-memory — demo does not persist across restarts)
  bool _isDemoSession = false;

  static const _demoUser = User(
    id: 'demo_user',
    name: 'Alex Johnson',
    email: demoEmail,
    avatarUrl: null,
  );

  @override
  Future<User?> build() async {
    final repo = ref.read(authRepositoryProvider);

    // Keep state in sync with Firebase auth state changes
    final sub = repo.watchAuthState().listen((user) {
      if (_isDemoSession) return;
      state = AsyncData(user);
    });
    ref.onDispose(sub.cancel);

    // Initial value from Firebase's persisted session
    return repo.currentUser;
  }

  /// Sign in with email + password. Demo credentials bypass Firebase.
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    if (email.trim().toLowerCase() == demoEmail && password == demoPassword) {
      await Future.delayed(const Duration(milliseconds: 500));
      _isDemoSession = true;
      state = const AsyncData(_demoUser);
      return;
    }

    _isDemoSession = false;
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email, password),
    );
  }

  /// Create a new account and sign in immediately.
  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    _isDemoSession = false;
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(name, email, password),
    );
  }

  /// Sign out.
  Future<void> logout() async {
    _isDemoSession = false;
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
