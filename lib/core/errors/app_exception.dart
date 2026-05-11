import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;

  static AppException fromDio(Object error) {
    if (error is DioException) {
      final msg = error.message;
      if (msg != null && msg.isNotEmpty) {
        return AppException(msg);
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const AppException(
              'Request timed out. Check your connection.');
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          return AppException('Server error${code != null ? ' ($code)' : ''}.');
        case DioExceptionType.connectionError:
          return const AppException('No internet connection.');
        default:
          return const AppException('Something went wrong. Please try again.');
      }
    }
    return const AppException('Something went wrong. Please try again.');
  }
}
