/// Model untuk response dari POST /auth
///
/// Contoh response API:
/// {
///   "success": true,
///   "message": "User has login successfully",
///   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
///   "role": "ADMIN"   // atau "CUSTOMER"
/// }
class AuthResponseModel {
  final bool success;
  final String message;
  final String token;
  final String role;

  AuthResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? '',
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

  @override
  String toString() =>
      'AuthResponseModel(success: $success, role: $role, token: ${token.substring(0, 20)}...)';
}

