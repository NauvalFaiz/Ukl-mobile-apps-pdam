import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/features/customer/data/models/customer_model.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';

class CustomerMeApiService {
  final ApiClient apiClient;

  CustomerMeApiService({required this.apiClient});

  Future<CustomerModel> getMyProfile() async {
    try {
      final response = await apiClient.dio.get('/customers/me');
      if (response.statusCode == 200 && response.data['success']) {
        return CustomerModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<List<BillModel>> getMyBills() async {
    try {
      final response = await apiClient.dio.get('/bills/me');
      if (response.statusCode == 200 && response.data['success']) {
        final List data = response.data['data'];
        return data.map((json) => BillModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch my bills');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<BillModel> getMyBillDetail(int id) async {
    try {
      final response = await apiClient.dio.get('/bills/me/$id');
      if (response.statusCode == 200 && response.data['success']) {
        return BillModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch bill detail');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<List<PaymentModel>> getMyPayments({int page = 1, int limit = 10}) async {
    try {
      final response = await apiClient.dio.get(
        '/payments/me',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200 && response.data['success']) {
        final rawData = response.data['data'];
        // Support both paginated object and plain array
        final List data = rawData is List ? rawData : (rawData['data'] ?? rawData);
        return data.map((json) => PaymentModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch my payments');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> uploadPayment(int billId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'bill_id': billId,
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await apiClient.dio.post('/payments', data: formData);
      if (response.statusCode != 200 || !response.data['success']) {
        throw Exception(response.data['message'] ?? 'Failed to upload payment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
