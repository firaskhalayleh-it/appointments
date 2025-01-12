// lib/app/controllers/users_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/user_model.dart';
import '../../../services/users_service.dart';

class UsersController extends GetxController {
  final UsersService _usersService = Get.find<UsersService>();

  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(); // For password input

  final _users = <User>[].obs;
  final _filteredUsers = <User>[].obs;
  final selectedRole = UserRole.user.obs;
  final selectedPermissions = <Permission>{}.obs;

  List<User> get filteredUsers => _filteredUsers;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    // Listen to search input changes
    searchController.addListener(() {
      filterUsers();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose(); // Dispose password controller
    super.onClose();
  }

  /// Fetch users from Firestore
  void fetchUsers() {
    _usersService.fetchUsers().listen((usersData) {
      _users.value = usersData;
      filterUsers();
    }, onError: (error) {
      Get.snackbar(
        'Error',
        'Failed to fetch users: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  /// Filter users based on search query
  void filterUsers() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredUsers.value = _users;
    } else {
      _filteredUsers.value = _users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.role.name.toLowerCase().contains(query);
      }).toList();
    }
  }

  /// Reset the add/edit user form
  void resetForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear(); // Clear password field
    selectedRole.value = UserRole.user;
    selectedPermissions.clear();
    setDefaultPermissionsForRole(UserRole.user);
  }

  /// Set default permissions based on role
  void setDefaultPermissionsForRole(UserRole role) {
    selectedPermissions.clear();
    switch (role) {
      case UserRole.admin:
        selectedPermissions.addAll(Permission.values);
        break;

      case UserRole.user:
        selectedPermissions.addAll([
          Permission.viewUsers,
          Permission.viewReports,
          Permission.viewDashboard,
        ]);
        break;
    }
  }

  /// Toggle permission selection
  void togglePermission(Permission permission) {
    if (selectedPermissions.contains(permission)) {
      selectedPermissions.remove(permission);
    } else {
      selectedPermissions.add(permission);
    }
  }

  /// Add a new user
  Future<void> addUser() async {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      try {
        await _usersService.signUpUser(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
          role: selectedRole.value,
          permissions: selectedPermissions.toList(),
        );
        resetForm();
        Get.snackbar(
          'Success',
          'User added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to add user: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Please fill in all required fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Edit an existing user
  Future<void> editUser(User user) async {
    nameController.text = user.name;
    emailController.text = user.email;
    selectedRole.value = user.role;
    selectedPermissions.value = user.permissions?.toSet() ?? {};

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  nameController,
                  'Name',
                  Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  emailController,
                  'Email',
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email shouldn't be editable
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => DropdownButton<UserRole>(
                        value: selectedRole.value,
                        dropdownColor: Colors.blue.shade900,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white),
                        items: UserRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                                GetStringUtils(role.name).capitalizeFirst!),
                          );
                        }).toList(),
                        onChanged: (role) {
                          if (role != null) {
                            selectedRole.value = role;
                            setDefaultPermissionsForRole(role);
                          }
                        },
                      )),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedUser = User(
                          id: user.id,
                          name: nameController.text,
                          email: user.email, // Email is not editable
                          role: selectedRole.value,
                          permissions: selectedPermissions.toList(),
                        );
                        try {
                          await _usersService.updateUser(user.id, updatedUser);
                          filterUsers();
                          Get.back();
                          resetForm();
                          Get.snackbar(
                            'Success',
                            'User updated successfully',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to update user: $e',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Delete a user
  Future<void> deleteUser(User user) async {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Are you sure you want to delete ${user.name}?',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _usersService.deleteUser(user.id);
                        filterUsers();
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'User deleted successfully',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to delete user: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade900,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a reusable text field with hint and icon
  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {TextInputType? keyboardType, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
