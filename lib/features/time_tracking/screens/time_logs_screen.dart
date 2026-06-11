import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_error_states.dart';

class TimeLogsScreen extends StatelessWidget {
  final String projectId;
  const TimeLogsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final logs = [
      {'date': '2026-05-28', 'desc': 'Design system integration', 'hours': '3.5h'},
      {'date': '2026-05-27', 'desc': 'API endpoint debugging', 'hours': '1.2h'},
      {'date': '2026-05-26', 'desc': 'Initial component scaffolding', 'hours': '4.0h'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Time Logs')),
      body: logs.isEmpty
          ? const EmptyState(title: 'No Time Logged', subtitle: 'Start tracking time on your tasks', icon: Icons.timer_off_outlined)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (_, i) {
                final log = logs[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(log['desc']!, style: AppTextStyles.titleSmall),
                  subtitle: Text(log['date']!, style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(log['hours']!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                );
              },
            ),
    );
  }
}
