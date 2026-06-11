import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/milestone_card.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../models/milestone.dart';
import '../../../models/project.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../projects/providers/project_providers.dart';

class MilestoneListScreen extends ConsumerWidget {
  final String projectId;

  const MilestoneListScreen({super.key, required this.projectId});

  ProjectModel? _project(WidgetRef ref) {
    return ref.watch(projectDetailProvider(projectId)).valueOrNull;
  }

  Color _nodeColor(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.approved:
        return AppColors.secondary;
      case MilestoneStatus.inProgress:
        return AppColors.primary;
      case MilestoneStatus.review:
        return AppColors.info;
      case MilestoneStatus.overdue:
        return AppColors.error;
      case MilestoneStatus.revision:
        return AppColors.warning;
      case MilestoneStatus.upcoming:
        return AppColors.textSecondaryLight;
    }
  }

  void _showCreateSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    DateTime? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Milestone', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Value (\$)', border: OutlineInputBorder(), prefixText: '\$'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 14)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) setS(() => dueDate = picked);
                },
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(dueDate == null
                    ? 'Select Due Date'
                    : 'Due: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  AppSnackBar.success(context, 'Milestone created!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Create Milestone'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesAsync = ref.watch(projectMilestonesProvider(projectId));
    final project = _project(ref);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Milestones'),
            if (project != null)
              Text(project.title,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ],
        ),
      ),
      floatingActionButton: ref.watch(currentUserRoleProvider) == UserRole.client
          ? FloatingActionButton(
              onPressed: () => _showCreateSheet(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: milestonesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(count: 3, itemHeight: 120),
        ),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (milestones) {
          if (milestones.isEmpty) {
            return EmptyState(
              title: 'No Milestones',
              subtitle: 'Break your project into milestones to track progress',
              lottieAsset: 'assets/lottie/no_milestones.json',
              actionLabel: 'Add Milestone',
              onAction: () => _showCreateSheet(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: milestones.length,
            itemBuilder: (_, i) {
              final m = milestones[i];
              final nodeColor = _nodeColor(m.status);
              final isLast = i == milestones.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: nodeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: nodeColor.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MilestoneCard(
                          milestone: m,
                          onTap: () =>
                              context.push('/milestones/${m.id}'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
