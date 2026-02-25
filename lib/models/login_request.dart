class LoginRequest {
  final String email;
  final String password;
  final String clientType;

  LoginRequest({
    required this.email,
    required this.password,
    this.clientType = 'MOBILE',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'clientType': clientType,
    };
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String clientType;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.clientType = 'MOBILE',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'clientType': clientType,
    };
  }
}
