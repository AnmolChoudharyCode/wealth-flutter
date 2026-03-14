import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/auth_provider.dart';

class RegisterState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;
  final bool obscureConfirm;

  const RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
    this.obscurePassword = true,
    this.obscureConfirm = true,
  });

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
    bool? obscurePassword,
    bool? obscureConfirm,
    bool clearError = false,
  }) =>
      RegisterState(
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        obscurePassword: obscurePassword ?? this.obscurePassword,
        obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      );
}

final registerProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(RegisterNotifier.new);

class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  void setName(String v) => state = state.copyWith(name: v, clearError: true);
  void setEmail(String v) => state = state.copyWith(email: v, clearError: true);
  void setPassword(String v) =>
      state = state.copyWith(password: v, clearError: true);
  void setConfirmPassword(String v) =>
      state = state.copyWith(confirmPassword: v, clearError: true);
  void togglePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  void toggleConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  Future<void> submit() async {
    final err = _validate();
    if (err != null) {
      state = state.copyWith(errorMessage: err);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(authProvider.notifier)
          .register(state.name.trim(), state.email.trim(), state.password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String? _validate() {
    if (state.name.trim().isEmpty) return 'Please enter your full name.';
    if (state.email.trim().isEmpty) return 'Please enter your email address.';
    if (state.password.isEmpty) return 'Please enter a password.';
    if (state.password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (state.password != state.confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
