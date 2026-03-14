import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/views/forgot_password_page.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/register_page.dart';
import '../../features/auth/views/splash_page.dart';
import '../../features/dashboard/views/dashboard_page.dart';
import '../../features/goals/views/goals_page.dart';
import '../../features/goals/views/set_goal_page.dart';
import '../../features/markets/views/markets_page.dart';
import '../../features/portfolio/views/portfolio_page.dart';
import '../../features/profile/views/profile_page.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/app_shell/app_shell.dart';
import 'route_names.dart';

/// Bridges Riverpod auth state to GoRouter's refreshListenable.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue>(authProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final isAuthenticated = authState.valueOrNull != null;
    final isLoading = authState.isLoading;
    final location = state.matchedLocation;

    if (isLoading) return null;

    final onPublic = {
      RouteNames.splash,
      RouteNames.login,
      RouteNames.register,
      RouteNames.forgotPassword,
    }.contains(location);

    if (!isAuthenticated && !onPublic) return RouteNames.login;
    if (isAuthenticated && (location == RouteNames.login ||
        location == RouteNames.register)) {
      return RouteNames.dashboard;
    }
    return null;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // ── Public routes (no shell) ──────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      // ── Full-screen authenticated routes (no shell) ───────────────────────
      GoRoute(
        path: RouteNames.setGoal,
        builder: (_, _) => const SetGoalPage(),
      ),
      // ── Authenticated routes (wrapped in AppShell) ────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, _) => const DashboardPage(),
          ),
          GoRoute(
            path: RouteNames.portfolio,
            builder: (_, _) => const PortfolioPage(),
          ),
          GoRoute(
            path: RouteNames.markets,
            builder: (_, _) => const MarketsPage(),
          ),
          GoRoute(
            path: RouteNames.goals,
            builder: (_, _) => const GoalsPage(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, _) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });

  return router;
});
