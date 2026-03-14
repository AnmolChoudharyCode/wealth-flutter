import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/providers/auth_provider.dart';
import 'nav_item.dart';

class SidebarNav extends ConsumerWidget {
  const SidebarNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final isWide = MediaQuery.of(context).size.width >= AppBreakpoints.wide;
    final sidebarWidth = isWide ? 240.0 : 72.0;

    return Container(
      width: sidebarWidth,
      color: AppColors.dark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SidebarLogo(isExpanded: isWide),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: kNavItems.map((item) {
                  final isActive = location.startsWith(item.route);
                  return _SidebarItem(
                    item: item,
                    isActive: isActive,
                    showLabel: isWide,
                    onTap: () => context.go(item.route),
                  );
                }).toList(),
              ),
            ),
            _SidebarLogout(isExpanded: isWide, ref: ref),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _SidebarLogo extends StatelessWidget {
  final bool isExpanded;

  const _SidebarLogo({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: isExpanded
          ? Row(
              children: [
                _LogoIcon(),
                const SizedBox(width: AppSpacing.sm + 4),
                const Text('Wealth', style: AppTextStyles.logoText),
              ],
            )
          : Center(child: _LogoIcon()),
    );
  }
}

class _LogoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPurple, AppColors.rose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        Icons.account_balance_wallet,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final bool showLabel;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive
        ? Colors.white
        : AppColors.textOnDarkMuted;
    final bgColor = isActive
        ? AppColors.darkPurple
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? AppSpacing.md : AppSpacing.sm,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          ),
          child: Row(
            mainAxisAlignment: showLabel
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: iconColor,
                size: 22,
              ),
              if (showLabel) ...[
                const SizedBox(width: AppSpacing.md - 4),
                Text(
                  item.label,
                  style: AppTextStyles.sidebarLabel.copyWith(
                    color: iconColor,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarLogout extends StatelessWidget {
  final bool isExpanded;
  final WidgetRef ref;

  const _SidebarLogout({required this.isExpanded, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: InkWell(
        onTap: () => ref.read(authProvider.notifier).logout(),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? AppSpacing.md : AppSpacing.sm,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_outlined,
                color: AppColors.textOnDarkMuted,
                size: 22,
              ),
              if (isExpanded) ...[
                const SizedBox(width: AppSpacing.md - 4),
                Text(
                  'Sign Out',
                  style: AppTextStyles.sidebarLabel.copyWith(
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
