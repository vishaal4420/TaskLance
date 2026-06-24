import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/seed_data.dart';
import '../../../models/project.dart';
import '../../../models/milestone.dart';
import '../../../models/invoice.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/providers/auth_providers.dart';

final clientProjectsProvider = StreamProvider<List<ProjectModel>>((ref) async* {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    yield [];
    return;
  }
  
  yield* FirebaseFirestore.instance
      .collection('projects')
      .where('clientUid', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ProjectModel.fromJson(data);
          }).toList());
});

final clientPendingMilestonesProvider = StreamProvider<List<MilestoneModel>>((ref) async* {
  // A comprehensive query requires filtering by project IDs or joining.
  // For a client, we could fetch their projects first, then query milestones.
  // To avoid complex joins locally, we'll fetch all milestones and filter.
  // If the data scales, a backend function or denormalized `clientUid` on milestones is better.
  final projects = await ref.watch(clientProjectsProvider.future);
  final projectIds = projects.map((p) => p.id).toList();
  
  if (projectIds.isEmpty) {
    yield [];
    return;
  }

  // Use Firestore 'in' query if projectIds length <= 10. For simplicity in UI, we fetch all pending and filter.
  yield* FirebaseFirestore.instance
      .collection('milestones')
      .where('status', isEqualTo: MilestoneStatus.review.name)
      .snapshots()
      .map((snapshot) {
        final allPending = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return MilestoneModel.fromJson(data);
        }).toList();
        return allPending.where((m) => projectIds.contains(m.projectId)).toList();
      });
});

final recentInvoicesProvider = StreamProvider<List<InvoiceModel>>((ref) async* {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    yield [];
    return;
  }

  yield* FirebaseFirestore.instance
      .collection('invoices')
      .where('clientUid', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return InvoiceModel.fromJson(data);
          }).toList());
});
