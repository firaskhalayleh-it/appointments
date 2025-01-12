import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.blue.shade600,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Obx(
                        () => IconButton(
                          icon: Icon(
                            controller.isEditing.value
                                ? Icons.close
                                : Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () => controller.toggleEditMode(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Main Content Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Profile Information
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 60),
                              _buildInfoField(
                                'full_name'.tr,
                                controller.nameController,
                                Icons.person_outline,
                                controller,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoField(
                                'email'.tr,
                                controller.emailController,
                                Icons.email_outlined,
                                controller,
                                enabled: false,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoField(
                                'phone'.tr,
                                controller.phoneController,
                                Icons.phone_outlined,
                                controller,
                              ),
                            ],
                          ),
                        ),

                        // Avatar on top
                        Positioned(
                          top: -60,
                          left: 0,
                          right: 0,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Obx(() {
                                if (controller.profileImageBase64.value.isNotEmpty) {
                                  try {
                                    Uint8List imageBytes = base64Decode(controller.profileImageBase64.value);
                                    return CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.white.withOpacity(0.9),
                                      backgroundImage: MemoryImage(imageBytes),
                                    );
                                  } catch (e) {
                                    return _defaultAvatar();
                                  }
                                } else {
                                  return _defaultAvatar();
                                }
                              }),
                              Positioned(
                                top: 80,
                                right: 100,
                                child: Obx(
                                  () => controller.isEditing.value
                                      ? Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              controller.pickAndConvertImage();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.camera_alt,
                                                size: 20,
                                                color: Colors.blue.shade900,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  Obx(() => controller.isEditing.value
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              bool confirm = await _showConfirmationDialog();
                              if (confirm) {
                                await controller.saveProfile();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade900,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'save_changes'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog() async {
    return await Get.defaultDialog<bool>(
          title: 'confirm'.tr,
          middleText: 'confirm_save_changes'.tr,
          textConfirm: 'yes'.tr,
          textCancel: 'no'.tr,
          onConfirm: () {
            Get.back(result: true);
          },
          onCancel: () {
            Get.back(result: false);
          },
        ) ??
        false;
  }

  CircleAvatar _defaultAvatar() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white.withOpacity(0.9),
      child: const Icon(
        Icons.person_outline,
        size: 60,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController textController,
    IconData icon,
    ProfileController controller, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(
            () => TextField(
              controller: textController,
              enabled: controller.isEditing.value && enabled,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.white70),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
