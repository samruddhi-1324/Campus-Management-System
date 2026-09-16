import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static const String _issuesCachePrefix = 'cached_issues_';

  Future<void> cacheUserIssues(String userId, List<Map<String, dynamic>> issues) async {
    if (kIsWeb) return; // Online-only in Phase 1-2 for Web per FR-PLAT-13
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_issuesCachePrefix$userId', jsonEncode(issues));
  }

  Future<List<Map<String, dynamic>>?> getCachedUserIssues(String userId) async {
    if (kIsWeb) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_issuesCachePrefix$userId');
    if (raw == null) return null;
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }
}

final localCacheService = LocalCacheService();
