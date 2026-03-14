import 'package:flutter/material.dart';
import '../../../core/config/breakpoints.dart';
import '../app_bar/common_app_bar.dart';
import '../app_bar/notification_panel.dart';
import 'bottom_nav_bar.dart';
import 'more_menu_panel.dart';
import 'sidebar_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.sidebar;
        return isDesktop
            ? _DesktopShell(child: child)
            : _MobileShell(child: child);
      },
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final Widget child;

  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarNav(),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Column(
              children: [
                const CommonAppBar(),
                Expanded(
                  child: Stack(
                    children: [
                      child,
                      const NotificationOverlay(),
                      const MoreMenuOverlay(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  final Widget child;

  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Stack(
        children: [
          child,
          const NotificationOverlay(),
          const MoreMenuOverlay(),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}
