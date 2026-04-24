import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

const _extraAuth = 'requiresAuth';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required void Function() onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _onUnauthorized = onUnauthorized {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 120),
        headers: const {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final needsAuth = options.extra[_extraAuth] == true;
          if (!needsAuth) return handler.next(options);

          final token = await _tokenStorage.getAccessToken();
          if (token == null || token.isEmpty) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: ApiException.missingToken(),
                type: DioExceptionType.cancel,
              ),
            );
          }
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401 &&
              e.requestOptions.extra[_extraAuth] == true) {
            await _tokenStorage.clear();
            _onUnauthorized();
          }
          return handler.next(e);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final void Function() _onUnauthorized;
  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> getJson<T>(
    String path, {
    bool requiresAuth = true,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(extra: {_extraAuth: requiresAuth}),
    );
  }

  Future<Response<T>> postJson<T>(
    String path, {
    Object? data,
    bool requiresAuth = true,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      options: Options(
        extra: {_extraAuth: requiresAuth},
        headers: const {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    bool requiresAuth = true,
  }) {
    return _dio.post<T>(
      path,
      data: formData,
      options: Options(extra: {_extraAuth: requiresAuth}),
    );
  }
}
