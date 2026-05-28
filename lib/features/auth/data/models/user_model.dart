class UserModel {
  final bool success;
  final String? message;
  final String? token;
  final String? role;

  UserModel({
    required this.success,
    this.message,
    this.token,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'role': role,
    };
  }
}
