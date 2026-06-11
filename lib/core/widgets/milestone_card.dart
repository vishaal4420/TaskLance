import 'package:flutter/material.dart';
import '../../models/milestone.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/date_formatter.dart';
import '../utils/currency_formatter.dart';
import 'status_chip.dart';

class MilestoneCard extends StatelessWidget {
  final MilestoneModel milestone;
  final VoidCallback? onTap;

  const MilestoneCard({super.key, required this.milestone, this.onTap});

  Color get _statusColor {
    switch (milestone.status) {
      case MilestoneStatus.approved:
        return AppColors.secondary;
      case MilestoneStatus.inProgress:
        return AppColors.primary;
      case MilestoneStatus.review:
        return AppColors.info;
      case MilestoneStatus.revision:
        return AppColors.warning;
      case MilestoneStatus.overdue:
        return AppColors.error;
      case MilestoneStatus.upcoming:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final progress = milestone.progressPercent;
    final isOverdue = milestone.isOverdue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue
                ? AppColors.error.withOpacity(0.3)
                : border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    milestone.title,
                    style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip.fromMilestoneStatus(milestone.status, small: true),
              ],
            ),
            if (milestone.description != null &&
                milestone.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                milestone.description!,
                style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${milestone.completedTasks}/${milestone.totalTasks} tasks',
                      style: AppTextStyles.labelSmall.copyWith(color: textSecondary),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: _statusColor.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: isOverdue ? AppColors.error : textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due ${DateFormatter.format(milestone.dueDate)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isOverdue ? AppColors.error : textSecondary,
                    fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Icon(Icons.attach_money_rounded, size: 12, color: textSecondary),
                Text(
                  CurrencyFormatter.format(milestone.value),
                  style: AppTextStyles.labelSmall.copyWith(color: textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
