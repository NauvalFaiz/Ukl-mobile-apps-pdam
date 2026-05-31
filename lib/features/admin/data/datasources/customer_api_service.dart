import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/features/customer/data/models/customer_model.dart';

class CustomerApiService {
  final ApiClient apiClient;

  CustomerApiService({required this.apiClient});

  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final response = await apiClient.dio.get('/customers');
      if (response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => CustomerModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal memuat pelanggan: $serverMessage');
    }
  }

  Future<CustomerModel> getCustomerById(int id) async {
    try {
      final response = await apiClient.dio.get('/customers/$id');
      if (response.data['data'] != null) {
        return CustomerModel.fromJson(response.data['data']);
      }
      throw Exception('Format response tidak sesuai');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal memuat detail pelanggan: $serverMessage');
    }
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/customers', data: data);
      if (response.data['data'] != null) {
        return CustomerModel.fromJson(response.data['data']);
      }
      throw Exception('Format response tidak sesuai');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal membuat pelanggan: $serverMessage');
    }
  }

  Future<CustomerModel> updateCustomer(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/customers/$id', data: data);
      if (response.data['data'] != null) {
        return CustomerModel.fromJson(response.data['data']);
      }
      throw Exception('Format response tidak sesuai');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal mengupdate pelanggan: $serverMessage');
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await apiClient.dio.delete('/customers/$id');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Gagal menghapus pelanggan: $serverMessage');
    }
  }
}
