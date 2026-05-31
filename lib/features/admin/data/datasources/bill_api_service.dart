import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';

class BillApiService {
  final ApiClient apiClient;

  BillApiService({required this.apiClient});

  Future<List<BillModel>> getAllBills() async {
    try {
      final response = await apiClient.dio.get('/bills');
      if (response.statusCode == 200 && response.data['success']) {
        final List data = response.data['data'];
        return data.map((json) => BillModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch bills');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<BillModel> getBillById(int id) async {
    try {
      final response = await apiClient.dio.get('/bills/$id');
      if (response.statusCode == 200 && response.data['success']) {
        return BillModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch bill detail');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<BillModel> createBill(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/bills', data: data);
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success']) {
        return BillModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create bill');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<BillModel> updateBill(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/bills/$id', data: data);
      if (response.statusCode == 200 && response.data['success']) {
        return BillModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update bill');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> deleteBill(int id) async {
    try {
      final response = await apiClient.dio.delete('/bills/$id');
      if (response.statusCode != 200 || !response.data['success']) {
        throw Exception(response.data['message'] ?? 'Failed to delete bill');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
