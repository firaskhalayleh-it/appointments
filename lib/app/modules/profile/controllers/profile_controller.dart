import 'package:appointments/app/data/user_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';

class ProfileController extends GetxController {
  final isEditing = false.obs;
  final profileImageBase64 = ''.obs;

  final Rxn<User> userModel = Rxn<User>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final roleController = TextEditingController();

  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    roleController.dispose();
    super.onClose();
  }

  Future<void> fetchUserData() async {
    try {
      final fb_auth.User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('error'.tr, 'noUserLoggedIn'.tr,
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        Get.snackbar('error'.tr, 'userDataNotFound'.tr,
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      userModel.value = User.fromMap(data, userDoc.id);

      nameController.text = userModel.value?.name ?? '';
      emailController.text = userModel.value?.email ?? '';
      phoneController.text = userModel.value?.phone ?? '';
      roleController.text = userModel.value?.role.name ?? '';

      profileImageBase64.value = userModel.value?.profileImage ?? '';
    } catch (e) {
      Get.snackbar('error'.tr, '${'failedFetchUserData'.tr}: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      fetchUserData();
    }
  }

  Future<void> pickAndConvertImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) return;

      File file = File(result.files.single.path!);

      List<int> imageBytes = await file.readAsBytes();
      profileImageBase64.value = base64Encode(imageBytes);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failedPickImage'.tr}: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> saveProfile() async {
    try {
      final fb_auth.User? firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        Get.snackbar('error'.tr, 'noUserLoggedIn'.tr,
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (userModel.value == null) return;

      final newRoleString = roleController.text.trim().toLowerCase();
      final matchedRole = UserRole.values.firstWhere(
        (r) => r.name == newRoleString,
        orElse: () => UserRole.user,
      );

      final updatedUser = User(
        id: userModel.value!.id,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        profileImage: profileImageBase64.value,
        role: matchedRole,
        permissions: userModel.value!.permissions,
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .update(updatedUser.toMap());

      userModel.value = updatedUser;
      isEditing.value = false;

      Get.snackbar('success'.tr, 'profileUpdatedSuccessfully'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failedSaveProfile'.tr}: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
