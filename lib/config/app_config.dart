class AppConfig {
  // OpenAI API Configuration
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '', // Empty default - key should be provided externally
  );

  // App Configuration
  static const String appName = 'MindfulChat';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.openai.com';

  // Validation
  static bool get isOpenAIKeyValid => openaiApiKey.isNotEmpty;

  // For development - you can set this temporarily
  static String get developmentApiKey {
    // TODO: Replace with your actual key for development, but don't commit this!
    return 'sk-proj-YOUR_API_KEY_HERE';
  }
}