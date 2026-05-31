import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/features/service/data/models/service_model.dart';

class ServiceApiService {
  final ApiClient apiClient;

  ServiceApiService({required this.apiClient});

  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await apiClient.dio.get('/services');
      if (response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal memuat layanan: $serverMessage');
    }
  }

  Future<ServiceModel> getServiceById(int id) async {
    try {
      final response = await apiClient.dio.get('/services/$id');
      if (response.data['data'] != null) {
        return ServiceModel.fromJson(response.data['data']);
      }
      throw Exception('Format response tidak sesuai');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal memuat detail layanan: $serverMessage');
    }
  }

  Future<ServiceModel> createService(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/services', data: data);
      if (response.data['data'] != null) {
        return ServiceModel.fromJson(response.data['data']);
      }
      throw Exception('Format response tidak sesuai');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal membuat layanan: $serverMessage');
    }
  }

  Future<ServiceModel> updateService(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/services/$id', data: data);
      if (response.data['data'] != null) {
        return ServiceModel.fromJson(response.data['data']);
      }
      throw Exception('Format response tidak sesuai');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal mengupdate layanan: $serverMessage');
    }
  }

  Future<void> deleteService(int id) async {
    try {
      await apiClient.dio.delete('/services/$id');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      
      if (serverMessage.toString().contains('Foreign key constraint violated') || serverMessage.toString().contains('service_id')) {
        throw Exception('Gagal menghapus: Layanan sedang digunakan oleh pelanggan atau data transaksi. Hapus data pelanggan terkait terlebih dahulu.');
      }
      
      throw Exception('Gagal menghapus layanan: $serverMessage');
    }
  }
}
