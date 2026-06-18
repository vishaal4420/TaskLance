import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  final bool _darkTheme = false;

  Future<void> _updateNotificationPreference(String field, bool value, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        field: value,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Get alerts on your device'),
            value: user?.pushNotifs ?? true,
            onChanged: (v) {
              if (user != null) _updateNotificationPreference('pushNotifs', v, user.uid);
            },
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive daily summaries'),
            value: user?.emailNotifs ?? true,
            onChanged: (v) {
              if (user != null) _updateNotificationPreference('emailNotifs', v, user.uid);
            },
            activeThumbColor: AppColors.primary,
          ),
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Toggle dark mode'),
            value: isDark,
            onChanged: (v) {
              ref.read(themeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light;
            },
            activeThumbColor: AppColors.primary,
          ),
          _SectionHeader(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/change-password'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Two-Factor Authentication'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/2fa'),
          ),
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Uri(path: '/settings/legal', queryParameters: {'title': 'Terms of Service'}).toString()),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Uri(path: '/settings/legal', queryParameters: {'title': 'Privacy Policy'}).toString()),
          ),
          const SizedBox(height: 40),
          Center(
            child: TextButton.icon(
              onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
