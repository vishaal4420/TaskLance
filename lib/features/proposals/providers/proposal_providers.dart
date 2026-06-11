import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final proposalDetailProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, proposalId) {
  return FirebaseFirestore.instance.collection('proposals').doc(proposalId).snapshots().map((doc) {
    if (doc.exists) {
      return doc.data();
    }
    return null;
  });
});

final projectProposalsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, projectId) {
  return FirebaseFirestore.instance
      .collection('proposals')
      .where('projectId', isEqualTo: projectId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
