import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/auth_response.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await _client.postJson(
        '/auth/login',
        data: {'email': email, 'password': password},
        requiresAuth: false,
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw ApiException('Unexpected response from server.');
      }
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
