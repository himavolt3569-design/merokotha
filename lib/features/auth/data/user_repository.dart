import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:merokotha/shared/models/user_model.dart';
import 'package:merokotha/shared/providers/firebase_providers.dart';

part 'user_repository.g.dart';

class UserRepository {
  final FirebaseFirestore _db;

  UserRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // Create new user document after first login
  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set(user.toMap());
  }

  // Get user by ID (one-time fetch)
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromSnapshot(doc);
  }

  // Check if user document exists
  Future<bool> userExists(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists;
  }

  // Watch user in real time
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromSnapshot(doc);
    });
  }

  // Update user fields
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Save FCM token
  Future<void> saveFcmToken(String uid, String token) async {
    await _users.doc(uid).update({'fcmToken': token});
  }

  // Update role (for role switching)
  Future<void> updateRole(String uid, UserRole role) async {
    await _users.doc(uid).update({
      'role': role.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(firebaseFirestoreProvider));
}
