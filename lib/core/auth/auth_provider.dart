import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:etbp_mobile/core/api/api_client.dart';
import 'package:etbp_mobile/core/auth/auth_service.dart';
import 'package:etbp_mobile/core/auth/token_storage.dart';
import 'package:etbp_mobile/models/user.dart';

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.read(tokenStorageProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    api: ref.read(apiClientProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.login(email, password));
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
    ));
  }

  Future<void> checkAuth() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.getMe();
      state = AsyncValue.data(user);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.getMe();
      state = AsyncValue.data(user);
    } catch (_) {}
  }
}
