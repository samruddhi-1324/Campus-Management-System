import 'package:dio/dio.dart';
import 'package:campus_care/app/config.dart';
import 'package:campus_care/core/storage/secure_storage.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
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
            final candidates = [
              'http://127.0.0.1:8000/api/v1',
              'http://192.168.1.23:8000/api/v1',
              'http://10.0.2.2:8000/api/v1',
            ];
            for (final candidate in candidates) {
              if (error.requestOptions.baseUrl != candidate) {
                try {
                  final fallbackOptions = error.requestOptions.copyWith(
                    baseUrl: candidate,
                    connectTimeout: const Duration(seconds: 3),
                  );
                  final res = await dio.fetch(fallbackOptions);
                  return handler.resolve(res);
                } catch (_) {
                  continue;
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}

final apiClient = ApiClient();
