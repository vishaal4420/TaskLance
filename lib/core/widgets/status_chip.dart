import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/invoice.dart';
import '../../models/milestone.dart';
import '../../models/project.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool small;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.small = false,
  });

  factory StatusChip.fromTaskStatus(TaskStatus status, {bool small = false}) {
    return switch (status) {
      TaskStatus.todo => StatusChip(label: 'To Do', color: AppColors.statusDraft, small: small),
      TaskStatus.inProgress => StatusChip(label: 'In Progress', color: AppColors.statusActive, small: small),
      TaskStatus.inReview => StatusChip(label: 'In Review', color: AppColors.statusReview, small: small),
      TaskStatus.done => StatusChip(label: 'Done', color: AppColors.statusCompleted, small: small),
    };
  }

  factory StatusChip.fromMilestoneStatus(MilestoneStatus status, {bool small = false}) {
    return switch (status) {
      MilestoneStatus.upcoming => StatusChip(label: 'Upcoming', color: AppColors.statusDraft, small: small),
      MilestoneStatus.inProgress => StatusChip(label: 'In Progress', color: AppColors.statusActive, small: small),
      MilestoneStatus.review => StatusChip(label: 'Pending Review', color: AppColors.statusReview, small: small),
      MilestoneStatus.approved => StatusChip(label: 'Approved', color: AppColors.statusCompleted, small: small),
      MilestoneStatus.revision => StatusChip(label: 'Revision', color: AppColors.warning, small: small),
      MilestoneStatus.overdue => StatusChip(label: 'Overdue', color: AppColors.statusOverdue, small: small),
    };
  }

  factory StatusChip.fromProjectStatus(ProjectStatus status, {bool small = false}) {
    return switch (status) {
      ProjectStatus.open => StatusChip(label: 'Open', color: AppColors.info, small: small),
      ProjectStatus.active => StatusChip(label: 'Active', color: AppColors.statusActive, small: small),
      ProjectStatus.completed => StatusChip(label: 'Completed', color: AppColors.statusCompleted, small: small),
      ProjectStatus.onHold => StatusChip(label: 'On Hold', color: AppColors.warning, small: small),
      ProjectStatus.archived => StatusChip(label: 'Archived', color: AppColors.statusDraft, small: small),
    };
  }

  factory StatusChip.fromInvoiceStatus(InvoiceStatus status, {bool small = false}) {
    return switch (status) {
      InvoiceStatus.draft => StatusChip(label: 'Draft', color: AppColors.statusDraft, small: small),
      InvoiceStatus.sent => StatusChip(label: 'Sent', color: AppColors.statusReview, small: small),
      InvoiceStatus.viewed => StatusChip(label: 'Viewed', color: AppColors.info, small: small),
      InvoiceStatus.paid => StatusChip(label: 'Paid', color: AppColors.statusCompleted, small: small),
      InvoiceStatus.overdue => StatusChip(label: 'Overdue', color: AppColors.statusOverdue, small: small),
      InvoiceStatus.voided => StatusChip(label: 'Voided', color: AppColors.statusDraft, small: small),
    };
  }

  factory StatusChip.fromString(String status, {bool small = false}) {
    return switch (status.toLowerCase()) {
      'open' => StatusChip(label: 'Open', color: AppColors.info, small: small),
      'approved' => StatusChip(label: 'Approved', color: AppColors.statusCompleted, small: small),
      'review' => StatusChip(label: 'In Review', color: AppColors.statusReview, small: small),
      'revision' => StatusChip(label: 'Revision', color: AppColors.warning, small: small),
      'pending' => StatusChip(label: 'Pending', color: AppColors.statusDraft, small: small),
      'paid' => StatusChip(label: 'Paid', color: AppColors.statusCompleted, small: small),
      'active' => StatusChip(label: 'Active', color: AppColors.statusActive, small: small),
      'completed' => StatusChip(label: 'Completed', color: AppColors.statusCompleted, small: small),
      'overdue' => StatusChip(label: 'Overdue', color: AppColors.statusOverdue, small: small),
      _ => StatusChip(label: status, color: AppColors.statusDraft, small: small),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(0.12);
    final fg = textColor ?? color;
    final fontSize = small ? 11.0 : 12.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
