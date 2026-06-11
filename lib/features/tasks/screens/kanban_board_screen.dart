import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/seed_data.dart';
import '../../../models/task.dart';

import '../providers/task_providers.dart';

class KanbanBoardScreen extends ConsumerStatefulWidget {
  final String projectId;

  const KanbanBoardScreen({super.key, required this.projectId});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen> {
  int _selectedCol = 0;
  final _pageCtrl = PageController();

  static const _columns = [
    (label: 'To Do', status: TaskStatus.todo),
    (label: 'In Progress', status: TaskStatus.inProgress),
    (label: 'In Review', status: TaskStatus.inReview),
    (label: 'Done', status: TaskStatus.done),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _showCreateTask() {
    context.push('/tasks/create', extra: widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(title: const Text('Kanban Board')),
      body: Column(
        children: [
          // Tab row
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: List.generate(_columns.length, (i) {
                final selected = _selectedCol == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCol = i);
                      _pageCtrl.animateToPage(i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderLight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _columns[i].label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondaryLight,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: tasksAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(message: e.toString()),
              data: (tasks) => PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _selectedCol = i),
                itemCount: _columns.length,
                itemBuilder: (_, colIdx) {
                  final col = _columns[colIdx];
                  final colTasks =
                      tasks.where((t) => t.status == col.status).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            Text(col.label, style: AppTextStyles.titleMedium),
                            const SizedBox(width: 8),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                colTasks.length.toString(),
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: colTasks.isEmpty
                            ? const EmptyState(
                                title: 'No tasks',
                                subtitle: 'Drop tasks here or create new ones',
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(12),
                                itemCount: colTasks.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, i) => TaskCard(
                                  task: colTasks[i],
                                  onTap: () =>
                                      context.push('/tasks/${colTasks[i].id}'),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
