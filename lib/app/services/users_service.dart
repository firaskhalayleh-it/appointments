// lib/app/services/users_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:get/get.dart';
import '../data/user_model.dart';

class UsersService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Stream of users from Firestore
  Stream<List<User>> fetchUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  /// Sign Up a new user with email and password, then create a Firestore document
  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required List<Permission> permissions,
  }) async {
    try {
      // Create user in Firebase Auth
      fb_auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // Create user data
      User newUser = User(
        id: uid,
        name: name,
        email: email,
        role: role,
        permissions: permissions,
      );

      // Create user document in Firestore with UID as document ID
      await _firestore.collection('users').doc(uid).set(newUser.toMap());
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      throw Exception(e.message);
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to sign up user: $e');
    }
  }

  /// Update an existing user in Firestore
  Future<void> updateUser(String id, User user) async {
    try {
      await _firestore.collection('users').doc(id).update(user.toMap());

      // Optionally, update display name in Firebase Auth if the current user is being updated
      fb_auth.User? authUser = _auth.currentUser;
      if (authUser != null && authUser.uid == id) {
        await authUser.updateDisplayName(user.name);
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete a user from Firestore and Firebase Auth (only if it's the current user)
  Future<void> deleteUser(String id) async {
    try {
      // Delete user from Firebase Auth if it's the currently authenticated user
      fb_auth.User? authUser = _auth.currentUser;
      if (authUser != null && authUser.uid == id) {
        await authUser.delete();
      } else {
        // Deleting other users from Firebase Auth requires Admin privileges.
        // This typically cannot be done from the client side for security reasons.
        // Instead, you might want to mark the user as inactive or handle it via Cloud Functions.
        // For this example, we'll proceed to delete from Firestore only.
      }

      // Delete user from Firestore
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

}
