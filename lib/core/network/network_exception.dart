import 'package:dio/dio.dart';
import '../error/app_exception.dart';

class NetworkExceptionMapper {
  static NetworkException fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Connection timed out. Please check your internet.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _messageFromStatus(statusCode);
        return NetworkException(message, statusCode: statusCode, code: 'HTTP_$statusCode');
      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection.',
          code: 'NO_CONNECTION',
        );
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.', code: 'CANCELLED');
      default:
        return NetworkException(
          e.message ?? 'An unexpected network error occurred.',
          code: 'UNKNOWN',
          cause: e,
        );
    }
  }

  static String _messageFromStatus(int? code) {
    switch (code) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred (${code ?? 'unknown'}).';
    }
  }
}
