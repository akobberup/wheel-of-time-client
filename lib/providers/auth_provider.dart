import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Represents the current authentication state of the application.
/// Contains information about whether the user is authenticated, loading status,
/// any authentication errors, and the current user data.
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

  /// Creates a copy of this AuthState with the given fields replaced with new values.
  /// Note: error is always replaced (not merged) to allow clearing errors by passing null.
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

/// StateNotifier that manages authentication state and operations.
/// Handles login, registration, logout, and automatic session restoration.
/// Automatically checks for existing authentication on initialization.
/// - Methods modify state by creating new instances
/// - Setting state = ... automatically notifies listeners (ui)
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  /// Constructor initializes with unauthenticated state and immediately checks
  /// for existing authentication data in storage to restore user session.
  AuthNotifier(this._apiService, this._storageService) : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Checks if there's existing authentication data in storage and validates it.
  /// Called automatically on initialization to restore user sessions across app restarts.
  /// If valid auth data is found, restores the authenticated state.
  /// Otherwise, sets state to unauthenticated.
  Future<void> _checkAuthStatus() async {
    // update ui - loading
    state = state.copyWith(isLoading: true);

    final authData = await _storageService.getAuthData();
    final token = authData['token'];

    if (token != null) {
      // Set the token in API service before validating
      _apiService.setToken(token);
      final isValid = await _apiService.validateToken();

      if (isValid) {
        final userId = int.tryParse(authData['userId'] ?? '');
        if (userId != null) {
          // Token is valid, restore authenticated state
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

    // No valid token found, set to unauthenticated
    state = state.copyWith(isAuthenticated: false, isLoading: false);
  }

  /// Authenticates a user with email and password.
  /// On success, saves auth data to storage and updates state to authenticated.
  /// On failure, updates state with error message.
  Future<void> login(String email, String password) async {
    // update ui
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      // Save authentication data to persistent storage for session restoration
      await _storageService.saveAuthData(
        token: response.token,
        userId: response.userId,
        name: response.name,
        email: response.email,
      );

      // Set token in API service for subsequent authenticated requests
      _apiService.setToken(response.token);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: response,
      );
    } catch (e) {
      // Set error state with the exception message
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Registers a new user account with name, email, and password.
  /// On success, automatically logs the user in by saving auth data and updating state.
  /// On failure, updates state with error message.
  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
      );
      final response = await _apiService.register(request);

      // Automatically log in after successful registration
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

  /// Logs out the current user by clearing all stored authentication data
  /// and resetting the state to unauthenticated.
  Future<void> logout() async {
    await _storageService.clearAuthData();
    _apiService.setToken(null);
    state = AuthState();
  }
}

// Riverpod Providers
// These providers make services and state available throughout the app via dependency injection.

/// Provider for ApiService singleton.
/// Use this to access API functionality from anywhere in the app.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Provider for StorageService singleton.
/// Use this to access persistent storage functionality from anywhere in the app.
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

/// Main authentication provider that manages auth state and operations.
/// Watch this provider to:
/// - Access current authentication state (isAuthenticated, isLoading, error, user)
/// - Call authentication methods (login, register, logout)
/// This provider automatically initializes and checks for existing sessions on app start.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(apiService, storageService);
});
