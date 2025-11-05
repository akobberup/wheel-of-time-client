import 'dart:developer' as developer;
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
  /// If access token is expired but refresh token is valid, automatically refreshes.
  /// Otherwise, sets state to unauthenticated.
  Future<void> _checkAuthStatus() async {
    developer.log('🔍 Checking auth status...', name: 'AuthProvider');
    // update ui - loading
    state = state.copyWith(isLoading: true);

    final authData = await _storageService.getAuthData();
    final token = authData['token'];
    final refreshToken = authData['refreshToken'];

    developer.log('📦 Retrieved from storage - token: ${token != null ? "EXISTS (${token.length} chars)" : "NULL"}, refreshToken: ${refreshToken != null ? "EXISTS (${refreshToken.substring(0, 8)}...)" : "NULL"}', name: 'AuthProvider');

    if (token != null && refreshToken != null) {
      // Set the token in API service before validating
      _apiService.setToken(token);
      developer.log('🔐 Validating token...', name: 'AuthProvider');
      final isValid = await _apiService.validateToken();
      developer.log('✅ Token validation result: $isValid', name: 'AuthProvider');

      if (isValid) {
        final userId = int.tryParse(authData['userId'] ?? '');
        if (userId != null) {
          // Token is valid, restore authenticated state
          developer.log('✨ Auth restored successfully for user $userId', name: 'AuthProvider');
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: AuthResponse(
              token: token,
              refreshToken: refreshToken,
              userId: userId,
              name: authData['name'] ?? '',
              email: authData['email'] ?? '',
            ),
          );
          return;
        }
      } else {
        // Access token expired, try to refresh
        developer.log('🔄 Token invalid, attempting refresh...', name: 'AuthProvider');
        try {
          final response = await _apiService.refreshAccessToken(refreshToken);

          // Save new tokens
          await _storageService.saveAuthData(
            token: response.token,
            refreshToken: response.refreshToken,
            userId: response.userId,
            name: response.name,
            email: response.email,
          );

          _apiService.setToken(response.token);

          developer.log('✅ Token refreshed successfully', name: 'AuthProvider');
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: response,
          );
          return;
        } catch (e) {
          // Refresh failed, clear auth data and continue to unauthenticated state
          developer.log('❌ Token refresh failed: $e', name: 'AuthProvider');
          await _storageService.clearAuthData();
        }
      }
    } else {
      developer.log('⚠️ No tokens found in storage', name: 'AuthProvider');
    }

    // No valid token found, set to unauthenticated
    developer.log('🚫 Setting state to unauthenticated', name: 'AuthProvider');
    state = state.copyWith(isAuthenticated: false, isLoading: false);
  }

  /// Authenticates a user with email and password.
  /// On success, saves auth data to storage and updates state to authenticated.
  /// On failure, updates state with error message.
  Future<void> login(String email, String password) async {
    developer.log('🔑 Login attempt for: $email', name: 'AuthProvider');
    // update ui
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      developer.log('✅ Login successful, saving auth data...', name: 'AuthProvider');
      developer.log('📝 Saving refreshToken: ${response.refreshToken.substring(0, 8)}...', name: 'AuthProvider');
      // Save authentication data to persistent storage for session restoration
      await _storageService.saveAuthData(
        token: response.token,
        refreshToken: response.refreshToken,
        userId: response.userId,
        name: response.name,
        email: response.email,
      );

      developer.log('💾 Auth data saved to storage', name: 'AuthProvider');
      // Set token in API service for subsequent authenticated requests
      _apiService.setToken(response.token);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: response,
      );
      developer.log('✨ Login complete, user authenticated', name: 'AuthProvider');
    } catch (e) {
      // Set error state with the exception message
      developer.log('❌ Login failed: $e', name: 'AuthProvider');
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
        refreshToken: response.refreshToken,
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

  /// Refreshes the access token using the stored refresh token.
  /// This should be called when receiving a 401 Unauthorized response.
  /// On success, updates tokens in storage and API service.
  /// On failure, logs the user out.
  /// Returns true if refresh was successful, false otherwise.
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null) {
        // No refresh token available, logout
        await logout();
        return false;
      }

      final response = await _apiService.refreshAccessToken(refreshToken);

      // Save new tokens
      await _storageService.saveAuthData(
        token: response.token,
        refreshToken: response.refreshToken,
        userId: response.userId,
        name: response.name,
        email: response.email,
      );

      _apiService.setToken(response.token);

      state = state.copyWith(
        isAuthenticated: true,
        user: response,
      );

      return true;
    } catch (e) {
      // Refresh failed, logout
      await logout();
      return false;
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
