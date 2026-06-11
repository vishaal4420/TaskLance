import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../models/task.dart';

/// Stream of tasks for a specific project
final projectTasksProvider = StreamProvider.family<List<TaskModel>, String>((ref, projectId) async* {
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.streamTasksForProject(projectId);
});

/// Stream of a single task detail
final taskDetailProvider = StreamProvider.family<TaskModel?, String>((ref, taskId) async* {
  final repo = ref.watch(taskRepositoryProvider);
  yield* repo.collection('tasks').doc(taskId).snapshots().map((doc) {
    if (doc.exists && doc.data() != null) {
      return TaskModel.fromJson(doc.data()!);
    }
    return null;
  });
});

/// Controller to update tasks
class TaskController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.updateTask(taskId, {'status': newStatus.name});
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleSubtask(TaskModel task, String subtaskId) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(taskRepositoryProvider);
      final newSubtasks = task.subtasks.map((s) {
        if (s.id == subtaskId) {
          return s.copyWith(isCompleted: !s.isCompleted);
        }
        return s;
      }).toList();
      
      await repo.updateTask(task.id, {'subtasks': newSubtasks.map((e) => e.toJson()).toList()});
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final taskControllerProvider = AsyncNotifierProvider<TaskController, void>(TaskController.new);
