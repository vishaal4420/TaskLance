import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upgrade to Premium', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.primary),
              title: Text('Unlimited Projects'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.primary),
              title: Text('Priority Support'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.primary),
              title: Text('Advanced Analytics'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  AppSnackBar.success(context, 'Plan upgraded successfully!');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Confirm \$29.00 / month'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Payment Method', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '0000 0000 0000 0000',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: const TextField(
                    decoration: InputDecoration(labelText: 'Expiry Date', hintText: 'MM/YY'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: const TextField(
                    decoration: InputDecoration(labelText: 'CVC', hintText: '123'),
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  AppSnackBar.success(context, 'Card added successfully');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Save Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Billing & Plans')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Plan', style: AppTextStyles.labelMedium.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text('Freelancer Pro', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                const SizedBox(height: 16),
                Text('\$15.00 / month', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showUpgradeSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Manage Subscription'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Payment Methods', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.credit_card, color: AppColors.primary),
            title: const Text('Visa ending in 4242'),
            subtitle: const Text('Expires 12/28'),
            trailing: const Text('Default', style: TextStyle(color: AppColors.secondary)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showAddPaymentSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
          ),
        ],
      ),
    );
  }
}
