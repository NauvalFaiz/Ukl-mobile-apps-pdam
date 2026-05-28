class AdminModel {
  final int id;
  final String username;
  final String name;
  final String phone;
  final String role;

  AdminModel({
    required this.id,
    required this.username,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
