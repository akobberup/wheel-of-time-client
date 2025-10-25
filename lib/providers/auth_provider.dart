import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Auth State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final AuthResponse? user;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    AuthResponse? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthNotifier(this._apiService, this._storageService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final authData = await _storageService.getAuthData();
    final token = authData['token'];

    if (token != null) {
      _apiService.setToken(token);
      final isValid = await _apiService.validateToken();

      if (isValid) {
        final userId = int.tryParse(authData['userId'] ?? '');
        if (userId != null) {
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: AuthResponse(
              token: token,
              userId: userId,
              name: authData['name'] ?? '',
              email: authData['email'] ?? '',
            ),
          );
          return;
        }
      }
    }

    state = state.copyWith(isAuthenticated: false, isLoading: false);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      await _storageService.saveAuthData(
        token: response.token,
        userId: response.userId,
        name: response.name,
        email: response.email,
      );

      _apiService.setToken(response.token);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: response,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
      );
      final response = await _apiService.register(request);

      await _storageService.saveAuthData(
        token: response.token,
        userId: response.userId,
        name: response.name,
        email: response.email,
      );

      _apiService.setToken(response.token);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: response,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _storageService.clearAuthData();
    _apiService.setToken(null);
    state = AuthState();
  }
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(apiService, storageService);
});
