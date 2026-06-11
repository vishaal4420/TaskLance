import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/seed_data.dart';

class SeedService {
  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instance;
    
    // Seed Projects
    final projectBatch = firestore.batch();
    for (var project in SeedData.projects) {
      final docRef = firestore.collection('projects').doc(project.id);
      projectBatch.set(docRef, project.toJson());
    }
    await projectBatch.commit();

    // Seed Tasks
    final taskBatch = firestore.batch();
    for (var task in SeedData.tasks) {
      final docRef = firestore.collection('tasks').doc(task.id);
      taskBatch.set(docRef, task.toJson());
    }
    await taskBatch.commit();

    // Seed Milestones
    final milestoneBatch = firestore.batch();
    for (var milestone in SeedData.milestones) {
      final docRef = firestore.collection('milestones').doc(milestone.id);
      milestoneBatch.set(docRef, milestone.toJson());
    }
    await milestoneBatch.commit();
  }
}
