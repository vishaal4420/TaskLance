import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.support_agent_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'How can we help you?',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _SupportTile(
            icon: Icons.article_outlined,
            title: 'FAQs',
            subtitle: 'Find answers to common questions',
            onTap: () => context.push('/profile/support/faqs'),
          ),
          const SizedBox(height: 12),
          _SupportTile(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@tasklance.com',
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'support@tasklance.com',
                queryParameters: {
                  'subject': 'TaskLance Support Request'
                },
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const _SupportTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      tileColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    );
  }
}
