import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/auth_repository.dart';

// Local provider — scoped to this page
final _forgotPasswordProvider =
    NotifierProvider.autoDispose<_ForgotPasswordNotifier, _ForgotPasswordState>(
  _ForgotPasswordNotifier.new,
);

class _ForgotPasswordState {
  final String email;
  final bool isLoading;
  final String? errorMessage;
  final bool emailSent;

  const _ForgotPasswordState({
    this.email = '',
    this.isLoading = false,
    this.errorMessage,
    this.emailSent = false,
  });

  _ForgotPasswordState copyWith({
    String? email,
    bool? isLoading,
    String? errorMessage,
    bool? emailSent,
    bool clearError = false,
  }) =>
      _ForgotPasswordState(
        email: email ?? this.email,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        emailSent: emailSent ?? this.emailSent,
      );
}

class _ForgotPasswordNotifier
    extends AutoDisposeNotifier<_ForgotPasswordState> {
  @override
  _ForgotPasswordState build() => const _ForgotPasswordState();

  void setEmail(String v) =>
      state = state.copyWith(email: v, clearError: true);

  Future<void> submit() async {
    if (state.email.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email address.');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(state.email.trim());
      state = state.copyWith(isLoading: false, emailSent: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

class ForgotPasswordPage extends ConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_forgotPasswordProvider);
    final notifier = ref.read(_forgotPasswordProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: state.emailSent
                  ? _SuccessView(email: state.email)
                  : _FormView(state: state, notifier: notifier),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final _ForgotPasswordState state;
  final _ForgotPasswordNotifier notifier;

  const _FormView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.darkPurple.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.lock_reset_outlined,
              color: AppColors.darkPurple, size: 28),
        ),
        const SizedBox(height: 20),
        const Text('Reset password', style: AppTextStyles.headingLg),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we\'ll send you a link to reset your password.',
          style:
              AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),

        if (state.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.negative.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(color: AppColors.negative.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.negative, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.negative),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onChanged: notifier.setEmail,
          onFieldSubmitted: (_) => notifier.submit(),
        ),
        const SizedBox(height: AppSpacing.lg),

        ElevatedButton(
          onPressed: state.isLoading ? null : notifier.submit,
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Send Reset Link'),
        ),
        const SizedBox(height: AppSpacing.md),

        TextButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(RouteNames.login),
          child: const Text(
            'Back to Sign In',
            style: TextStyle(color: AppColors.darkPurple),
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.positive.withAlpha(20),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              color: AppColors.positive, size: 28),
        ),
        const SizedBox(height: 20),
        const Text('Check your email', style: AppTextStyles.headingLg),
        const SizedBox(height: 8),
        Text(
          'We sent a password reset link to',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.darkPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.positive.withAlpha(15),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            border: Border.all(color: AppColors.positive.withAlpha(50)),
          ),
          child: Text(
            'Didn\'t receive the email? Check your spam folder or make sure the address is correct.',
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.positive.withAlpha(200)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          onPressed: () => context.go(RouteNames.login),
          child: const Text('Back to Sign In'),
        ),
      ],
    );
  }
}
