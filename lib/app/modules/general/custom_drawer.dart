import 'dart:convert';
import 'dart:typed_data';

import 'package:appointments/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomDrawer extends StatelessWidget {
  final AdvancedDrawerController advancedDrawerController;

  const CustomDrawer({
    Key? key,
    required this.advancedDrawerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProfileController controller =
        Get.isRegistered() ? Get.find<ProfileController>() : Get.put(ProfileController());

    final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final fb_auth.User? user = _auth.currentUser;

    if (user == null) {
      return Container(
        color: Colors.teal,
        child: Center(
          child: Text(
            'noUserLoggedIn'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );
    }

    final DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.teal,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            color: Colors.teal,
            child: Center(
              child: Text(
                '${'error'.tr}: ${snapshot.error}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            color: Colors.teal,
            child: Center(
              child: Text(
                'userDataNotFound'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          );
        }

        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        String role = data['role'] ?? 'user';

        return Container(
          color: Colors.teal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  advancedDrawerController.hideDrawer();
                  Get.toNamed('/profile');
                },
                child: Obx(() {
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
              ),
              const SizedBox(height: 20),
              if (role.toLowerCase() == 'admin') ...[
                _buildDrawerItem(
                  icon: Icons.home,
                  label: 'home'.tr,
                  onTap: () {
                    advancedDrawerController.hideDrawer();
                    Get.toNamed('/home');
                  },
                ),
                const SizedBox(height: 20),
              ],
              if (role.toLowerCase() == 'user') ...[
                _buildDrawerItem(
                  icon: Icons.home,
                  label: 'home'.tr,
                  onTap: () {
                    advancedDrawerController.hideDrawer();
                    Get.offAllNamed('/user-dashboard');
                  },
                ),
                const SizedBox(height: 20),
              ],
              _buildDrawerItem(
                icon: Icons.settings,
                label: 'settings'.tr,
                onTap: () {
                  advancedDrawerController.hideDrawer();
                  Get.toNamed('/settings');
                },
              ),
              const SizedBox(height: 20),
              if (role.toLowerCase() == 'admin') ...[
                _buildDrawerItem(
                  icon: Icons.people_sharp,
                  label: 'users'.tr,
                  onTap: () {
                    advancedDrawerController.hideDrawer();
                    Get.toNamed('/users');
                  },
                ),
                const SizedBox(height: 20),
              ],
              _buildDrawerItem(
                icon: Icons.logout,
                label: 'logout'.tr,
                onTap: () async {
                  try {
                    await _auth.signOut();
                    await const FlutterSecureStorage().deleteAll();
                    advancedDrawerController.hideDrawer();
                    Get.offAllNamed('/login');
                  } catch (e) {
                    Get.snackbar(
                      'error'.tr,
                      '${'failedLogout'.tr}: $e',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
