// login_controller.dart
import 'package:appointments/app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  
  final _secureStorage = const FlutterSecureStorage();
  final NotificationService _notificationService = Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    _checkIfLoggedIn();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.init();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> _checkIfLoggedIn() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final storedRole = await _secureStorage.read(key: 'role');
      if (storedRole != null) {
        _navigateBasedOnRole(storedRole);
      } else {
        await _fetchRoleAndNavigate(currentUser.uid);
      }
    }
  }

  Future<void> _fetchRoleAndNavigate(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final role = userDoc['role'] ?? 'user';
        await _secureStorage.write(key: 'role', value: role);
        _navigateBasedOnRole(role);
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  Future<void> login() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      debugPrint('Authenticated UID: $uid');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        debugPrint('User document found: ${userDoc.data()}');
        final role = userDoc['role'] ?? 'user';

        await _secureStorage.write(key: 'role', value: role);
        _navigateBasedOnRole(role);
      } else {
        debugPrint('No user document found for UID: $uid');
        Get.snackbar('Error', 'User not found in the database');
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      Get.snackbar('Login Failed', e.toString());
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'admin':
        Get.offAllNamed('/home');
        break;
      case 'user':
        Get.offAllNamed('/user-dashboard');
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