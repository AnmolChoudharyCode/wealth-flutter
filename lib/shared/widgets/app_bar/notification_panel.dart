import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/notification_panel_provider.dart';

class NotificationOverlay extends ConsumerStatefulWidget {
  const NotificationOverlay({super.key});

  @override
  ConsumerState<NotificationOverlay> createState() =>
      _NotificationOverlayState();
}

class _NotificationOverlayState extends ConsumerState<NotificationOverlay>
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
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
      ref.read(notificationPanelOpenProvider.notifier).state = false;

  @override
  Widget build(BuildContext context) {
    final isOpen = ref.watch(notificationPanelOpenProvider);

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
            // Panel — slides in from top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: GestureDetector(
                  onTap: () {},
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) < -300) _close();
                  },
                  child: _NotificationPanel(onClose: _close),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  final VoidCallback onClose;

  const _NotificationPanel({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.cardDark : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.borderRadiusLg),
          bottomRight: Radius.circular(AppSpacing.borderRadiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text('Notifications', style: AppTextStyles.headingSm),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          // Empty state
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Column(
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 40,
                  color: AppColors.textSecondary.withAlpha(120),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No notifications',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Swipe hint
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Swipe up to close',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary.withAlpha(120),
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
