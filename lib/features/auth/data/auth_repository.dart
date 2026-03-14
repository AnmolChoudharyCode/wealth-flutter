import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(fb.FirebaseAuth.instance),
);

// Demo credentials — for testing without a Firebase account
const demoEmail = 'demo@wealth.app';
const demoPassword = 'demo123';

class AuthRepository {
  final fb.FirebaseAuth _auth;
  const AuthRepository(this._auth);

  /// Stream of auth state — emits on sign-in, sign-out, and token refresh.
  Stream<User?> watchAuthState() =>
      _auth.authStateChanges().map((u) => u != null ? _map(u) : null);

  /// Returns the currently signed-in Firebase user mapped to app User, or null.
  User? get currentUser =>
      _auth.currentUser != null ? _map(_auth.currentUser!) : null;

  /// Sign in with email and password.
  Future<User> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _map(cred.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  /// Create a new account with email, password, and display name.
  Future<User> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Set display name so the mapped user has a proper name
      await cred.user!.updateDisplayName(name.trim());
      await cred.user!.reload();
      return _map(_auth.currentUser!);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  /// Send a password-reset email. Throws a friendly Exception on failure.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  /// Sign out the current user.
  Future<void> signOut() => _auth.signOut();

  // ── helpers ────────────────────────────────────────────────────────────────

  User _map(fb.User u) => User(
        id: u.uid,
        name: u.displayName ?? u.email!.split('@').first,
        email: u.email!,
        avatarUrl: u.photoURL,
      );

  Exception _mapError(fb.FirebaseAuthException e) {
    final msg = switch (e.code) {
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'Incorrect email or password.',
      'email-already-in-use' => 'An account with this email already exists.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'Network error. Check your connection.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Password must be at least 6 characters.',
      'operation-not-allowed' =>
        'Email/password sign-in is not enabled. Enable it in Firebase Console.',
      _ => e.message ?? 'Authentication failed. Please try again.',
    };
    return Exception(msg);
  }
}
