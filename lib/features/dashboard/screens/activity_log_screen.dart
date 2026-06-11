import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'user': 'Client', 'action': 'viewed Invoice #001', 'time': '2 hrs ago'},
      {'user': 'You', 'action': 'uploaded Deliverable v2', 'time': '5 hrs ago'},
      {'user': 'Client', 'action': 'approved Milestone 1', 'time': '1 day ago'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, i) {
          final a = activities[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.history, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          children: [
                            TextSpan(text: '${a['user']} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: a['action']),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(a['time']!, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    ],
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
