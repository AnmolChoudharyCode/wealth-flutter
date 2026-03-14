import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';

class UserAvatar extends ConsumerWidget {
  final double size;

  const UserAvatar({this.size = 34, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final initials = user?.initials ?? '?';
    final avatarUrl = user?.avatarUrl;

    return GestureDetector(
      onTap: () => context.go(RouteNames.profile),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: avatarUrl == null
              ? const LinearGradient(
                  colors: [AppColors.darkPurple, AppColors.rose],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          image: avatarUrl != null
              ? DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: avatarUrl == null
            ? Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Compact badge-style avatar used in tight spaces
class UserAvatarCompact extends UserAvatar {
  const UserAvatarCompact({super.key}) : super(size: AppSpacing.xl - 4);
}
