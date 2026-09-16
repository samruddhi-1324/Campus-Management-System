import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_access_token';
  static const String _userKey = 'auth_user_data';

  // In-memory token storage for Web to prevent token exposure in localStorage (FR-PLAT-10)
  static String? _webMemoryToken;

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _webMemoryToken = token;
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      return _webMemoryToken;
    }
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearAll() async {
    _webMemoryToken = null;
    if (!kIsWeb) {
      await _storage.deleteAll();
    }
  }
}

final secureStorageService = SecureStorageService();
