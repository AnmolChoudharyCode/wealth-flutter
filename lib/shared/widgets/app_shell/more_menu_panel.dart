import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/more_menu_provider.dart';

class MoreMenuOverlay extends ConsumerStatefulWidget {
  const MoreMenuOverlay({super.key});

  @override
  ConsumerState<MoreMenuOverlay> createState() => _MoreMenuOverlayState();
}

class _MoreMenuOverlayState extends ConsumerState<MoreMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() =>
      ref.read(moreMenuOpenProvider.notifier).state = false;

  @override
  Widget build(BuildContext context) {
    final isOpen = ref.watch(moreMenuOpenProvider);

    if (isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isDismissed) return const SizedBox.shrink();

        return Stack(
          children: [
            // Backdrop — tap to close
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withAlpha(50),
                ),
              ),
            ),
            // Panel — slides up from bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: GestureDetector(
                  onTap: () {},
                  child: _MoreMenuPanel(onClose: _close),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MoreMenuPanel extends StatelessWidget {
  final VoidCallback onClose;

  const _MoreMenuPanel({required this.onClose});

  static const _items = [
    _MenuItem(icon: Icons.receipt_long_outlined, label: 'Transactions'),
    _MenuItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
    _MenuItem(icon: Icons.calculate_outlined, label: 'Calculator'),
    _MenuItem(icon: Icons.settings_outlined, label: 'Settings'),
    _MenuItem(icon: Icons.help_outline, label: 'Help'),
    _MenuItem(icon: Icons.info_outline, label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.cardDark : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.borderRadiusLg),
          topRight: Radius.circular(AppSpacing.borderRadiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Text('More', style: AppTextStyles.headingSm),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.0,
              children: _items
                  .map((item) => _MenuGridItem(item: item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});
}

class _MenuGridItem extends StatelessWidget {
  final _MenuItem item;

  const _MenuGridItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.lightBg;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: AppColors.darkPurple, size: 26),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
