import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/auth_provider.dart';

class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
    this.obscurePassword = true,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    bool? obscurePassword,
    bool clearError = false,
  }) =>
      LoginState(
        email: email ?? this.email,
        password: password ?? this.password,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        obscurePassword: obscurePassword ?? this.obscurePassword,
      );
}

final loginProvider =
    NotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setEmail(String v) => state = state.copyWith(email: v, clearError: true);
  void setPassword(String v) =>
      state = state.copyWith(password: v, clearError: true);
  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  Future<void> submit() async {
    if (state.email.trim().isEmpty || state.password.isEmpty) {
      state =
          state.copyWith(errorMessage: 'Please enter your email and password.');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(authProvider.notifier)
          .login(state.email.trim(), state.password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        // Firebase errors arrive as Exception("message") — strip the prefix.
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
