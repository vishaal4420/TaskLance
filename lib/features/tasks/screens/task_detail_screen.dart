import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../providers/task_providers.dart';
import '../../projects/providers/project_providers.dart';
import '../../../models/task.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return taskAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(count: 4, itemHeight: 80),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(message: e.toString()),
      ),
      data: (task) {
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorState(message: 'Task not found'),
          );
        }

        final projectAsync = ref.watch(projectDetailProvider(task.projectId));
        final project = projectAsync.valueOrNull;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Detail'),
            actions: [
              IconButton(
                icon: const Icon(Icons.timer_outlined),
                onPressed: () => context.push('/time-tracker/$taskId'),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () { context.push('/tasks/create'); },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(task.title, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 12),
                // Breadcrumb
                Row(
                  children: [
                    if (project != null)
                      _Chip(label: project.title, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, size: 16, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    const SizedBox(width: 8),
                    _Chip(label: 'Backend API', color: AppColors.secondary),
                  ],
                ),
                const SizedBox(height: 16),
                // Info grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                  children: [
                    _InfoTile(
                      label: 'Status',
                      child: PopupMenuButton<TaskStatus>(
                        initialValue: task.status,
                        tooltip: 'Change Status',
                        child: StatusChip.fromTaskStatus(task.status, small: true),
                        onSelected: (newStatus) {
                          ref.read(taskControllerProvider.notifier).updateTaskStatus(task.id, newStatus);
                        },
                        itemBuilder: (context) => TaskStatus.values.map((s) {
                          return PopupMenuItem<TaskStatus>(
                            value: s,
                            child: Row(
                              children: [
                                StatusChip.fromTaskStatus(s, small: true),
                                if (s == task.status)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Icon(Icons.check, size: 16),
                                  )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    _InfoTile(label: 'Priority', child: _PriorityPill(task.priority)),
                    _InfoTile(
                      label: 'Due Date',
                      child: task.dueDate == null
                          ? const Text('No date')
                          : Text('${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                              style: AppTextStyles.bodySmall),
                    ),
                    _InfoTile(
                      label: 'Assignee',
                      child: task.assigneeName == null
                          ? const Text('Unassigned')
                          : Row(children: [
                              AvatarWidget(name: task.assigneeName!, size: 22),
                              const SizedBox(width: 4),
                              Flexible(child: Text(task.assigneeName!, style: AppTextStyles.labelSmall, overflow: TextOverflow.ellipsis)),
                            ]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                _SectionCard(
                  title: 'Description',
                  child: Text(
                    task.description ?? 'No description provided.',
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  ),
                ),
                const SizedBox(height: 16),
                // Subtasks
                if (task.subtasks.isNotEmpty)
                  _SectionCard(
                    title: 'Subtasks',
                    child: Column(
                      children: task.subtasks.map((st) {
                        return CheckboxListTile(
                          value: st.isCompleted,
                          onChanged: (_) {
                            ref.read(taskControllerProvider.notifier).toggleSubtask(task, st.id);
                          },
                          title: Text(
                            st.title,
                            style: TextStyle(
                              decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                              color: st.isCompleted ? AppColors.textSecondaryLight : null,
                            ),
                          ),
                          dense: true,
                        );
                      }).toList(),
                    ),
                  ),
                if (task.subtasks.isNotEmpty) const SizedBox(height: 16),
                // Activity
                if (task.activities.isNotEmpty)
                  _SectionCard(
                    title: 'Activity',
                    child: Column(
                      children: task.activities.map((a) {
                        // Very simple formatting
                        final diff = DateTime.now().difference(a.timestamp);
                        String timeStr;
                        if (diff.inDays > 0) {
                          timeStr = '${diff.inDays}d ago';
                        } else if (diff.inHours > 0) {
                          timeStr = '${diff.inHours}h ago';
                        } else if (diff.inMinutes > 0) {
                          timeStr = '${diff.inMinutes}m ago';
                        } else {
                          timeStr = 'Just now';
                        }
                        
                        return _ActivityItem(
                          text: a.text,
                          time: timeStr,
                          icon: Icons.history, // Simplification: could map string to icon
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final Widget child;

  const _InfoTile({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityPill(this.priority);

  @override
  Widget build(BuildContext context) {
    final color = priority == TaskPriority.high
        ? AppColors.error
        : priority == TaskPriority.medium
            ? AppColors.warning
            : AppColors.secondary;
    final label = priority.name[0].toUpperCase() + priority.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String text;
  final String time;
  final IconData icon;

  const _ActivityItem({required this.text, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
          Text(time, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}
