import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';

final inboxProvider = StreamProvider<List<ConversationModel>>((ref) async* {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    yield [];
    return;
  }

  yield* FirebaseFirestore.instance
      .collection('conversations')
      .where('participantUids', arrayContains: uid)
      .snapshots()
      .map((snapshot) {
    final list = snapshot.docs.map((doc) => ConversationModel.fromJson(doc.data())).toList();
    list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return list;
  });
});

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) async* {
  yield* FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => MessageModel.fromJson(doc.data())).toList();
  });
});

final contactsProvider = FutureProvider<List<UserModel>>((ref) async {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) return [];
  
  // For simplicity, just return all users except the current one.
  // In a real app, this might only return connected freelancers/clients.
  final snapshot = await FirebaseFirestore.instance.collection('users').get();
  return snapshot.docs
      .map((doc) => UserModel.fromJson(doc.data()))
      .where((u) => u.uid != uid)
      .toList();
});
