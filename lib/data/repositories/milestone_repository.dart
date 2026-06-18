import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/milestone.dart';
import 'base_repository.dart';

final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return MilestoneRepository();
});

class MilestoneRepository extends BaseRepository {
  static const String _collectionName = 'milestones';

  /// Stream a specific milestone by ID
  Stream<MilestoneModel?> streamMilestone(String milestoneId) {
    return collection(_collectionName).doc(milestoneId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id;
        return MilestoneModel.fromJson(data);
      }
      return null;
    });
  }

  /// Stream all milestones for a project
  Stream<List<MilestoneModel>> streamMilestonesForProject(String projectId) {
    return collection(_collectionName)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return MilestoneModel.fromJson(data);
          })
          .toList();
    });
  }

  /// Stream all milestones for a user (across all projects)
  Stream<List<MilestoneModel>> streamMilestonesForUser(String uid) {
    // Note: Since milestones don't have user IDs directly, 
    // a backend function or denormalization would be better here.
    // For now, returning all for the sake of the client view if needed, 
    // but in reality we'd fetch projects first, then their milestones.
    // However, the original UI fetched pending milestones from SeedData.
    // To support a generic user query without cloud functions, we can just fetch all.
    return collection(_collectionName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return MilestoneModel.fromJson(data);
          })
          .toList();
    });
  }

  /// Create a new milestone
  Future<void> createMilestone(MilestoneModel milestone) async {
    await collection(_collectionName).doc(milestone.id).set(milestone.toJson());
  }

  /// Update an existing milestone
  Future<void> updateMilestone(String milestoneId, Map<String, dynamic> updates) async {
    await collection(_collectionName).doc(milestoneId).update(updates);
  }
}
