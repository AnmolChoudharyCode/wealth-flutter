import 'package:flutter/material.dart';
import '../../../core/config/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'notification_bell.dart';
import 'user_avatar.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const CommonAppBar({this.title, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.dark : AppColors.lightBg;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final isDesktop = MediaQuery.of(context).size.width >= AppBreakpoints.sidebar;

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Row(
            children: [
              // On mobile, show logo; on desktop the sidebar has it
              if (!isDesktop) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.darkPurple, AppColors.rose],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('Wealth', style: AppTextStyles.headingSm),
              ],
              if (title != null && isDesktop) ...[
                Text(title!, style: AppTextStyles.headingMd),
              ],
              const Spacer(),
              const NotificationBell(),
              const SizedBox(width: AppSpacing.xs),
              const UserAvatar(),
            ],
          ),
        ),
      ),
    );
  }
}
