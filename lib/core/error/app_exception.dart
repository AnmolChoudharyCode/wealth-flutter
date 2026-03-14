class AppException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const AppException(this.message, {this.code, this.cause});

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(
    super.message, {
    this.statusCode,
    super.code,
    super.cause,
  });
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.cause});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.cause});
}
