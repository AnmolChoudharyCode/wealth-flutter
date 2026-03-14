abstract final class AppConfig {
  static const String appName = 'Wealth';
  static const String appVersion = '1.0.0';

  // API base URL — replace with real endpoint
  static const String baseUrl = 'https://api.wealth.example.com/v1';

  // Timeouts
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;

  // Polling interval for market data (seconds)
  static const int marketDataRefreshSec = 30;
}
