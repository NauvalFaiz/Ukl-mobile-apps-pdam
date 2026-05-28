import 'package:dio/dio.dart';
import '../shared/token_storage.dart';
import 'api_constants.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient({required this.dio, required this.tokenStorage}) {
    // Set Base URL dari ApiConstants
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 1. Ambil App-Key
          final appKey = tokenStorage.getAppKey();
          if (appKey != null) {
            options.headers['app-key'] = appKey;
          }

          // 2. Ambil JWT Token
          final jwt = tokenStorage.getJwt();
          if (jwt != null) {
            options.headers['Authorization'] = 'Bearer $jwt';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }
}
