import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;

  const LegalDocumentScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: May 30, 2026',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '1. Introduction',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to TaskLance. By accessing our platform, you agree to these terms. Please read them carefully. We provide a platform connecting freelancers with clients looking to manage their projects efficiently and securely.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),
            Text(
              '2. User Accounts',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'You must be 18 years or older to use this service. You are responsible for safeguarding the password that you use to access the service and for any activities or actions under your password, whether your password is with our service or a third-party service.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),
            Text(
              '3. Payments and Billing',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'All payments made through the platform are processed securely. We act as a payment facilitator and hold funds in escrow when required. Disputes must be resolved through our official arbitration process.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'End of Document',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
