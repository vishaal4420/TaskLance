import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../models/milestone.dart';

final projectMilestonesProvider = StreamProvider.family<List<MilestoneModel>, String>((ref, projectId) async* {
  final repo = ref.watch(milestoneRepositoryProvider);
  yield* repo.streamMilestonesForProject(projectId);
});

final singleMilestoneProvider = StreamProvider.family<MilestoneModel?, String>((ref, milestoneId) async* {
  final repo = ref.watch(milestoneRepositoryProvider);
  yield* repo.streamMilestone(milestoneId);
});

final milestoneDeliverablesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, milestoneId) async* {
  yield* FirebaseFirestore.instance
      .collection('deliverables')
      .where('milestoneId', isEqualTo: milestoneId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
