import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import 'base_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

class TaskRepository extends BaseRepository {
  static const String _collectionName = 'tasks';

  /// Stream all tasks for a specific project
  Stream<List<TaskModel>> streamTasksForProject(String projectId) {
    return collection(_collectionName)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Stream all tasks for a specific milestone
  Stream<List<TaskModel>> streamTasksForMilestone(String milestoneId) {
    return collection(_collectionName)
        .where('milestoneId', isEqualTo: milestoneId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Create a new task
  Future<void> createTask(TaskModel task) async {
    await collection(_collectionName).doc(task.id).set(task.toJson());
  }

  /// Update an existing task
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    await collection(_collectionName).doc(taskId).update(updates);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    await collection(_collectionName).doc(taskId).delete();
  }
}
