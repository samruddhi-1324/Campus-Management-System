class AppConfig {
  static const String appName = 'Campus Care';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
  static const String appVersion = '1.0.0';
}
