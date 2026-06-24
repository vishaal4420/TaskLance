import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    // Status colors mapping
    Color statusBgColor;
    Color statusTextColor;
    String statusText = project.status.name.toUpperCase();
    
    switch (project.status) {
      case ProjectStatus.active:
        statusBgColor = AppColors.primary.withOpacity(0.1);
        statusTextColor = AppColors.primary;
        statusText = 'IN PROGRESS';
        break;
      case ProjectStatus.open:
        statusBgColor = AppColors.success.withOpacity(0.1);
        statusTextColor = AppColors.success;
        statusText = 'OPEN';
        break;
      default:
        statusBgColor = isDark ? AppColors.borderDark : AppColors.borderLight;
        statusTextColor = textSecondary;
        statusText = project.status.name.toUpperCase();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
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
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.category,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              project.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Meta Row
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  '${project.pricingType == PricingType.fixedPrice ? 'Fixed Price' : 'Hourly Rate'} Budget: \$${project.budget.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  'Due ${DateFormat('MMM dd, yyyy').format(project.endDate)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            if (project.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Skills Needed:',
                style: AppTextStyles.labelMedium.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: project.skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      skill,
                      style: AppTextStyles.labelSmall.copyWith(color: textSecondary),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
