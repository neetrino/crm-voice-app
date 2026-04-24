class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  final String id;
  final String email;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: (json['role']?.toString() ?? '').toUpperCase(),
    );
  }
}
