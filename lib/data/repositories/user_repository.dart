import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import 'base_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserRepository extends BaseRepository {
  static const String _collectionName = 'users';

  /// Fetch a user by their UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await collection(_collectionName).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  /// Create or overwrite a user profile
  Future<void> createUser(UserModel user) async {
    await collection(_collectionName).doc(user.uid).set(user.toJson());
  }

  /// Update an existing user profile
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    await collection(_collectionName).doc(uid).update(updates);
  }

  /// Stream a user's profile for real-time updates
  Stream<UserModel?> streamUser(String uid) {
    return collection(_collectionName).doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
