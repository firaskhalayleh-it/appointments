import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginController extends GetxController {
  // TextEditingControllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Obx observables
  final isPasswordHidden = true.obs;

  // Secure Storage instance
  final _secureStorage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    _checkIfLoggedIn(); // Check if a user is already logged in and redirect if needed.
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Checks if there is a currently logged-in user and if so,
  /// retrieves the stored role from secure storage and navigates accordingly.
  Future<void> _checkIfLoggedIn() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // There's an authenticated user in Firebase Auth
      final storedRole = await _secureStorage.read(key: 'role');
      if (storedRole != null) {
        _navigateBasedOnRole(storedRole);
      } else {
        // In case the role is not found in secure storage,
        // fetch from Firestore as a fallback and navigate.
        _fetchRoleAndNavigate(currentUser.uid);
      }
    }
  }

  /// Helper method to fetch user role from Firestore, store it, and navigate.
  Future<void> _fetchRoleAndNavigate(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final role = userDoc['role'] ?? 'user';
        await _secureStorage.write(key: 'role', value: role);
        _navigateBasedOnRole(role);
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  /// Logs the user in, stores the role in secure storage, and navigates based on role.
  Future<void> login() async {
    try {
      // Authenticate user
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      print('Authenticated UID: $uid'); // Debug: Check the UID being used

      // Fetch user details from Firestore
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        print('User document found: ${userDoc.data()}'); // Debug
        final role = userDoc['role'] ?? 'user';

        // Store the role securely
        await _secureStorage.write(key: 'role', value: role);

        // Navigate based on role
        _navigateBasedOnRole(role);
      } else {
        print('No user document found in Firestore for UID: $uid');
        Get.snackbar('Error', 'User not found in the database');
      }
    } catch (e) {
      print('Error during login: $e'); // Debug
      Get.snackbar('Login Failed', e.toString() ?? 'An error occurred');
    }
  }

  /// Synchronizes Firebase Authentication users with Firestore (if needed).
  Future<void> syncMissingUsers() async {
    try {
      final authUsers = FirebaseAuth.instance.currentUser;
      if (authUsers != null) {
        final uid = authUsers.uid;

        // Check if the user exists in Firestore
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!userDoc.exists) {
          // Add missing user to Firestore
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'uid': uid,
            'email': authUsers.email,
            'role': 'user', // Default role
          });
          print('Added missing user: ${authUsers.email}');
        }
      } else {
        print('No authenticated users found to sync.');
      }
    } catch (e) {
      print('Error syncing users: $e');
    }
  }

  /// Private helper to navigate based on role.
  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'admin':
        Get.offAllNamed('/home'); // Admin dashboard route
        break;
      case 'user':
        Get.offAllNamed('/user-dashboard'); // User dashboard route
        break;
      default:
        Get.snackbar('Error', 'Unauthorized access');
        break;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
