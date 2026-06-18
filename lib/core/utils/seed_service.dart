import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/seed_data.dart';

class SeedService {
  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    
    // Find an actual freelancer and client in the database
    final usersSnapshot = await firestore.collection('users').get();
    String? freelancerUid;
    String? clientUid;
    
    final currentUser = auth.currentUser;
    
    try {
      final freelancerDoc = usersSnapshot.docs.firstWhere(
        (doc) => (doc.data()['role'] == 'UserRole.freelancer' || doc.data()['role'] == 'freelancer') && (currentUser == null || doc.id == currentUser.uid)
      );
      freelancerUid = freelancerDoc.id;
    } catch (e) {
      try {
        final freelancerDoc = usersSnapshot.docs.firstWhere(
          (doc) => doc.data()['role'] == 'UserRole.freelancer' || doc.data()['role'] == 'freelancer'
        );
        freelancerUid = freelancerDoc.id;
      } catch (e) {
        freelancerUid = 'seed_freelancer_001';
      }
    }
    
    try {
      final clientDoc = usersSnapshot.docs.firstWhere(
        (doc) => (doc.data()['role'] == 'UserRole.client' || doc.data()['role'] == 'client') && (currentUser == null || doc.id == currentUser.uid)
      );
      clientUid = clientDoc.id;
    } catch (e) {
      try {
        final clientDoc = usersSnapshot.docs.firstWhere(
          (doc) => doc.data()['role'] == 'UserRole.client' || doc.data()['role'] == 'client'
        );
        clientUid = clientDoc.id;
      } catch (e) {
        clientUid = 'seed_client_001';
      }
    }
    
    // Seed Projects
    final projectBatch = firestore.batch();
    for (var project in SeedData.projects) {
      final docRef = firestore.collection('projects').doc(project.id);
      final data = project.toJson();
      if (data['freelancerUid'] == 'seed_freelancer_001') data['freelancerUid'] = freelancerUid;
      if (data['clientUid'] == 'seed_client_001') data['clientUid'] = clientUid;
      if (data['teamMemberUids'] != null) {
        data['teamMemberUids'] = (data['teamMemberUids'] as List).map((u) => u == 'seed_freelancer_001' ? freelancerUid : u).toList();
      }
      projectBatch.set(docRef, data);
    }
    await projectBatch.commit();

    // Seed Tasks
    final taskBatch = firestore.batch();
    for (var task in SeedData.tasks) {
      final docRef = firestore.collection('tasks').doc(task.id);
      final data = task.toJson();
      if (data['assigneeUid'] == 'seed_freelancer_001') data['assigneeUid'] = freelancerUid;
      taskBatch.set(docRef, data);
    }
    await taskBatch.commit();

    // Seed Milestones
    final milestoneBatch = firestore.batch();
    for (var milestone in SeedData.milestones) {
      final docRef = firestore.collection('milestones').doc(milestone.id);
      final data = milestone.toJson();
      if (data['assigneeUid'] == 'seed_freelancer_001') data['assigneeUid'] = freelancerUid;
      milestoneBatch.set(docRef, data);
    }
    await milestoneBatch.commit();
    
    // Seed Invoices
    final invoiceBatch = firestore.batch();
    for (var invoice in SeedData.invoices) {
      final docRef = firestore.collection('invoices').doc(invoice.id);
      final data = invoice.toJson();
      if (data['freelancerUid'] == 'seed_freelancer_001') data['freelancerUid'] = freelancerUid;
      if (data['clientUid'] == 'seed_client_001') data['clientUid'] = clientUid;
      invoiceBatch.set(docRef, data);
    }
    await invoiceBatch.commit();
  }
}
