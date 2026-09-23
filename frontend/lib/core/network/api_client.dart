import 'package:dio/dio.dart';
import 'package:campus_care/app/config.dart';
import 'package:campus_care/core/storage/secure_storage.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            final currentUrl = error.requestOptions.baseUrl;
            if (currentUrl.contains('127.0.0.1')) {
              try {
                final fallbackOptions = error.requestOptions.copyWith(
                  baseUrl: 'http://192.168.0.111:8000/api/v1',
                );
                final res = await dio.fetch(fallbackOptions);
                return handler.resolve(res);
              } catch (_) {}
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}

final apiClient = ApiClient();
