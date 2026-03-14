import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../data/auth_repository.dart';
import '../providers/login_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);

    // Navigate when auth succeeds
    ref.listen(authProvider, (_, next) {
      next.whenData((user) {
        if (user != null) context.go(RouteNames.dashboard);
      });
    });

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const _Logo(),
                  const SizedBox(height: 40),
                  Text(
                    'Welcome back',
                    style: AppTextStyles.headingLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _DemoBanner(loginState: loginState),
                  const SizedBox(height: 20),
                  _LoginForm(loginState: loginState),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoBanner extends ConsumerWidget {
  final LoginState loginState;
  const _DemoBanner({required this.loginState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loginProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkPurple.withAlpha(12),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.darkPurple.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.darkPurple),
              const SizedBox(width: 6),
              Text(
                'Quick Access',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.darkPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Use your Firebase account or try the demo:',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          _CredentialRow(label: 'Email', value: demoEmail),
          const SizedBox(height: 4),
          _CredentialRow(label: 'Password', value: demoPassword),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: loginState.isLoading
                  ? null
                  : () {
                      notifier.setEmail(demoEmail);
                      notifier.setPassword(demoPassword);
                      notifier.submit();
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkPurple,
                side: const BorderSide(color: AppColors.darkPurple),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
              ),
              child: const Text(
                'Continue as Demo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;
  const _CredentialRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.darkPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.darkPurple, AppColors.rose],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        const Text('Wealth', style: AppTextStyles.headingLg),
      ],
    );
  }
}

class _LoginForm extends ConsumerWidget {
  final LoginState loginState;

  const _LoginForm({required this.loginState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loginProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loginState.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.negative.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(color: AppColors.negative.withAlpha(60)),
            ),
            child: Text(
              loginState.errorMessage!,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.negative),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextFormField(
          initialValue: loginState.email,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: notifier.setEmail,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          initialValue: loginState.password,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                loginState.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: notifier.togglePasswordVisibility,
            ),
          ),
          obscureText: loginState.obscurePassword,
          textInputAction: TextInputAction.done,
          onChanged: notifier.setPassword,
          onFieldSubmitted: (_) => notifier.submit(),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          onPressed: loginState.isLoading ? null : notifier.submit,
          child: loginState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Sign In'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => context.push(RouteNames.forgotPassword),
          child: const Text(
            'Forgot password?',
            style: TextStyle(color: AppColors.darkPurple),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SignUpLink(),
      ],
    );
  }
}

class _SignUpLink extends StatelessWidget {
  const _SignUpLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => context.go(RouteNames.register),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.darkPurple,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
