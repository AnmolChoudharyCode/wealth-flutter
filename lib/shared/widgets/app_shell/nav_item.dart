import 'package:flutter/material.dart';
import '../../../core/router/route_names.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Single source of truth for all navigation items
const List<NavItem> kNavItems = [
  NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    route: RouteNames.dashboard,
  ),
  NavItem(
    label: 'Portfolio',
    icon: Icons.pie_chart_outline,
    activeIcon: Icons.pie_chart,
    route: RouteNames.portfolio,
  ),
  NavItem(
    label: 'Markets',
    icon: Icons.trending_up_outlined,
    activeIcon: Icons.trending_up,
    route: RouteNames.markets,
  ),
  NavItem(
    label: 'My Goals',
    icon: Icons.flag_outlined,
    activeIcon: Icons.flag,
    route: RouteNames.goals,
  ),
];
