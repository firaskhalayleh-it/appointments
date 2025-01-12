enum UserRole {
  admin,
  user,
}

enum Permission {
  viewUsers,
  createUser,
  editUser,
  deleteUser,
  viewReports,
  createReports,
  manageRoles,
  managePermissions,
  accessSettings,
  viewDashboard
}

extension StringExtension on String {
  String? get capitalizeFirst {
    if (isEmpty) return null;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? profileImage;
  final List<Permission>? permissions;

  User({
    required this.id,
    required this.name,
    required this.email,
     this.phone,
    required this.role,
     this.profileImage,
     this.permissions,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      permissions: (map['permissions'] as List<dynamic>?)
              ?.map((perm) => Permission.values.firstWhere(
                    (e) => e.name == perm,
                    orElse: () => Permission.viewDashboard,
                  ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone??'',
      'profileImage': profileImage??'',
      'role': role.name,
      'permissions': permissions?.map((e) => e.name).toList() ?? [],
    };
  }
}
