import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'status_chip.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.open:
        return AppColors.info;
      case ProjectStatus.active:
        return AppColors.primary;
      case ProjectStatus.completed:
        return AppColors.secondary;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.archived:
        return AppColors.statusDraft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor = _statusColor(project.status);
    final progress = project.progressPercent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header accent strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: AppTextStyles.titleLarge.copyWith(color: textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip.fromProjectStatus(project.status, small: true),
                    ],
                  ),
                  if (project.clientName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      project.clientName!,
                      style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${project.completedMilestones}/${project.totalMilestones} milestones',
                                  style: AppTextStyles.labelSmall.copyWith(color: textSecondary),
                                ),
                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: accentColor,
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
                                backgroundColor: accentColor.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Footer: budget + deadline
                  Row(
                    children: [
                      Icon(Icons.attach_money_rounded, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 2),
                      Text(
                        CurrencyFormatter.format(project.budget),
                        style: AppTextStyles.labelMedium.copyWith(color: textSecondary),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today_outlined, size: 12, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.format(project.endDate),
                        style: AppTextStyles.labelSmall.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
