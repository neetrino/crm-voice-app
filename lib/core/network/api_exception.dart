import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  static ApiException missingToken() =>
      ApiException('Սեսիան ավարտվել է, մուտք գործեք նորից', statusCode: 401);

  static ApiException fromDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        'Հարցման ժամանակը սպառվեց։ Ստուգեք կապը և փորձեք նորից։',
        statusCode: code,
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        'Չհաջողվեց կապ հաստատել սերվերի հետ։',
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
          serverMsg ?? 'Սխալ հարցում։ Ստուգեք տվյալները։',
          statusCode: 400,
        );
      case 401:
        return ApiException(
          serverMsg ?? 'Սեսիան ավարտվել է, մուտք գործեք նորից',
          statusCode: 401,
        );
      case 403:
        return ApiException(
          serverMsg ?? 'Այս գործողության համար թույլտվություն չունեք։',
          statusCode: 403,
        );
      case 500:
      default:
        if (code != null && code >= 500) {
          return ApiException(
            serverMsg ?? 'Սերվերի սխալ։ Փորձեք ավելի ուշ։',
            statusCode: code,
          );
        }
        return ApiException(
          serverMsg ?? e.message ?? 'Ինչ-որ բան սխալ ընթացավ։',
          statusCode: code,
        );
    }
  }

  @override
  String toString() => message;
}
