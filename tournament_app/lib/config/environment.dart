/// Environment configuration for different build modes
/// 
/// Usage:
/// - Development: Default when running `flutter run`
/// - Production: Use `flutter run --dart-define=ENV=production`
class Environment {
  static const String dev = 'development';
  static const String prod = 'production';

  /// Get current environment from dart-define
  static String get currentEnv {
    const env = String.fromEnvironment('ENV', defaultValue: dev);
    return env;
  }

  /// Check if running in production
  static bool get isProduction => currentEnv == prod;

  /// Check if running in development
  static bool get isDevelopment => currentEnv == dev;

  /// Get API base URL based on environment
  static String get apiBaseUrl {
    if (isProduction) {
      // TODO: Update this with your production API URL
      return 'https://your-api.azurewebsites.net/api';
    }

    // Development URLs
    // Use 10.0.2.2 for Android Emulator
    // Use localhost for iOS Simulator
    // Use actual IP for physical devices
    return _getDevApiUrl();
  }

  /// Get development API URL based on platform
  static String _getDevApiUrl() {
    // You can also use dart-define to override this
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) {
      return override;
    }

    // Default development URLs
    // Uncomment the one you need:

    // For Android Emulator:
    return 'http://10.0.2.2:8080/api';

    // For iOS Simulator or Physical Device on same network:
    // return 'http://localhost:8080/api';

    // For Physical Device (update with your PC's IP):
    // return 'http://192.168.1.X:8080/api';
  }

  /// Get environment display name
  static String get environmentName {
    return isProduction ? 'Production' : 'Development';
  }

  /// Enable debug features in development
  static bool get enableDebugFeatures => isDevelopment;

  /// Show mock data option in development
  static bool get allowMockData => isDevelopment;

  /// API timeout duration (in seconds)
  static Duration get apiTimeout {
    return isProduction 
        ? const Duration(seconds: 30) 
        : const Duration(seconds: 60);
  }

  /// Log API calls in development
  static bool get logApiCalls => isDevelopment;
}
