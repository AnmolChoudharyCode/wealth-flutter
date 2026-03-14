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

/// Slide-from-right transition for full-screen push routes.
Page<void> _slidePage(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, _, child) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

/// Fade transition for shell tab routes (no slide overlap).
Page<void> _fadePage(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

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
        pageBuilder: (_, s) => _fadePage(const SplashPage(), s),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (_, s) => _slidePage(const LoginPage(), s),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (_, s) => _slidePage(const RegisterPage(), s),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (_, s) => _slidePage(const ForgotPasswordPage(), s),
      ),
      // ── Full-screen authenticated routes (no shell) ───────────────────────
      GoRoute(
        path: RouteNames.setGoal,
        pageBuilder: (_, s) => _slidePage(const SetGoalPage(), s),
      ),
      // ── Authenticated routes (wrapped in AppShell) ────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder: (_, s) => _fadePage(const DashboardPage(), s),
          ),
          GoRoute(
            path: RouteNames.portfolio,
            pageBuilder: (_, s) => _fadePage(const PortfolioPage(), s),
          ),
          GoRoute(
            path: RouteNames.markets,
            pageBuilder: (_, s) => _fadePage(const MarketsPage(), s),
          ),
          GoRoute(
            path: RouteNames.goals,
            pageBuilder: (_, s) => _fadePage(const GoalsPage(), s),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (_, s) => _fadePage(const ProfilePage(), s),
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
