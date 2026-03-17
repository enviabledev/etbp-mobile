import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:etbp_mobile/config/constants.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: AppConstants.accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
