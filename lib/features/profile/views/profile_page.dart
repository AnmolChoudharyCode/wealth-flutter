import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/empty_states/error_state_widget.dart';
import '../../../shared/widgets/loaders/shimmer_box.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const _ProfileShimmer(),
      error: (err, _) => ErrorStateWidget(message: err.toString()),
      data: (profile) => _ProfileContent(profile: profile),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserProfile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        _ProfileHeader(profile: profile),
        const SizedBox(height: AppSpacing.sectionGap),
        _SettingsSection(
          title: 'Account',
          tiles: [
            _SettingsTile(
              icon: Icons.person_outline,
              label: 'Full Name',
              value: profile.name,
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: profile.email,
            ),
            if (profile.phone != null)
              _SettingsTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: profile.phone!,
              ),
            if (profile.country != null)
              _SettingsTile(
                icon: Icons.public_outlined,
                label: 'Country',
                value: profile.country!,
              ),
            if (profile.joinedAt != null)
              _SettingsTile(
                icon: Icons.calendar_today_outlined,
                label: 'Member Since',
                value: DateFormatter.long(profile.joinedAt!),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        _SettingsSection(
          title: 'Appearance',
          tiles: [
            _ThemeToggleTile(themeMode: themeMode),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        _SettingsSection(
          title: 'Notifications',
          tiles: [
            _SwitchTile(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              value: true,
              onChanged: (_) {},
            ),
            _SwitchTile(
              icon: Icons.email_outlined,
              label: 'Email Alerts',
              value: false,
              onChanged: (_) {},
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        _SettingsSection(
          title: 'Security',
          tiles: [
            _SettingsTile(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.fingerprint,
              label: 'Biometric Login',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Card(
          child: InkWell(
            onTap: () => ref.read(authProvider.notifier).logout(),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppColors.negative, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Sign Out',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.negative,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.darkPurple, AppColors.rose],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              profile.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(profile.name, style: AppTextStyles.headingMd),
        Text(
          profile.email,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _SettingsSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.2),
          ),
        ),
        Card(
          child: Column(
            children: tiles.asMap().entries.map((entry) {
              return Column(
                children: [
                  entry.value,
                  if (entry.key < tiles.length - 1)
                    const Divider(height: 1, indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkPurple, size: 20),
      title: Text(label, style: AppTextStyles.bodyMd),
      trailing: value != null
          ? Text(value!, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary))
          : onTap != null
              ? const Icon(Icons.chevron_right, size: 20)
              : null,
      onTap: onTap,
      dense: true,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkPurple, size: 20),
      title: Text(label, style: AppTextStyles.bodyMd),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.darkPurple,
      ),
      dense: true,
    );
  }
}

class _ThemeToggleTile extends ConsumerWidget {
  final ThemeMode themeMode;

  const _ThemeToggleTile({required this.themeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined, color: AppColors.darkPurple, size: 20),
      title: const Text('Theme', style: AppTextStyles.bodyMd),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 16)),
          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
        ],
        selected: {themeMode},
        onSelectionChanged: (modes) =>
            ref.read(themeModeProvider.notifier).setMode(modes.first),
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      dense: true,
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Center(
          child: ShimmerBox(width: 80, height: 80, borderRadius: 40),
        ),
        const SizedBox(height: 12),
        Center(child: ShimmerBox(width: 140, height: 20)),
        const SizedBox(height: 6),
        Center(child: ShimmerBox(width: 180, height: 16)),
        const SizedBox(height: AppSpacing.sectionGap),
        ShimmerBox(width: double.infinity, height: 200),
      ],
    );
  }
}
