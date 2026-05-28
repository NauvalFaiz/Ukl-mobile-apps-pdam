import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_client.dart';

class AdminService {
  final ApiClient apiClient;

  AdminService({required this.apiClient});

  Future<Map<String, dynamic>> getAdminProfile() async {
    try {
      final response = await apiClient.dio.get('/admins/me');
      return response.data;
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal memuat profil: $serverMessage');
    } catch (e) {
      throw Exception('Gagal memuat profil: $e');
    }
  }

  Future<void> updateAdminProfile(int id, Map<String, dynamic> data) async {
    try {
      await apiClient.dio.patch('/admins/$id', data: data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal update profil: $serverMessage');
    } catch (e) {
      throw Exception('Gagal update profil: $e');
    }
  }

  Future<void> deleteAdminProfile(int id) async {
    try {
      await apiClient.dio.delete('/admins/$id');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal hapus profil: $serverMessage');
    } catch (e) {
      throw Exception('Gagal hapus profil: $e');
    }
  }
}
