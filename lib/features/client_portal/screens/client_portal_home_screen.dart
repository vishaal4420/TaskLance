import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ClientPortalHomeScreen extends StatelessWidget {
  const ClientPortalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Portal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_customize_rounded, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Welcome to the Client Portal', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('Manage your projects and invoices here.', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
