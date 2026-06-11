import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../models/project.dart';
import '../../../models/milestone.dart';
import '../../../models/task.dart';

final openProjectsProvider = StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.streamOpenProjects();
});

final projectDetailProvider = StreamProvider.family<ProjectModel?, String>((ref, projectId) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.streamProject(projectId);
});

final projectMilestonesProvider = StreamProvider.family<List<MilestoneModel>, String>((ref, projectId) {
  final repository = ref.watch(milestoneRepositoryProvider);
  return repository.streamMilestonesForProject(projectId);
});

final projectTasksProvider = StreamProvider.family<List<TaskModel>, String>((ref, projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.streamTasksForProject(projectId);
});

final milestoneTasksProvider = StreamProvider.family<List<TaskModel>, String>((ref, milestoneId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.streamTasksForMilestone(milestoneId);
});

final milestoneDetailProvider = StreamProvider.family<MilestoneModel?, String>((ref, milestoneId) {
  final repository = ref.watch(milestoneRepositoryProvider);
  return repository.streamMilestone(milestoneId);
});
