abstract final class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/me';

  // Dashboard
  static const String portfolioSummary = '/portfolio/summary';
  static const String recentTransactions = '/transactions/recent';

  // Portfolio
  static const String holdings = '/portfolio/holdings';
  static const String performance = '/portfolio/performance';

  // Markets
  static const String marketIndices = '/markets/indices';
  static const String watchlist = '/markets/watchlist';
  static const String ticker = '/markets/ticker'; // + /{symbol}

  // Profile
  static const String userProfile = '/user/profile';
  static const String notifications = '/user/notifications';
}
