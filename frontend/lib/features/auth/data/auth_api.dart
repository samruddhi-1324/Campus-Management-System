import 'package:campus_care/core/network/api_client.dart';

class AuthApi {
  final ApiClient _client = apiClient;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }
}

final authApi = AuthApi();
