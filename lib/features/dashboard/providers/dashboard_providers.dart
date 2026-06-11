import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../models/project.dart';
import '../../../models/milestone.dart';
import '../../auth/providers/auth_providers.dart';

/// Provides a stream of projects for the currently logged in user
final dashboardProjectsProvider = StreamProvider<List<ProjectModel>>((ref) async* {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    yield [];
    return;
  }
  
  final repository = ref.watch(projectRepositoryProvider);
  yield* repository.streamProjectsForUser(uid);
});

/// Provides a stream of milestones relevant to the currently logged in user
final dashboardMilestonesProvider = StreamProvider<List<MilestoneModel>>((ref) async* {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    yield [];
    return;
  }
  
  // A hacky way for now to get the milestones
  // Ideally, we fetch the user's projects first, then query milestones.
  final projects = await ref.watch(dashboardProjectsProvider.future);
  final projectIds = projects.map((p) => p.id).toList();
  
  if (projectIds.isEmpty) {
    yield [];
    return;
  }
  
  final firestore = FirebaseFirestore.instance;
  // Firestore 'in' query supports up to 10 project IDs. 
  final chunks = <List<String>>[];
  for (var i = 0; i < projectIds.length; i += 10) {
    chunks.add(projectIds.sublist(i, i + 10 > projectIds.length ? projectIds.length : i + 10));
  }

  // To simplify for this demo, we'll just stream all milestones and filter locally.
  final stream = firestore.collection('milestones').snapshots().map((snapshot) {
    final allMilestones = snapshot.docs.map((doc) => MilestoneModel.fromJson(doc.data())).toList();
    return allMilestones.where((m) => projectIds.contains(m.projectId)).toList();
  });
  
  yield* stream;
});
