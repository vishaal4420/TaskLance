import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../data/repositories/user_repository.dart';

// Provides the stream of Firebase authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provides the current Firebase UID
final currentUserUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

// Provides the full UserModel from Firestore based on the current UID
final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    yield null;
    return;
  }
  final repo = ref.watch(userRepositoryProvider);
  yield* repo.collection('users').doc(uid).snapshots().map((doc) {
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  });
});

// Fallback provider for user role (defaults to freelancer)
final currentUserRoleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.role ?? UserRole.freelancer;
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signUp(String name, String email, String password, UserRole role) async {
    state = const AsyncLoading();
    
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final newUser = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          role: role,
          bio: 'Newly joined ${role.name}',
          hourlyRate: role == UserRole.freelancer ? 50 : null,
          avatarUrl: 'https://i.pravatar.cc/150?u=$email',
          skills: [],
          createdAt: DateTime.now(),
          companyName: role == UserRole.client ? '$name Company' : null,
        );
        
        await ref.read(userRepositoryProvider).createUser(newUser);
        
        // Automatically send verification email
        await credential.user!.sendEmailVerification();
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await FirebaseAuth.instance.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
