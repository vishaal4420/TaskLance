import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project.dart';
import 'base_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

class ProjectRepository extends BaseRepository {
  static const String _collectionName = 'projects';

  /// Stream a specific project by ID
  Stream<ProjectModel?> streamProject(String projectId) {
    return collection(_collectionName).doc(projectId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ProjectModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Stream all projects where the user is either the client or a freelancer
  Stream<List<ProjectModel>> streamProjectsForUser(String uid) {
    return collection(_collectionName)
        .where(
          Filter.or(
            Filter('clientUid', isEqualTo: uid),
            Filter('freelancerUid', isEqualTo: uid),
          ),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Stream all open projects (for freelancers to bid on)
  Stream<List<ProjectModel>> streamOpenProjects() {
    return collection(_collectionName)
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Create a new project
  Future<void> createProject(ProjectModel project) async {
    await collection(_collectionName).doc(project.id).set(project.toJson());
  }

  /// Update an existing project
  Future<void> updateProject(String projectId, Map<String, dynamic> updates) async {
    await collection(_collectionName).doc(projectId).update(updates);
  }
}
