import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';

final firebaseServiceProvider =
    Provider<FirebaseService>((ref) => FirebaseService());

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> sendEmailVerification() async =>
      await _auth.currentUser?.sendEmailVerification();

  Future<void> reloadUser() async => await _auth.currentUser?.reload();

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> signOut() => _auth.signOut();

  Future<void> updatePassword(String newPassword) async =>
      await _auth.currentUser?.updatePassword(newPassword);

  Future<void> reauthenticate(String email, String password) async {
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  Future<void> createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUserDocument(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson({...doc.data()!, 'uid': doc.id});
  }

  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Stream<List<Map<String, dynamic>>> streamProjects(String uid) {
    return _firestore
        .collection('projects')
        .where('freelancerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamClientProjects(String clientUid) {
    return _firestore
        .collection('projects')
        .where('clientUid', isEqualTo: clientUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamConversations(String uid) {
    return _firestore
        .collection('conversations')
        .where('participantUids', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamNotifications(String uid) {
    return _firestore
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Future<void> sendMessage(
      String conversationId, Map<String, dynamic> messageData) async {
    final batch = _firestore.batch();
    final msgRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();
    batch.set(msgRef, {...messageData, 'id': msgRef.id});
    batch.update(
        _firestore.collection('conversations').doc(conversationId), {
      'lastMessage': messageData['content'],
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> markNotificationsRead(String uid) async {
    final snap = await _firestore
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

}
