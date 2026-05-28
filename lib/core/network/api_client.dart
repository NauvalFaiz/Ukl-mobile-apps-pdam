// uklmobileapps/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';
import 'package:uklmobileapps/core/storage/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient({required this.dio, required this.tokenStorage}) {
    // 1. Konfigurasi Dasar
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15); // Dinaikkan sedikit agar lebih aman jika jaringan lambat
    dio.options.receiveTimeout = const Duration(seconds: 15);

    // 2. Interceptor Tunggal untuk Menyuntikkan Header secara Otomatis
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ambil App-Key dari TokenStorage (Sinkronus, tanpa perlu await SharedPreferences lagi)
          final appKey = tokenStorage.getAppKey();
          if (appKey != null && appKey.isNotEmpty) {
            options.headers['app-key'] = appKey;
          }

          // Ambil JWT Token untuk User (Admin/Customer)
          final jwt = tokenStorage.getJwt();
          if (jwt != null && jwt.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $jwt';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Kamu bisa menambahkan log error global di sini jika diperlukan
          // Contoh: jika token kedaluwarsa (401), bisa diarahkan ke fungsi logout otomatis
          return handler.next(e);
        },
      ),
    );
  }
}