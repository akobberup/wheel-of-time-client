/// Response from authentication endpoints (login, register, refresh).
/// Contains authentication tokens and user information.
class AuthResponse {
  /// JWT access token for authenticated API requests.
  /// Levetid: 7 dage (mobile) / 24 timer (web).
  /// Ved 401 forsøger ApiService automatisk refresh via refresh token.
  final String token;

  /// Refresh token for obtaining new access tokens.
  /// Levetid: 180 dage (mobile) / 30 dage (web).
  /// Server automatically revokes old refresh token when issuing new one.
  final String refreshToken;

  /// Unique identifier for the authenticated user.
  final int userId;

  /// Display name of the authenticated user.
  final String name;

  /// Email address of the authenticated user.
  final String email;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.userId,
    required this.name,
    required this.email,
  });

  /// Creates an AuthResponse from JSON received from the server.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  /// Converts this AuthResponse to JSON for serialization.
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
      'name': name,
      'email': email,
    };
  }
}
