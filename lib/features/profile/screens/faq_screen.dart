import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> faqs = [
      {
        'q': 'How do I get paid for a project?',
        'a': 'Clients deposit funds into escrow when a contract starts or a milestone is approved. Once you submit the deliverable and the client approves it, the funds are immediately released to your TaskLance balance, which you can withdraw to your bank account.'
      },
      {
        'q': 'What is the platform fee?',
        'a': 'TaskLance charges a flat 10% platform fee on all completed milestones. This covers escrow services, dispute resolution, and platform maintenance.'
      },
      {
        'q': 'How do I dispute a contract?',
        'a': 'If you cannot reach an agreement with your client or freelancer, you can open a dispute from the Contract details page. Our support team will review the communications and deliverables to make a fair, binding decision.'
      },
      {
        'q': 'Can I change my hourly rate?',
        'a': 'Yes, you can update your hourly rate at any time from your Profile settings. Note that this will only affect future contracts; existing contracts will remain at the agreed-upon rate.'
      },
      {
        'q': 'How does time tracking work?',
        'a': 'You can use the built-in Time Tracker from the active tasks page. It automatically logs time against the specific task and project, and generates a timesheet for your client.'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Frequently Asked Questions')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: ExpansionTile(
              title: Text(
                faq['q']!,
                style: AppTextStyles.titleMedium,
              ),
              iconColor: AppColors.primary,
              collapsedIconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(
                  faq['a']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
