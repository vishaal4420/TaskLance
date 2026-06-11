import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_error_states.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = [
      {'id': 'e1', 'title': 'Domain Registration', 'amount': '\$15.00', 'date': 'May 28', 'category': 'Software'},
      {'id': 'e2', 'title': 'Figma Subscription', 'amount': '\$12.00', 'date': 'May 14', 'category': 'Design'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
      body: expenses.isEmpty
          ? const EmptyState(title: 'No Expenses', subtitle: 'Track your project-related expenses here.', icon: Icons.receipt_long)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final e = expenses[i];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return ListTile(
                  tileColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                  leading: CircleAvatar(backgroundColor: AppColors.error.withOpacity(0.1), child: const Icon(Icons.receipt, color: AppColors.error)),
                  title: Text(e['title']!, style: AppTextStyles.titleMedium),
                  subtitle: Text('${e['date']} • ${e['category']}', style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  trailing: Text(e['amount']!, style: AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
                );
              },
            ),
    );
  }
}
