import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_repository.dart';

final deliverableRepositoryProvider = Provider<DeliverableRepository>((ref) {
  return DeliverableRepository();
});

class DeliverableRepository extends BaseRepository {
  static const String _collectionName = 'deliverables';

  Stream<List<Map<String, dynamic>>> streamDeliverablesForProject(String projectId) {
    return collection(_collectionName)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> createDeliverable(Map<String, dynamic> deliverable) async {
    await collection(_collectionName).doc(deliverable['id']).set(deliverable);
  }
}
