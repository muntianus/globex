class AppConfig {
  // Позволяет переопределять базовый URL через --dart-define
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}

