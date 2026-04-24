import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccess = 'access_token';
const _kRefresh = 'refresh_token';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccess);

  Future<String?> getRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  Future<bool> hasAccessToken() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }
}
