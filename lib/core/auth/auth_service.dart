import 'package:etbp_mobile/core/api/api_client.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/core/auth/token_storage.dart';
import 'package:etbp_mobile/models/user.dart';

class AuthService {
  final ApiClient _api;
  final TokenStorage _tokenStorage;

  AuthService({required ApiClient api, required TokenStorage tokenStorage})
      : _api = api,
        _tokenStorage = tokenStorage;

  Future<User> login(String email, String password) async {
    final response = await _api.post(Endpoints.login, data: {
      'email': email,
      'password': password,
    });
    await _tokenStorage.saveTokens(
      response.data['access_token'],
      response.data['refresh_token'],
    );
    return getMe();
  }

  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _api.post(Endpoints.register, data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    await _tokenStorage.saveTokens(
      response.data['access_token'],
      response.data['refresh_token'],
    );
    return getMe();
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _api.post(Endpoints.logout, data: {'refresh_token': refreshToken});
      }
    } catch (_) {}
    await _tokenStorage.clearTokens();
  }

  Future<User> getMe() async {
    final response = await _api.get(Endpoints.me);
    return User.fromJson(response.data);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put(Endpoints.updateProfile, data: data);
    return User.fromJson(response.data);
  }
}
