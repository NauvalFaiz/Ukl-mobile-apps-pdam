import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';
import '../models/user_model.dart';


class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  Future<String?> getAppKey(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.ownerAuth,
        data: {
          'email': email,
          'password': password,
        },
      );

      // Cek apakah response success (200 atau 201)
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        
        // Coba baca dari data['message']['owner_token']
        if (data['message'] != null && data['message'] is Map && data['message']['owner_token'] != null) {
          return data['message']['owner_token'];
        }
        
        // Coba baca dari data['data']['owner_token'] (format awal)
        if (data['data'] != null && data['data'] is Map && data['data']['owner_token'] != null) {
          return data['data']['owner_token'];
        }
        
        // Coba baca dari data['owner_token'] langsung
        if (data['owner_token'] != null) {
          return data['owner_token'];
        }

        throw Exception('owner_token tidak ditemukan di response: $data');
      }
      throw Exception('Status code error: ${response.statusCode}');
    } on DioException catch (e) {
      final errorData = e.response?.data;
      throw Exception('API Error: ${e.message} - Data: $errorData');
    } catch (e) {
      throw Exception('Unknown Error: $e');
    }
  }

  Future<UserModel> loginUser(String username, String password) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.userAuth,
        data: {
          'username': username,
          'password': password,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        try {
          return UserModel.fromJson(e.response!.data);
        } catch (_) {}
      }
      return UserModel(
        success: false,
        message: e.message ?? 'Unknown Error Occurred',
      );
    }
  }
}
