import 'package:dio/dio.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';
import 'package:uklmobileapps/core/storage/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient({required this.dio, required this.tokenStorage}) {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15); 
    dio.options.receiveTimeout = const Duration(seconds: 15);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final appKey = tokenStorage.getAppKey();
          if (appKey != null && appKey.isNotEmpty) {
            options.headers['app-key'] = appKey;
          }

          final jwt = tokenStorage.getJwt();
          if (jwt != null && jwt.isNotEmpty) {
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