import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/task_draggable_card.dart';
import '../../../models/task.dart';
import '../providers/task_providers.dart';

class KanbanBoardScreen extends ConsumerStatefulWidget {
  final String projectId;

  const KanbanBoardScreen({super.key, required this.projectId});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen> {
  static const _columns = [
    (label: 'Backlog', status: TaskStatus.todo),
    (label: 'In Progress', status: TaskStatus.inProgress),
    (label: 'Review', status: TaskStatus.inReview),
    (label: 'Done', status: TaskStatus.done),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Task Tracker'),
            Text('Manage your tasks via Kanban board.', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (tasks) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: _columns.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final col = _columns[index];
              final colTasks = tasks.where((t) => t.status == col.status).toList();

              return SizedBox(
                width: 300,
                child: DragTarget<TaskModel>(
                  onAcceptWithDetails: (details) {
                    final task = details.data;
                    if (task.status != col.status) {
                      ref.read(taskControllerProvider.notifier).updateTaskStatus(task.id, col.status);
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHovering ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: isHovering ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(col.label, style: AppTextStyles.titleMedium),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    colTasks.length.toString(),
                                    style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 1),

                          // Tasks List
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: colTasks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) => TaskDraggableCard(
                                task: colTasks[i],
                                onTap: () => context.push('/tasks/${colTasks[i].id}'),
                              ),
                            ),
                          ),

                          // Footer Add Button
                          const Divider(height: 1, thickness: 1),
                          InkWell(
                            onTap: () {
                              context.push('/tasks/create', extra: widget.projectId);
                            },
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, size: 16, color: AppColors.textSecondaryLight),
                                  const SizedBox(width: 8),
                                  Text('Add Task', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
