import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  static ApiException missingToken() =>
      ApiException('Not signed in. Please log in again.', statusCode: 401);

  static ApiException fromDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        'Request timed out. Check your network and try again.',
        statusCode: code,
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        'Cannot reach the server. Is the API running and URL correct?',
        statusCode: code,
      );
    }

    String? serverMsg;
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String) serverMsg = m;
      if (serverMsg == null && data['error'] is String) {
        serverMsg = data['error'] as String;
      }
    }

    switch (code) {
      case 400:
        return ApiException(
          serverMsg ?? 'Invalid request. Please check your input.',
          statusCode: 400,
        );
      case 401:
        return ApiException(
          serverMsg ?? 'Session expired. Please sign in again.',
          statusCode: 401,
        );
      case 403:
        return ApiException(
          serverMsg ?? 'You do not have permission for this action.',
          statusCode: 403,
        );
      case 500:
      default:
        if (code != null && code >= 500) {
          return ApiException(
            serverMsg ?? 'Server error. Please try again later.',
            statusCode: code,
          );
        }
        return ApiException(
          serverMsg ?? e.message ?? 'Something went wrong.',
          statusCode: code,
        );
    }
  }

  @override
  String toString() => message;
}
