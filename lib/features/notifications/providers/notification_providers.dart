import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/notification_model.dart';
import '../../auth/providers/auth_providers.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) async* {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    yield [];
    return;
  }
  
  yield* FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((snapshot) {
    final list = snapshot.docs.map((doc) => NotificationModel.fromJson(doc.data())).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  });
});
