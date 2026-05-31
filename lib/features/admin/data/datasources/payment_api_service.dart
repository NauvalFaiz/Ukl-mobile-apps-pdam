import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';

class PaymentApiService {
  final ApiClient apiClient;

  PaymentApiService({required this.apiClient});

  Future<List<PaymentModel>> getAllPayments({int page = 1, int limit = 10}) async {
    try {
      final response = await apiClient.dio.get(
        '/payments',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200 && response.data['success']) {
        final rawData = response.data['data'];
        // Support both paginated object and plain array
        final List data = rawData is List ? rawData : (rawData['data'] ?? rawData);
        return data.map((json) => PaymentModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch payments');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<PaymentModel> getPaymentById(int id) async {
    try {
      final response = await apiClient.dio.get('/payments/$id');
      if (response.statusCode == 200 && response.data['success']) {
        return PaymentModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch payment detail');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<PaymentModel> verifyPayment(int id, bool verified) async {
    try {
      final response = await apiClient.dio.patch(
        '/payments/$id',
        data: {'verified': verified},
      );
      if (response.statusCode == 200 && response.data['success']) {
        return PaymentModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to verify payment');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      final response = await apiClient.dio.delete('/payments/$id');
      if (response.statusCode != 200 || !response.data['success']) {
        throw Exception(response.data['message'] ?? 'Failed to delete payment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
