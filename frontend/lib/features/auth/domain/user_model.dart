enum UserRole {
  reporter,
  coordinator,
  supervisor,
  opsHead,
  admin,
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: UserRole.values.byName(json['role']),
    );
  }
}
